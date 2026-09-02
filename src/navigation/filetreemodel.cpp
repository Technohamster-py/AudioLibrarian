#include "filetreemodel.h"

#include <QDir>
#include <QFileInfo>
#include <QFutureWatcher>
#include <QStandardPaths>

#include <QtConcurrent/QtConcurrentRun>
#include "metadata/metadatautils.h"


FileTreeModel::FileTreeModel(QObject *parent) : QFileSystemModel(parent) {
    configureFilters();
    connect(this, &QFileSystemModel::directoryLoaded, this, &FileTreeModel::slotDirectoryLoaded);
    const QString defaultPath = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);

    if (!defaultPath.isEmpty())
        setRootPathUrl(QUrl::fromLocalFile(defaultPath));
}

QUrl FileTreeModel::rootPath() const {
    return QUrl::fromLocalFile(QFileSystemModel::rootPath());
}

void FileTreeModel::setRootPathUrl(const QUrl &path) {
    if (!path.isLocalFile()) return;

    const QString localPath = QDir::cleanPath(path.toLocalFile());

    if (localPath.isEmpty()) return;
    if (localPath == QFileSystemModel::rootPath()) return;

    ++m_generation;

    m_metadataCache.clear();
    m_metadataPending.clear();

    setLoading(true);

    QFileSystemModel::setRootPath(localPath);

    emit rootPathChanged();
}

QModelIndex FileTreeModel::rootIndex() const {
    return QFileSystemModel::index(QFileSystemModel::rootPath());
}

QString FileTreeModel::filePath(const QModelIndex &index) const {
    if (!index.isValid()) return {};

    return QFileSystemModel::filePath(index);
}

bool FileTreeModel::isDirectory(const QModelIndex &index) const {
    if (!index.isValid()) return false;
    return QFileSystemModel::isDir(index);
}

QModelIndex FileTreeModel::indexForPath(const QString &filePath) const {
    if (filePath.isEmpty()) return {};
    return QFileSystemModel::index(QFileInfo(filePath).absoluteFilePath());
}

QStringList FileTreeModel::pathToRoot(const QString &filePath) const {
    if (filePath.isEmpty()) return {};

    const QString root = QDir::cleanPath(QFileSystemModel::rootPath());
    const QString target = QDir::cleanPath(QFileInfo(filePath).absoluteFilePath());

    if (root.isEmpty() || target.isEmpty()) return {};

    const QString rootPrefix = root.endsWith(QDir::separator()) ? root : root + QDir::separator();

    if (target != root && !target.startsWith(rootPrefix)) return {};

    QStringList result;

    QString current = target;

    while (!current.isEmpty()) {
        result.prepend(current);

        if (current == root) break;

        const QString parent = QFileInfo(current).absoluteDir().absolutePath();

        if (parent == current) return {};

        current = QDir::cleanPath(parent);
    }

    if (result.isEmpty() || result.first() != root) return {};

    return result;
}


void FileTreeModel::reload() {
    const QString path = QFileSystemModel::rootPath();

    if (path.isEmpty()) return;

    ++m_generation;

    m_metadataCache.clear();
    m_metadataPending.clear();

    setLoading(true);

    QFileSystemModel::setRootPath(path);
}

QVariant FileTreeModel::data(const QModelIndex &index, const int role) const {
    if (!index.isValid()) return {};

    switch (role) {
        case FilePathRole:
            return QFileSystemModel::filePath(index);

        case FileNameRole:
            // QFileSystemModel::fileName() delegates to data(). Calling it
            // from this override would recurse indefinitely for this role.
            return QFileInfo(QFileSystemModel::filePath(index)).fileName();

        case TitleRole:
        case ArtistRole:
        case AlbumRole:
        case YearRole:
        case DurationRole:
        case GenreRole:
        case HasLyricsRole:
            break;
        default:
            return QFileSystemModel::data(index, role);
    }


    if (QFileSystemModel::isDir(index))return role == HasLyricsRole ? QVariant(false) : QVariant(QString());

    const QString path = QFileSystemModel::filePath(index);

    if (path.isEmpty()) return role == HasLyricsRole ? QVariant(false) : QVariant(QString());

    const auto iterator = m_metadataCache.constFind(path);

    if (iterator == m_metadataCache.constEnd()) return role == HasLyricsRole ? QVariant(false) : QVariant(QString());

    const AudioFileInfo &fileInfo = iterator.value();

    const AudioMetadata &metadata = fileInfo.metadata;

    switch (role) {
        case TitleRole:
            return metadata.title();
        case ArtistRole:
            return metadata.artist();
        case AlbumRole:
            return metadata.album();
        case YearRole:
            return MetadataUtils::extractYear(metadata.date());
        case DurationRole:
            return MetadataUtils::formatDuration(fileInfo.durationSeconds);
        case GenreRole:
            return metadata.genre();
        case HasLyricsRole:
            return MetadataUtils::hasLyrics(metadata);
        default:
            return {};
    }
}

