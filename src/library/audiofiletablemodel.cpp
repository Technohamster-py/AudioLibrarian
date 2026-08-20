#include "audiofiletablemodel.h"

#include <QFileInfo>
#include <QBuffer>
#include <QImageReader>
#include <QDirIterator>
#include <QStandardPaths>
#include <QUrl>
#include <QtConcurrent/QtConcurrentRun>

#include <algorithm>
/**
 * @brief Creates the audio library model.
 *
 * The user's music directory is used as the initial root. The actual scan
 * starts immediately and is performed asynchronously.
 *
 * @param parent QObject parent.
 */
AudioFileTableModel::AudioFileTableModel(QObject *parent) : QAbstractTableModel(parent),
m_rootPath(QStandardPaths::writableLocation(QStandardPaths::MusicLocation)){
    connect(&m_scanWatcher, &QFutureWatcher<QVector<AudioFileRecord>>::finished, this, &AudioFileTableModel::handleScanFinished);
    reload();
}

/**
 * @brief Stops the watcher before destruction.
 *
 *  QFutureWatcher::waitForFinished() does not modify the model and is
 *  therefore safe here. It prevents the worker from finishing after the
 *  model itself has already been destroyed.
 */
AudioFileTableModel::~AudioFileTableModel() {
    if (m_scanWatcher.isRunning())
        m_scanWatcher.waitForFinished();
}

void AudioFileTableModel::setRootPath(const QUrl &path) {
    const QString localPath = path.toLocalFile();

    if (localPath == m_rootPath)
        return;

    const QFileInfo info(localPath);

    if (!localPath.isEmpty() && (!info.exists() || !info.isDir()))
        return;

    m_rootPath = localPath;
    emit rootPathChanged();
    reload();
}

bool AudioFileTableModel::isLoading() const {
    return m_loading;
}

void AudioFileTableModel::reload() {
    ++m_scanGeneration;

    if (m_scanWatcher.isRunning())
        return;

    setLoading(true);
    const QString path = m_rootPath;
    m_scanWatcher.setFuture(QtConcurrent::run(&AudioFileTableModel::scanDirectory, path));
}

int AudioFileTableModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;
    return m_files.size();
}

int AudioFileTableModel::columnCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;
    return ColumnCount;
}

QVariant AudioFileTableModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid()) return "Non valid index";
    if (index.row() < 0 || index.row() >= m_files.size()) return "Row out of range";
    if (index.column() < 0 || index.column() >= ColumnCount) return "Column out of range";

    const AudioFileRecord &record = m_files.at(index.row());
    const AudioMetadata &metadata = record.fileInfo.metadata;

    switch (role) {
        case FilePathRole:
            return record.filePath;
        case CoverRole:
            return  record.fileInfo.coverData;
        case FileNameRole:
            return QFileInfo(record.filePath).fileName();
        case TitleRole:
            return metadata.title();
        case ArtistRole:
            return metadata.artist();
        case AlbumRole:
            return metadata.album();
        case YearRole:
            return extractYear(metadata.date());
        case DurationRole:
            return formatDuration(record.fileInfo.durationSeconds);
        case GenreRole:
            return metadata.genre();
        case HasLyricsRole:
            return hasLyrics(metadata);

        case Qt::DisplayRole:
            switch (index.column()) {
                case Cover:
                    return !record.fileInfo.coverData.isEmpty();
                case FileName:
                    return QFileInfo(record.filePath).fileName();
                case Title:
                    return metadata.title();
                case Artist:
                    return metadata.artist();
                case Album:
                    return metadata.album();
                case Year:
                    return extractYear(metadata.date());
                case Duration:
                    return formatDuration(record.fileInfo.durationSeconds);
                case Genre:
                    return metadata.genre();
                case HasLyrics:
                    return hasLyrics(metadata);

                default:
                    return "N/A";
            }

        case Qt::ToolTipRole:
            return record.filePath;

        default:
            return "N/A";
    }
}

