#pragma once

#include <QFileSystemModel>
#include <QUrl>

#include <QtQmlIntegration/qqmlintegration.h>

class FileTreeModel : public QFileSystemModel{
    Q_OBJECT

    Q_PROPERTY(QUrl rootPath
                READ rootPath
                WRITE setRootPathUrl
                NOTIFY rootPathChanged
    )

    Q_PROPERTY(QModelIndex rootIndex
                READ rootIndex
                NOTIFY rootPathChanged
    )

    Q_PROPERTY(bool loading
                READ isLoading
                NOTIFY loadingChanged
    )

    QML_ELEMENT

public:
    explicit FileTreeModel(QObject *parent = nullptr);

    QUrl rootPath() const;
    void setRootPathUrl(const QUrl &path);
    QModelIndex rootIndex() const;

    bool isLoading() const {return m_loading;};

    Q_INVOKABLE QString filePath(const QModelIndex &index) const;
    Q_INVOKABLE bool isDirectory(const QModelIndex &index) const;
    Q_INVOKABLE void reload();
signals:
    void rootPathChanged();
    void loadingChanged();

private:
    void configureFilters();
    bool m_loading = false;

private slots:
    void slotDirectoryLoaded(const QString &path);
};