QHash<int, QByteArray> FileTreeModel::roleNames() const {
    QHash<int, QByteArray> roles = QFileSystemModel::roleNames();

    roles.insert(FilePathRole, QByteArrayLiteral("filePath"));
    roles.insert(FileNameRole, QByteArrayLiteral("fileName"));
    roles.insert(TitleRole, QByteArrayLiteral("title"));
    roles.insert(ArtistRole, QByteArrayLiteral("artist"));
    roles.insert(AlbumRole, QByteArrayLiteral("album"));
    roles.insert(YearRole, QByteArrayLiteral("year"));
    roles.insert(DurationRole, QByteArrayLiteral("duration"));
    roles.insert(GenreRole, QByteArrayLiteral("genre"));
    roles.insert(HasLyricsRole, QByteArrayLiteral("hasLyrics"));

    return roles;
}

void FileTreeModel::slotDirectoryLoaded(const QString &path) {
    loadDirectoryMetadata(path);

    if (path != QFileSystemModel::rootPath()) return;
    if (!m_loading) return;

    setLoading(false);
}


void FileTreeModel::configureFilters() {
    setFilter(
        QDir::AllDirs |
        QDir::Files |
        QDir::NoDotAndDotDot
    );

    setNameFilterDisables(false);

    setNameFilters({
        QStringLiteral("*.mp3"),
        QStringLiteral("*.flac"),
        QStringLiteral("*.ogg"),
        QStringLiteral("*.oga"),
        QStringLiteral("*.wav"),
        QStringLiteral("*.m4a"),
        QStringLiteral("*.aac"),
        QStringLiteral("*.opus"),
        QStringLiteral("*.wma"),
        QStringLiteral("*.aiff"),
        QStringLiteral("*.aif")
    });
}


void FileTreeModel::loadMetadata(const QString &filePath) {
    if (filePath.isEmpty()) return;
    if (m_metadataCache.contains(filePath)) return;
    if (m_metadataPending.contains(filePath)) return;

    m_metadataPending.insert(filePath);

    const quint64 generation = m_generation;

    auto *watcher = new QFutureWatcher<MetadataResult>(this);

    connect(watcher, &QFutureWatcher<MetadataResult>::finished, this, [this, watcher]() {
                const MetadataResult result = watcher->result();
                watcher->deleteLater();
                m_metadataPending.remove(result.filePath);

                if (result.generation != m_generation) return;

                if (!result.fileInfo.has_value()) return;

                m_metadataCache.insert(result.filePath, *result.fileInfo);

                const QModelIndex index = QFileSystemModel::index(result.filePath);

                if (!index.isValid()) return;

                emit dataChanged(index, index, {
                                     TitleRole, ArtistRole, AlbumRole, YearRole, DurationRole, GenreRole, HasLyricsRole
                                 });
            }
    );


    watcher->setFuture(
        QtConcurrent::run(
            [filePath, generation]() {
                TagLibMetadataBackend backend;

                MetadataResult result;
                result.filePath = filePath;
                result.generation = generation;

                result.fileInfo = backend.readFile(filePath);

                return result;
            }
        )
    );
}

/**
 * @brief Starts asynchronous metadata loading for files in a directory.
 *
 * QFileSystemModel emits directoryLoaded() as each directory becomes
 * available. This allows metadata loading to follow QFileSystemModel's
 * lazy-loading behaviour instead of performing a second recursive scan.
 *
 * @param path Loaded directory.
 */
void FileTreeModel::loadDirectoryMetadata(const QString &path) {
    if (path.isEmpty())return;

    const QModelIndex directoryIndex = QFileSystemModel::index(path);

    if (!directoryIndex.isValid()) return;

    const int rows = QFileSystemModel::rowCount(directoryIndex);

    for (int row = 0; row < rows; ++row) {
        const QModelIndex index = QFileSystemModel::index(row, 0, directoryIndex);

        if (!index.isValid()) continue;
        if (QFileSystemModel::isDir(index)) continue;

        const QString filePath = QFileSystemModel::filePath(index);

        if (isAudioFile(filePath))
            loadMetadata(filePath);
    }
}

bool FileTreeModel::isAudioFile(const QString &filePath) {
    const QString suffix = QFileInfo(filePath).suffix().toLower();

    return suffix == QStringLiteral("mp3") ||
           suffix == QStringLiteral("flac") ||
           suffix == QStringLiteral("ogg") ||
           suffix == QStringLiteral("oga") ||
           suffix == QStringLiteral("wav") ||
           suffix == QStringLiteral("m4a") ||
           suffix == QStringLiteral("aac") ||
           suffix == QStringLiteral("opus") ||
           suffix == QStringLiteral("wma") ||
           suffix == QStringLiteral("aiff") ||
           suffix == QStringLiteral("aif");
}

void FileTreeModel::setLoading(const bool loading) {
    if (m_loading == loading)
        return;

    m_loading = loading;

    emit loadingChanged();
}