QHash<int, QByteArray> AudioFileTableModel::roleNames() const {
    return {
        {FilePathRole, "filePath"},
        {CoverRole, "cover"},
        {FileNameRole, "fileName"},
        {TitleRole, "title"},
        {ArtistRole, "artist"},
        {AlbumRole, "album"},
        {YearRole, "year"},
        {DurationRole, "duration"},
        {GenreRole, "genre"},
        {HasLyricsRole, "hasLyrics"}
    };
}

QVariant AudioFileTableModel::headerData(int section, Qt::Orientation orientation, int role) const {
    if (role != Qt:: DisplayRole) return {};
    if (orientation != Qt::Horizontal) return section + 1;

    switch (section) {
        case Cover:
            return tr("Cover");
        case FileName:
            return tr("File Name");
        case Title:
            return tr("Title");
        case Artist:
            return tr("Artist");
        case Album:
            return tr("Album");
        case Year:
            return tr("Year");
        case Duration:
            return tr("Duration");
        case Genre:
            return tr("Genre");
        case HasLyrics:
            return tr("Lyrics");
        default:
            return {};
    }
}

void AudioFileTableModel::sort(int column, Qt::SortOrder order) {
    if (column < 0 || column >= ColumnCount) return;
    if (m_files.size() < 2) return;

    layoutAboutToBeChanged();

    std::stable_sort(m_files.begin(), m_files.end(), [column, order](const AudioFileRecord &left, const AudioFileRecord &right) {
        const bool result = lessThan(left, right, column);

        return order == Qt::AscendingOrder ? result : !result && !lessThan(right, left, column);
    });

    layoutChanged();
}

/**
 * @brief Converts embedded image data into a QML-compatible data URL.
 *
 * QImageReader is used to determine the actual image format instead of
 * assuming JPEG. This allows embedded PNG, JPEG, WebP and other formats
 * supported by Qt to be displayed correctly.
 *
 * @param imageBytes Embedded image data.
 *
 * @return Data URL suitable for Image::source, or an empty string when
 *         the data cannot be recognized as an image.
 */
QString AudioFileTableModel::makeCoverUrl(const QByteArray &imageBytes) const {
    if (imageBytes.isEmpty())
        return {};

    QBuffer buffer;
    buffer.setData(imageBytes);

    if (!buffer.open(QIODevice::ReadOnly))
        return {};

    QImageReader reader(&buffer);

    const QByteArray format = reader.format();

    if (format.isEmpty())
        return {};

    QString mimeType;

    if (format.compare("jpg", Qt::CaseInsensitive) == 0 || format.compare("jpeg", Qt::CaseInsensitive) == 0) {
        mimeType = QStringLiteral("image/jpeg");
    }
    else if (format.compare("png", Qt::CaseInsensitive) == 0) {
            mimeType = QStringLiteral("image/png");
    }
    else if (format.compare("webp", Qt::CaseInsensitive) == 0) {
            mimeType = QStringLiteral("image/webp");
    }
    else if (format.compare("bmp", Qt::CaseInsensitive) == 0) {
            mimeType = QStringLiteral("image/bmp");
    }
    else if (format.compare("gif", Qt::CaseInsensitive) == 0) {
            mimeType = QStringLiteral("image/gif");
    }
    else {
            mimeType = QStringLiteral("image/%1").arg(QString::fromLatin1(format));
    }
    return QStringLiteral("data:%1;base64,%2").arg(mimeType, QString::fromLatin1(imageBytes.toBase64()));
}

void AudioFileTableModel::handleScanFinished() {
    const QVector<AudioFileRecord> files = m_scanWatcher.result();

    beginResetModel();
    m_files = files;
    endResetModel();
    setLoading(false);
}

