#pragma once

#include "metadata/taglibmetadatabackend.h"
#include "library/audiofilerecord.h"
#include "library/scanner/libraryscanner.h"

#include <QAbstractTableModel>
#include <QUrl>
#include <QVector>

#include <QFutureWatcher>
#include <QtQmlIntegration/qqmlintegration.h>



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

    QML_ELEMENT

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

    /**
     * @brief Creates the model.
     *
     * The default root path is QStandardPaths::MusicLocation.
     *
     * @param parent QObject parent.
     */
    explicit AudioFileTableModel(QObject *parent = nullptr);

    ~AudioFileTableModel() override;

    /**
     * @brief Returns the directory currently scanned by the model.
     */
    QUrl rootPath() const { return QUrl::fromLocalFile(m_rootPath); }

    /**
     * @brief Changes the directory scanned by the model.
     *
     * Changing the path automatically starts a new asynchronous scan.
     *
     * @param path Directory URL.
     */
    void setRootPath(const QUrl &path);

    /**
     * @brief Returns whether a scan is currently running.
     */
    bool isLoading() const;

    /**
     * @brief Starts scanning the current directory again.
     */
    Q_INVOKABLE void reload();

    /**
     * @brief Returns the number of audio files.
     */
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    /**
     * @brief Returns the number of logical columns.
     */
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;

    /**
     * @brief Returns data for the specified cell or role.
     */
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    /**
     * @brief Returns role names for QML.
     */
    QHash<int, QByteArray> roleNames() const override;

    /**
     * @brief Returns one role name for QML-facing model contract checks.
     */
    Q_INVOKABLE QString roleName(int role) const;

    /**
     * @brief Returns column header data.
     */
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

    /**
     * @brief Sorts the model by a logical column.
     *
     * @param column Logical column index.
     * @param order Sort direction.
     */
    Q_INVOKABLE void sort(int column, Qt::SortOrder order = Qt::AscendingOrder) override;

    Q_INVOKABLE bool reloadFile(const QString &filePath);

signals:
    /**
    * @brief Emitted when rootPath changes.
    */
    void rootPathChanged();

    /**
     * @brief Emitted when scanning state changes.
     */
    void loadingChanged();

private slots:
    /**
     * @brief Handles completion of an asynchronous scan.
     */
    void handleScanFinished();

private:
    /**
     * @brief Compares two records according to a logical column.
     */
    static bool lessThan(const AudioFileRecord &left, const AudioFileRecord &right, int column);

    /**
     * @brief Changes the loading state and emits loadingChanged().
     */
    void setLoading(const bool loading);

    QString m_rootPath;
    QVector<AudioFileRecord> m_files;
    bool m_loading = false;

    struct ScanResult {
        quint64 generation = 0;
        QVector<AudioFileRecord> files;
    };

    /**
     * @brief Identifies the most recent scan request.
     *
     * A scan cannot be forcefully cancelled reliably once TagLib has
     * started reading a file. The generation counter lets us discard
     * results belonging to an older rootPath/reload request.
     */
    quint64 m_scanGeneration = 0;
    QFutureWatcher<ScanResult> m_scanWatcher;

    void startScan(quint64 generation);
};
