#include "filetreemodel.h"

#include <QDir>
#include <QFileInfo>
#include <QFutureWatcher>
#include <QStandardPaths>

#include <QtConcurrent/QtConcurrentRun>
#include "metadata/metadatautils.h"


FileTreeModel::FileTreeModel(QObject *parent): QFileSystemModel(parent){
    configureFilters();
    connect(this, &QFileSystemModel::directoryLoaded, this, &FileTreeModel::slotDirectoryLoaded);

    const QString defaultPath = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);

    if (!defaultPath.isEmpty())
        setRootPathUrl(QUrl::fromLocalFile(defaultPath));
}

QUrl FileTreeModel::rootPath() const{
    return QUrl::fromLocalFile(QFileSystemModel::rootPath());
}

void FileTreeModel::setRootPathUrl(const QUrl &path){
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

QModelIndex FileTreeModel::rootIndex() const{
    return QFileSystemModel::index(QFileSystemModel::rootPath());
}


int FileTreeModel::columnCount(const QModelIndex &parent) const{
    // Every item in this tree has the same set of columns.  Returning zero
    // for a valid parent makes QTreeView/TreeView treat child rows as having
    // no columns and can leave it holding indexes that no longer belong to
    // this model.
    Q_UNUSED(parent)
    return ColumnCount;
}


QVariant FileTreeModel::data(const QModelIndex &index, const int role) const{
    if (!index.isValid()) return {};

    if (role == FilePathRole)
        return QFileSystemModel::filePath(index);

    if (role == FileNameRole)
        return QFileSystemModel::fileName(index);

    if (role == Qt::DisplayRole) {
        if (QFileSystemModel::isDir(index)) {
            if (index.column() == FileName)
                return QFileSystemModel::fileName(index);
            return {};
        }

        const QString path = QFileSystemModel::filePath(index);

        if (path.isEmpty()) return {};
        if (index.column() == FileName) return QFileSystemModel::fileName(index);

        const auto iterator = m_metadataCache.constFind(path);

        if (iterator == m_metadataCache.constEnd())
            return {};

        const AudioMetadata &metadata = iterator.value().metadata;

        switch (index.column()) {
            case Artist:
                return metadata.artist();

            case Album:
                return metadata.album();

            case Year:
                return MetadataUtils::extractYear(metadata.date());

            case Duration:
                return MetadataUtils::formatDuration(iterator.value().durationSeconds);

            case Genre:
                return metadata.genre();

            case HasLyrics:
                return MetadataUtils::hasLyrics(metadata);

            default:
                return {};
        }
    }

    /*
     * Custom roles expose metadata independently of the current column.
     * This is useful for QML delegates and keeps the model API consistent
     * with AudioFileTableModel.
     */
    if (QFileSystemModel::isDir(index))
        return {};

    const QString path =
        QFileSystemModel::filePath(index);

    if (path.isEmpty())
        return {};

    const auto iterator =
        m_metadataCache.constFind(path);

    if (iterator == m_metadataCache.constEnd())
        return {};

    const AudioMetadata &metadata =
        iterator.value().metadata;

    switch (role) {
        case TitleRole:
            return metadata.title();

        case ArtistRole:
            return metadata.artist();

        case AlbumRole:
            return metadata.album();

        case YearRole:
            return MetadataUtils::extractYear(
                metadata.date()
            );

        case DurationRole:
            return MetadataUtils::formatDuration(
                iterator.value().durationSeconds
            );

        case GenreRole:
            return metadata.genre();

        case HasLyricsRole:
            return MetadataUtils::hasLyrics(metadata);

        default:
            return QFileSystemModel::data(index, role);
    }
}


QVariant FileTreeModel::headerData(const int section, const Qt::Orientation orientation, const int role) const{
    if (role != Qt::DisplayRole)
        return {};

    if (orientation != Qt::Horizontal)
        return section + 1;

    switch (section) {
        case FileName:
            return tr("File Name");

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

QHash<int, QByteArray> FileTreeModel::roleNames() const{
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

QString FileTreeModel::filePath(const QModelIndex &index) const{
    if (!index.isValid())
        return {};
    return QFileSystemModel::filePath(index);
}

bool FileTreeModel::isDirectory(const QModelIndex &index) const
{
    if (!index.isValid())
        return false;
    return QFileSystemModel::isDir(index);
}

QModelIndex FileTreeModel::indexForPath(const QString &filePath) const{
    if (filePath.isEmpty())
        return {};

    return QFileSystemModel::index(
        QFileInfo(filePath).absoluteFilePath()
    );
}


/**
 * @brief Builds the path from the configured root to a target.
 *
 * @param filePath Target filesystem path.
 * @return Ordered list starting with the model root.
 */
QStringList FileTreeModel::pathToRoot(const QString &filePath) const{
    if (filePath.isEmpty())
        return {};

    const QString root = QDir::cleanPath(QFileSystemModel::rootPath());

    const QString target = QDir::cleanPath(QFileInfo(filePath).absoluteFilePath());

    if (root.isEmpty() || target.isEmpty())
        return {};

    const QString rootPrefix = root.endsWith(QDir::separator())? root : root + QDir::separator();

    if (target != root && !target.startsWith(rootPrefix)) {
        return {};
    }

    QStringList result;

    QString current = target;

    while (!current.isEmpty()) {
        result.prepend(current);

        if (current == root)
            break;

        const QString parent = QFileInfo(current).absoluteDir().absolutePath();

        if (parent == current)
            return {};

        current = QDir::cleanPath(parent);
    }

    if (result.isEmpty() ||
        result.first() != root) {
        return {};
    }

    return result;
}

void FileTreeModel::reload()
{
    const QString path = QFileSystemModel::rootPath();

    if (path.isEmpty())
        return;

    ++m_generation;

    m_metadataCache.clear();
    m_metadataPending.clear();

    setLoading(true);

    QFileSystemModel::setRootPath(path);
}

void FileTreeModel::slotDirectoryLoaded(const QString &path){
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


void FileTreeModel::loadMetadata(const QString &filePath){
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

            if (!index.isValid())return;

            const QModelIndex first = index.siblingAtColumn(Artist);
            const QModelIndex last = index.siblingAtColumn(HasLyrics);

            emit dataChanged(
                first,
                last,
                {
                    Qt::DisplayRole,
                    TitleRole,
                    ArtistRole,
                    AlbumRole,
                    YearRole,
                    DurationRole,
                    GenreRole,
                    HasLyricsRole
                }
            );
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

void FileTreeModel::loadDirectoryMetadata(const QString &path){
    if (path.isEmpty()) return;

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

bool FileTreeModel::isAudioFile(const QString &filePath){
    const QString suffix =QFileInfo(filePath).suffix().toLower();

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

void FileTreeModel::setLoading(const bool loading){
    if (m_loading == loading)
        return;

    m_loading = loading;

    emit loadingChanged();
}
