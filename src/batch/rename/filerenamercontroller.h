#pragma once

#include "batchprocesscontroller.h"
#include "filerenamer.h"
#include "library/scanner/libraryscanner.h"

#include <QLoggingCategory>
#include <QSharedPointer>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>
#include <QVariantMap>

Q_DECLARE_LOGGING_CATEGORY(renamerControllerCategory)

/**
 * @brief QML controller for batch file renaming.
 *
 * Scans the selected directory and executes FileRenamer using the
 * metadata collected by LibraryScanner.
 */
class FileRenamerController : public BatchProcessController
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit FileRenamerController(QObject *parent = nullptr);

    /**
     * @brief Starts batch file renaming.
     *
     * @param baseFilePath Directory containing files to rename.
     * @param templatePattern Rename template.
     * @return true if the operation was started.
     */
    Q_INVOKABLE bool start(const QString &baseFilePath, const QString &templatePattern);

    Q_INVOKABLE QVariantMap preparePreview(const QString &baseFilePath, const QString &templatePattern);

    /** @brief Executes the previously prepared rename operation. */
    Q_INVOKABLE bool confirmRename();

    /** @brief Discards the prepared rename operation. */
    Q_INVOKABLE void discardPreview();


protected:
    void handleFinished() override;

private:
    LibraryScanner m_scanner;
    QSharedPointer<FileRenamer> m_fileRenamer;

    QVector<AudioFileRecord> m_pendingFiles;
    QString m_pendingTemplate;
    QString m_pendingBaseDirectory;
    QVariantList m_previewEntries;
};