QVector<AudioFileRecord> AudioFileTableModel::scanDirectory(const QString &path) {
    QVector<AudioFileRecord> result;

    if (path.isEmpty())
        return result;

    const QFileInfo rootInfo(path);
    if (!rootInfo.exists() || !rootInfo.isDir())
        return result;

    QDirIterator iterator(path, QDir::Files | QDir::Readable, QDirIterator::Subdirectories);

    TagLibMetadataBackend backend;

    while (iterator.hasNext()) {
        const QString filePath = iterator.next();
        const auto fileInfo = backend.readFile(filePath);

        if (!fileInfo)
            continue;

        AudioFileRecord record;
        record.filePath = filePath;
        record.fileInfo = *fileInfo;

        result.append(std::move(record));
    }

    std::sort(result.begin(), result.end(), [](const AudioFileRecord &left, const AudioFileRecord &right) {
        return QString::compare(left.filePath, right.filePath, Qt::CaseInsensitive) < 0;
    });

    return result;
}

QString AudioFileTableModel::formatDuration(int seconds) {
    if (seconds <= 0)
        return QStringLiteral("00:00");

    const int hours = seconds / 3600;
    const int minutes = (seconds % 3600) / 60;
    const int remainingSeconds = seconds % 60;

    if (hours > 0)
        return QStringLiteral("%1:%2:%3").arg(hours).arg(minutes, 2, 10, QChar('0')).arg(remainingSeconds, 2, 10, QChar('0'));
    return QStringLiteral("%1:%2").arg(minutes, 2, 10, QChar('0')).arg(remainingSeconds, 2, 10, QChar('0'));
}

QString AudioFileTableModel::extractYear(const QString &date) {
    if (date.size() < 4)
        return {};

    const QString year = date.left(4);

    bool ok = false;
    year.toInt(&ok);

    return ok? year : QString();
}

bool AudioFileTableModel::hasLyrics(const AudioMetadata &metadata) {
    static const QStringList lyricsKeys = {
        QStringLiteral("LYRICS"),
        QStringLiteral("UNSYNCEDLYRICS"),
        QStringLiteral("UNSYNCED_LYRICS"),
        QStringLiteral("USLT"),
    };

    for (const QString &key : lyricsKeys) {
        const QStringList values = metadata.values(key);

        for (const QString &value : values) {
            if (!value.trimmed().isEmpty())
                return true;
        }
    }

    for (auto iterator = metadata.properties().cbegin(); iterator != metadata.properties().cend(); ++iterator) {
        if (!iterator.key().contains(QStringLiteral("LYRIC"), Qt::CaseInsensitive))
            continue;

        for (const QString &value : iterator.value()) {
            if (!value.trimmed().isEmpty())
                return true;
        }
    }
    return false;
}

bool AudioFileTableModel::lessThan(const AudioFileRecord &left, const AudioFileRecord &right, int column) {
    const AudioMetadata leftMetadata = left.fileInfo.metadata;
    const AudioMetadata rightMetadata = right.fileInfo.metadata;

    switch (column) {
        case Cover:
            return left.fileInfo.coverData.size() < right.fileInfo.coverData.size();
        case FileName:
            return QString::compare(left.filePath, right.filePath, Qt::CaseInsensitive) < 0;
        case Title:
            return QString::compare(leftMetadata.title(), rightMetadata.title(), Qt::CaseInsensitive) < 0;
        case Artist:
            return QString::compare(leftMetadata.artist(), rightMetadata.artist(), Qt::CaseInsensitive) < 0;
        case Album:
            return QString::compare(leftMetadata.album(), rightMetadata.album(), Qt::CaseInsensitive) < 0;
        case Year:
            return extractYear(leftMetadata.date()).toInt() < extractYear(rightMetadata.date()).toInt();
        case Duration:
            return left.fileInfo.durationSeconds < right.fileInfo.durationSeconds;
        case Genre:
            return QString::compare(leftMetadata.genre(), rightMetadata.genre(), Qt::CaseInsensitive) < 0;
        case HasLyrics:
            return hasLyrics(leftMetadata) < hasLyrics(rightMetadata);
        default:
            return false;
    }
}

void AudioFileTableModel::setLoading(const bool loading) {
    if (m_loading == loading)
        return;
    m_loading = loading;
    emit loadingChanged();
}


