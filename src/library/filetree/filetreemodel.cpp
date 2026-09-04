#include "filetreemodel.h"

#include <QDir>
#include <QFileInfo>
#include <QFutureWatcher>
#include <QStandardPaths>

#include <QtConcurrent/QtConcurrentRun>

#include "metadata/metadatautils.h"

FileTreeModel::FileTreeModel(QObject *parent) : QAbstractProxyModel(parent), m_sourceModel(nullptr){
    configureSourceModel();
    setSourceModel(&m_sourceModel);

    connect(&m_sourceModel, &QFileSystemModel::directoryLoaded, this, &FileTreeModel::slotDirectoryLoaded);
    connect(&m_sourceModel, &QAbstractItemModel::dataChanged, this, &FileTreeModel::slotDataChanged);
    connect(&m_sourceModel, &QAbstractItemModel::rowsAboutToBeInserted, this, &FileTreeModel::slotInsertRows);
    connect(&m_sourceModel, &QAbstractItemModel::rowsInserted, this, &FileTreeModel::slotEndInsertRows);
    connect(&m_sourceModel, &QAbstractItemModel::rowsAboutToBeRemoved, this, &FileTreeModel::slotRemoveRows);
    connect( &m_sourceModel, &QAbstractItemModel::rowsRemoved, this, &FileTreeModel::slotEndRemoveRows);
    connect(&m_sourceModel, &QAbstractItemModel::modelAboutToBeReset, this, &FileTreeModel::slotResetModel);
    connect(&m_sourceModel,&QAbstractItemModel::modelReset,this,&FileTreeModel::slotEndModelReset);

    const QString defaultPath = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);

    if (!defaultPath.isEmpty())
        setRootPathUrl(QUrl::fromLocalFile(defaultPath));
}

/**
 * @brief Configures the internal filesystem model.
 *
 * Directories are always included, while files are restricted to supported
 * audio formats.
 */
