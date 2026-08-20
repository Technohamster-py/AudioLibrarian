#pragma once

#include "metadata/audiometadata.h"

#include <QAbstractTableModel>
#include <QUrl>
#include <QVector>

/**
 * @brief Represents one audio file in the library.
 *
 * The record contains only data required by the library view.
 * TagLib-specific types are deliberately not exposed here.
 */
struct AudioFileRecord {
    QString filePath; ///< Absolute path to the audio file.
    AudioMetadata metadata; ///< Format-independent textual metadata.
    int durationSeconds = 0; ///< Duration in seconds.
};

/**
 * @brief Table model representing the audio library.
 *
 * The model recursively scans a directory and exposes supported audio
 * files as rows. Each column represents one property of an audio file.
 *
 * The model is intentionally a QAbstractTableModel because the QML view
 * is a real table rather than a list with a collection of unrelated
 * properties.
 */
class AudioFileTableModel : public QAbstractTableModel {
    Q_OBJECT

    /**
     * @brief Directory being scanned by the model
     */
    Q_PROPERTY(
        QUrl rootPath
        READ rootPath
        WRITE setRootPath
        NOTIFY rootPathChanged
    )

    /**
     * @brief Indicates whether the directory is currently being scanned.
     */
    Q_PROPERTY(
        bool loading
        READ isLoading
        NOTIFY loadingChanged
    )

public:
    /**
     * @brief Columns exposed by the model.
     *
     * The order of this enum is the logical model order.
     * QML may change the visual order of columns without modifying
     * these logical indexes.
     */
    enum Column {
        Cover = 0,
        FileName,
        Title,
        Artist,
        Album,
        Year,
        Duration,
        Genre,
        HasLyrics,
        ColumnCount
    };

    Q_ENUM(Column)

    /**
     * @brief Roles exposed by the model.
     */
    enum Role {
        FilePathRole = Qt::UserRole + 1,
        CoverRole,
        FileNameRole,
        TitleRole,
        ArtistRole,
        AlbumRole,
        YearRole,
        DurationRole,
        GenreRole,
        HasLyricsRole
    };

    Q_ENUM(Role)

    explicit AudioFileTableModel(QObject *parent = nullptr);

    ~AudioFileTableModel() override;

    QUrl rootPath() const;

    void setRootPath(const QUrl &path);

    bool isLoading() const;

    Q_INVOKABLE void reload();

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

    void sort(int column, Qt::SortOrder order = Qt::AscendingOrder) override;

signals:
    void rootPathChanged();
    void loadingChanged();

private:
    static QVector<AudioFileRecord> scanDirectory(const QString &path);

    static QString formatDuration(int seconds);

    static QString extractYear(const QString &date);

    static bool hasLyrics(const AudioMetadata &metadata);

    static bool lessThan(const AudioFileRecord &left, const AudioFileRecord &right, int column);

    QString m_rootPath;
    QVector<AudioFileRecord> m_files;
    bool m_loading = false;
};
