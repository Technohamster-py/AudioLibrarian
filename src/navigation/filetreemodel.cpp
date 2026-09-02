#include "filetreemodel.h"

#include <QDir>
#include <QStandardPaths>

FileTreeModel::FileTreeModel(QObject *parent) : QFileSystemModel(parent) {
    configureFilters();

    const QString defaultPath = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);

    connect(this, &QFileSystemModel::directoryLoaded, this, &FileTreeModel::slotDirectoryLoaded);

    if (!defaultPath.isEmpty())
        setRootPathUrl(QUrl::fromLocalFile(defaultPath));
}

QUrl FileTreeModel::rootPath() const {
    return QUrl::fromLocalFile(QFileSystemModel::rootPath());
}

void FileTreeModel::setRootPathUrl(const QUrl &path) {
    if (!path.isLocalFile())
        return;

    const QString localPath = path.toLocalFile();

    if (localPath.isEmpty()) return;

    if (localPath == QFileSystemModel::rootPath())
        return;

    if (!m_loading) {
        m_loading = true;
        emit loadingChanged();
    }

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

void FileTreeModel::reload() {
    const QString path = QFileSystemModel::rootPath();

    if (path.isEmpty()) return;

    if (!m_loading) {
        m_loading = true;
        emit loadingChanged();
    }

    QFileSystemModel::setRootPath(path);
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

void FileTreeModel::slotDirectoryLoaded(const QString &path) {
    if (path != QFileSystemModel::rootPath()) return;

    if (!m_loading) return;

    m_loading = false;
    emit loadingChanged();
}
