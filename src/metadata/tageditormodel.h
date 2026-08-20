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
        ValueRole
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
     * @brief Replaces the model contents with metadata properties.
     *
     * @param metadata Metadata read from the audio file.
     */
    void setMetadata(const AudioMetadata &metadata);

    QString m_filePath; ///< Path to the currently loaded audio file.
    AudioMetadata m_metadata; ///< Metadata of the currently loaded file.

    TagLibMetadataBackend m_backend; ///< Backend used to read metadata.
};
