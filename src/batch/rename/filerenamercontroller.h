#pragma once

#include "batchprocesscontroller.h"
#include "filerenamer.h"
#include "library/scanner/libraryscanner.h"

#include <QSharedPointer>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

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

private:
    LibraryScanner m_scanner;
    QSharedPointer<FileRenamer> m_fileRenamer;
};