void FileTreeModel::configureSourceModel() {
    m_sourceModel.setFilter(
        QDir::AllDirs |
        QDir::Files |
        QDir::NoDotAndDotDot
    );

    m_sourceModel.setNameFilterDisables(false);

    m_sourceModel.setNameFilters({
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

QUrl FileTreeModel::rootPath() const {
    return QUrl::fromLocalFile(m_sourceModel.rootPath());
}

void FileTreeModel::setRootPathUrl(const QUrl &path) {
    if (!path.isLocalFile()) return;

    const QString localPath = QDir::cleanPath(path.toLocalFile());

    if (localPath.isEmpty() || localPath == m_sourceModel.rootPath())
        return;

    ++m_generation;

    m_metadataCache.clear();
    m_metadataPending.clear();

    setLoading(true);

    m_sourceModel.setRootPath(localPath);

    emit rootPathChanged();
}

QModelIndex FileTreeModel::rootIndex() const {
    return mapFromSource(m_sourceModel.index(m_sourceModel.rootPath()));
}

int FileTreeModel::columnCount(const QModelIndex &parent) const {
    Q_UNUSED(parent)
    return ColumnCount;
}

int FileTreeModel::rowCount(const QModelIndex &parent) const {
    return m_sourceModel.rowCount(mapToSource(parent));
}

QModelIndex FileTreeModel::index( const int row, const int column, const QModelIndex &parent) const {
    if (column < 0 || column >= ColumnCount)
        return {};

    const QModelIndex sourceParent = mapToSource(parent);

    const QModelIndex sourceIndex = m_sourceModel.index(row, 0, sourceParent);

    if (!sourceIndex.isValid()) return {};

    return createIndex(sourceIndex.row(), column, sourceIndex.internalPointer());
}

QModelIndex FileTreeModel::parent(const QModelIndex &index) const {
    if (!index.isValid()) return {};

    const QModelIndex sourceIndex = mapToSource(index);

    if (!sourceIndex.isValid()) return {};

    return mapFromSource(sourceIndex.parent());
}

QModelIndex FileTreeModel::mapFromSource(const QModelIndex &sourceIndex) const {
    if (!sourceIndex.isValid() || sourceIndex.model() != &m_sourceModel) return {};

    return createIndex(sourceIndex.row(), 0, sourceIndex.internalPointer());
}

QModelIndex FileTreeModel::mapToSource(const QModelIndex &proxyIndex) const {
    if (!proxyIndex.isValid() || proxyIndex.model() != this)
        return {};

    return createSourceIndex(proxyIndex.row(), 0, proxyIndex.internalPointer());
}

QVariant FileTreeModel::data(const QModelIndex &index, const int role) const {
    if (!index.isValid()) return {};

    const QModelIndex sourceIndex = mapToSource(index);

    if (!sourceIndex.isValid()) return {};

    if (role == Qt::DisplayRole) {
        if (index.column() == FileName)
            return m_sourceModel.fileName(sourceIndex);

        if (m_sourceModel.isDir(sourceIndex))
            return {};

        const QString path = m_sourceModel.filePath(sourceIndex);

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
                return MetadataUtils::formatDuration(
                    iterator.value().durationSeconds
                );

            case Genre:
                return metadata.genre();

            case HasLyrics:
                return MetadataUtils::hasLyrics(metadata);

            default:
                return {};
        }
    }

    if (role == FilePathRole) return m_sourceModel.filePath(sourceIndex);

    if (role == FileNameRole) return m_sourceModel.fileName(sourceIndex);

    if (m_sourceModel.isDir(sourceIndex)) return {};

    const QString path = m_sourceModel.filePath(sourceIndex);

    const auto iterator = m_metadataCache.constFind(path);

    if (iterator == m_metadataCache.constEnd()) return {};

    const AudioMetadata &metadata = iterator.value().metadata;

    switch (role) {
        case TitleRole: return metadata.title();
        case ArtistRole: return metadata.artist();
        case AlbumRole: return metadata.album();
        case YearRole: return MetadataUtils::extractYear(metadata.date());
        case DurationRole: return MetadataUtils::formatDuration(iterator.value().durationSeconds);
        case GenreRole: return metadata.genre();
        case HasLyricsRole: return MetadataUtils::hasLyrics(metadata);
        default: return m_sourceModel.data(sourceIndex, role);
    }
}

QVariant FileTreeModel::headerData(const int section, const Qt::Orientation orientation, const int role) const {
    if (role != Qt::DisplayRole) return {};

    if (orientation != Qt::Horizontal) return section + 1;

    switch (section) {
        case FileName: return tr("File Name");
        case Artist: return tr("Artist");
        case Album: return tr("Album");
        case Year: return tr("Year");
        case Duration: return tr("Duration");
        case Genre: return tr("Genre");
        case HasLyrics: return tr("Lyrics");
        default: return {};
    }
}

QHash<int, QByteArray> FileTreeModel::roleNames() const {
    QHash<int, QByteArray> roles = m_sourceModel.roleNames();

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

QString FileTreeModel::filePath(const QModelIndex &index) const {
    const QModelIndex sourceIndex = mapToSource(index);
    if (!sourceIndex.isValid()) return {};

    return m_sourceModel.filePath(sourceIndex);
}

bool FileTreeModel::isDirectory(const QModelIndex &index) const {
    const QModelIndex sourceIndex = mapToSource(index);
    return sourceIndex.isValid() && m_sourceModel.isDir(sourceIndex);
}

QModelIndex FileTreeModel::indexForPath(const QString &filePath) const {
    if (filePath.isEmpty()) return {};

    return mapFromSource(m_sourceModel.index(QFileInfo(filePath).absoluteFilePath()));
}

/**
 * @brief Builds the path from the configured root to a target.
 *
 * @param filePath Target filesystem path.
 * @return Ordered list starting with the model root.
 */
QStringList FileTreeModel::pathToRoot(const QString &filePath) const {
    if (filePath.isEmpty()) return {};

    const QString root = QDir::cleanPath(m_sourceModel.rootPath());
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
    const QString path = m_sourceModel.rootPath();

    if (path.isEmpty()) return;

    ++m_generation;

    m_metadataCache.clear();
    m_metadataPending.clear();

    setLoading(true);

    m_sourceModel.setRootPath(path);
}

void FileTreeModel::slotDirectoryLoaded(const QString &path) {
    loadDirectoryMetadata(path);

    if (path != m_sourceModel.rootPath()) return;
    if (!m_loading) return;

    setLoading(false);
}

void FileTreeModel::slotDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QList<int> &roles) {
    const QModelIndex proxyTopLeft = mapFromSource(topLeft);
    const QModelIndex proxyBottomRight = mapFromSource(bottomRight);

    if (!proxyTopLeft.isValid() || !proxyBottomRight.isValid())
        return;

    emit dataChanged(
        createIndex(proxyTopLeft.row(), FileName, proxyTopLeft.internalPointer()),
        createIndex(proxyBottomRight.row(), HasLyrics, proxyBottomRight.internalPointer()),
        roles
    );
}

void FileTreeModel::slotInsertRows(const QModelIndex &parent, const int first, const int last) {
    beginInsertRows(mapFromSource(parent), first, last);
}

void FileTreeModel::slotEndInsertRows() {
    endInsertRows();
}

void FileTreeModel::slotRemoveRows(const QModelIndex &parent, const int first, const int last) {
    beginRemoveRows(mapFromSource(parent), first, last);
}

void FileTreeModel::slotEndRemoveRows() {
    endRemoveRows();
}

void FileTreeModel::slotResetModel() {
    beginResetModel();
}

void FileTreeModel::slotEndModelReset() {
    endResetModel();
}

void FileTreeModel::loadMetadata(const QString &filePath)
{
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

            if (result.generation != m_generation)
                return;

            if (!result.fileInfo.has_value())
                return;

            m_metadataCache.insert(result.filePath, *result.fileInfo);

            const QModelIndex sourceIndex =
                m_sourceModel.index(result.filePath);

            const QModelIndex proxyIndex =
                mapFromSource(sourceIndex);

            if (!proxyIndex.isValid())
                return;

            emit dataChanged(
                createIndex(proxyIndex.row(), Artist, proxyIndex.internalPointer()),
                createIndex(proxyIndex.row(), HasLyrics, proxyIndex.internalPointer()),
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

    watcher->setFuture(QtConcurrent::run([filePath, generation]() {
                LibraryScanner scanner;

                MetadataResult result;
                result.filePath = filePath;
                result.generation = generation;

                const auto record = scanner.readFile(filePath);

                if (record)
                    result.fileInfo = record->fileInfo;

                return result;
            }
        )
    );
}

void FileTreeModel::loadDirectoryMetadata(const QString &path)
{
    if (path.isEmpty()) return;

    const QModelIndex directoryIndex = m_sourceModel.index(path);

    if (!directoryIndex.isValid()) return;

    const int rows = m_sourceModel.rowCount(directoryIndex);

    for (int row = 0; row < rows; ++row) {
        const QModelIndex index = m_sourceModel.index(row, 0, directoryIndex);

        if (!index.isValid() || m_sourceModel.isDir(index)) continue;

        const QString filePath = m_sourceModel.filePath(index);

        if (m_scanner.isAudioFile(filePath))
            loadMetadata(filePath);
    }
}

void FileTreeModel::setLoading(const bool loading)
{
    if (m_loading == loading) return;

    m_loading = loading;

    emit loadingChanged();
}
