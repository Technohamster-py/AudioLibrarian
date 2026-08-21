#pragma once

#include "audiometadata.h"
#include "taglibmetadatabackend.h"

#include <QAbstractListModel>
#include <QString>

#include <QtQmlIntegration/qqmlintegration.h>

/**
 * @brief Model containing metadata properties of the currently selected file.
 *
 * The model exposes every metadata property returned by TagLib. It does not
 * restrict the result to a predefined set of standard tags because different
 * audio formats may contain format-specific or custom properties.
 *
 * The current implementation is read-only. Writing metadata will be added
 * later.
 */
class TagEditorModel : public QAbstractListModel {
    Q_OBJECT

    Q_PROPERTY(
        QString filePath
        READ filePath
        WRITE setFilePath
        NOTIFY filePathChanged
    )

    QML_ELEMENT

public:
    /**
     * @brief Roles exposed to QML delegates.
     */
    enum Role {
        KeyRole = Qt::UserRole + 1,
        ValuesRole,
        ValueRole,
        DisplayNameRole,
        IsLyricsRole,
    };

    Q_ENUM(Role)

    /**
     * @brief Creates an empty metadata model.
     *
     * @param parent QObject parent.
     */
    explicit TagEditorModel(QObject *parent = nullptr);

    /**
     * @brief Returns the currently loaded file path.
     */
    [[nodiscard]] QString filePath() const;

    /**
     * @brief Sets the file whose metadata should be displayed.
     *
     * The metadata is read synchronously for now. This is acceptable for the
     * initial implementation because the editor loads one file at a time.
     * If metadata loading becomes noticeable for large files or network paths,
     * this operation can later be moved to Qt Concurrent.
     *
     * @param filePath Absolute path to an audio file.
     */
    void setFilePath(const QString &filePath);

    /**
     * @brief Returns the number of metadata properties.
     */
    [[nodiscard]] int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    /**
     * @brief Returns metadata data for a model index.
     */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    /**
     * @brief Returns role names exposed to QML.
     */
    [[nodiscard]] QHash<int, QByteArray> roleNames() const override;

signals:
    /**
     * @brief Emitted when the selected file changes.
     */
    void filePathChanged();

    /**
     * @brief Emitted when metadata could not be loaded.
     *
     * @param message Human-readable error description.
     */
    void errorOccurred(const QString &message);

private:
    /**
     * @brief One metadata property prepared for presentation.
     */
    struct TagEntry {
        QString key;        ///< Original TagLib property name.
        QStringList values; ///< Original property values.
        int priority = 9;   ///< Display-order priority.
    };

    /**
     * @brief Replaces the model contents with metadata properties.
     *
     * @param metadata Metadata read from the audio file.
     */
    void setMetadata(const AudioMetadata &metadata);

    /**
     * @brief Converts an internal metadata key into a user-readable name.
     *
     * Known standard properties receive explicit localized names. Unknown
     * properties are converted to a human-readable fallback while preserving
     * the original key through KeyRole.
     *
     * @param key Internal metadata property name.
     * @return User-readable property name.
     */
    static QString displayNameForKey(const QString &key);

    /**
     * @brief Returns the display-order priority of a metadata property.
     *
     * Lower values are displayed before higher values.
     *
     * @param key Internal metadata property name.
     * @return Sorting priority.
     */
    static int sortPriorityForKey(const QString &key);

    /**
     * @brief Formats a metadata value for presentation.
     *
     * LENGTH is stored by TagLib in milliseconds and is converted into the same
     * MM:SS / H:MM:SS representation used by AudioFileTableModel.
     *
     * @param key Metadata property name.
     * @param values Property values.
     * @return Formatted value.
     */
    static QString formatValue(const QString &key, const QStringList &values);

    /**
     * @brief Checks whether a metadata property contains lyrics.
     *
     * @param key Metadata property name.
     * @return true if the property represents lyrics.
     */
    static bool isLyricsKey(const QString &key);

    /**
    * @brief Formats a duration in milliseconds.
    *
    * @param milliseconds Duration in milliseconds.
    * @return Duration in MM:SS or H:MM:SS format.
    */
    static QString formatDuration(quint64 milliseconds);

    QString m_filePath; ///< Path to the currently loaded audio file.
    AudioMetadata m_metadata; ///< Metadata of the currently loaded file.

    /**
     * @brief Metadata entries prepared for presentation.
     *
     * This vector is intentionally separate from AudioMetadata::Properties.
     * AudioMetadata stores the source data, while this vector stores the
     * presentation order.
     */
    QVector<TagEntry> m_entries;

    TagLibMetadataBackend m_backend; ///< Backend used to read metadata.
};
