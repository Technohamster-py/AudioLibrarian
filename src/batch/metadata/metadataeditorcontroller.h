#pragma once

#include "batchprocesscontroller.h"
#include "metadataeditor.h"
#include "metadataeditresultmodel.h"

#include "library/scanner/libraryscanner.h"

#include <QSharedPointer>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

/**
 * @brief QML controller for batch metadata editing.
 *
 * Scans files in the selected directory and executes MetadataEditor
 * with the metadata changes supplied by the user.
 */
class MetadataEditorController final : public BatchProcessController
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(qsizetype selectedFileCount READ selectedFileCount NOTIFY selectedFileCountChanged)
    Q_PROPERTY(MetadataEditResultModel *resultModel READ resultModel CONSTANT)

public:
    explicit MetadataEditorController(QObject *parent = nullptr);

    /** @brief Returns the number of files selected for processing. */
    qsizetype selectedFileCount() const { return m_selectedFileCount; }

    /**
     * @brief Starts batch metadata editing.
     *
     * @param baseFilePath Directory to scan recursively.
     * @param changes Metadata changes to apply to every scanned file.
     * @return true if the operation was started.
     */
    Q_INVOKABLE bool start(const QString &baseFilePath, const QVariantList &changes);

    signals:
        void selectedFileCountChanged();

    /**
 * @brief Returns the model containing metadata edit results.
 */
    MetadataEditResultModel *resultModel() { return &m_resultModel; }

protected:
    void handleFinished() override;

private:
    LibraryScanner m_scanner;
    QSharedPointer<MetadataEditor> m_metadataEditor;

    qsizetype m_selectedFileCount = 0;

    MetadataEditResultModel m_resultModel;
};