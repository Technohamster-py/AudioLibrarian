#include "audiofiletablemodel.h"

#include <QFileInfo>
#include <QStandardPaths>
#include <QUrl>
#include <QtConcurrent/QtConcurrentRun>

#include <algorithm>

#include "utils/datautils.h"
#include "metadata/metadatautils.h"

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
    m_scanWatcher.setFuture(QtConcurrent::run([path]() {
        LibraryScanner m_scanner;
        return m_scanner.scan(path);
    }));
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
            return  DataUrl::makeDataUrl(record.fileInfo.coverData);
        case FileNameRole:
            return QFileInfo(record.filePath).fileName();
        case TitleRole:
            return metadata.title();
        case ArtistRole:
            return metadata.artist();
        case AlbumRole:
            return metadata.album();
        case YearRole:
            return MetadataUtils::extractYear(metadata.date());
        case DurationRole:
            return MetadataUtils::formatDuration(record.fileInfo.durationSeconds);
        case GenreRole:
            return metadata.genre();
        case HasLyricsRole:
            return MetadataUtils::hasLyrics(metadata);

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
                    return MetadataUtils::extractYear(metadata.date());
                case Duration:
                    return MetadataUtils::formatDuration(record.fileInfo.durationSeconds);
                case Genre:
                    return metadata.genre();
                case HasLyrics:
                    return MetadataUtils::hasLyrics(metadata);

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

QString AudioFileTableModel::roleName(const int role) const {
    return QString::fromLatin1(roleNames().value(role));
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

void AudioFileTableModel::sort(const int column, const Qt::SortOrder order) {
    if (column < 0 || column >= ColumnCount) return;
    if (m_files.size() < 2) return;

    beginResetModel();

    std::stable_sort(m_files.begin(), m_files.end(), [column, order](const AudioFileRecord &left, const AudioFileRecord &right) {
            if (order == Qt::AscendingOrder)
                return lessThan(left, right, column);
            return lessThan(right, left, column);
        }
    );
    endResetModel();
}

bool AudioFileTableModel::reloadFile(const QString &filePath) {
    if (filePath.isEmpty())
        return false;

    const auto iterator = std::find_if(m_files.begin(), m_files.end(), [&filePath](const AudioFileRecord &record) {return record.filePath == filePath;});

    if (iterator == m_files.end())
        return false;

    const int row = std::distance(m_files.begin(), iterator);

    TagLibMetadataBackend backend;

    const auto fileInfo = backend.readFile(filePath);
    m_files[row].fileInfo = *fileInfo;

    const QModelIndex first = index(row, 0);
    const QModelIndex last = index(row, ColumnCount - 1);
    emit dataChanged(first, last, {FilePathRole,
                                                                CoverRole,
                                                                FileNameRole,
                                                                TitleRole,
                                                                ArtistRole,
                                                                AlbumRole,
                                                                YearRole,
                                                                DurationRole,
                                                                GenreRole,
                                                                HasLyricsRole,
                                                                Qt::DisplayRole}
    );

    return true;
}


void AudioFileTableModel::handleScanFinished() {
    const QVector<AudioFileRecord> files = m_scanWatcher.result();

    beginResetModel();
    m_files = files;
    endResetModel();
    setLoading(false);
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
            return MetadataUtils::extractYear(leftMetadata.date()).toInt() < MetadataUtils::extractYear(rightMetadata.date()).toInt();
        case Duration:
            return left.fileInfo.durationSeconds < right.fileInfo.durationSeconds;
        case Genre:
            return QString::compare(leftMetadata.genre(), rightMetadata.genre(), Qt::CaseInsensitive) < 0;
        case HasLyrics:
            return MetadataUtils::hasLyrics(leftMetadata) < MetadataUtils::hasLyrics(rightMetadata);
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
