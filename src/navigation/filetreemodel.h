#pragma once

#include <QFileSystemModel>
#include <QHash>
#include <QSet>
#include <QStringList>
#include <QUrl>

#include <optional>

#include <QtQmlIntegration/qqmlintegration.h>

#include "metadata/taglibmetadatabackend.h"


class FileTreeModel : public QFileSystemModel
{
    Q_OBJECT

    Q_PROPERTY(
        QUrl rootPath
        READ rootPath
        WRITE setRootPathUrl
        NOTIFY rootPathChanged
    )

    Q_PROPERTY(
        QModelIndex rootIndex
        READ rootIndex
        NOTIFY rootPathChanged
    )

    Q_PROPERTY(
        bool loading
        READ isLoading
        NOTIFY loadingChanged
    )

    QML_ELEMENT

public:
    /**
     * @brief Custom roles exposed to QML.
     */
    enum Roles {
        FilePathRole = Qt::UserRole + 100,
        FileNameRole,
        TitleRole,
        ArtistRole,
        AlbumRole,
        YearRole,
        DurationRole,
        GenreRole,
        HasLyricsRole
    };

    Q_ENUM(Roles)

    explicit FileTreeModel(QObject *parent = nullptr);

    QUrl rootPath() const;
    void setRootPathUrl(const QUrl &path);
    QModelIndex rootIndex() const;

    bool isLoading() const {return m_loading;};

    Q_INVOKABLE QString filePath(const QModelIndex &index) const;
    Q_INVOKABLE bool isDirectory(const QModelIndex &index) const;
    Q_INVOKABLE QModelIndex indexForPath(const QString &filePath) const;
    Q_INVOKABLE QStringList pathToRoot(const QString &filePath) const;
    Q_INVOKABLE void reload();

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    void rootPathChanged();
    void loadingChanged();
private:

    struct MetadataResult {
        QString filePath;
        std::optional<AudioFileInfo> fileInfo;
        quint64 generation = 0;
    };

    void configureFilters();
    void loadMetadata(const QString &filePath);
    void loadDirectoryMetadata(const QString &path);

    static bool isAudioFile(const QString &filePath);

    void setLoading(bool loading);

    bool m_loading = false;

    QHash<QString, AudioFileInfo> m_metadataCache;
    QSet<QString> m_metadataPending;
    quint64 m_generation = 0;

private slots:
    void slotDirectoryLoaded(const QString &path);
};
