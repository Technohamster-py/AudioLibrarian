#include "filerenamercontroller.h"

#include <QDir>

FileRenamerController::FileRenamerController(QObject *parent) : BatchProcessController(parent) {
}

bool FileRenamerController::start(const QString &baseFilePath, const QString &templatePattern)
{
    const QDir directory(baseFilePath);

    if (!directory.exists() || templatePattern.trimmed().isEmpty())
        return false;

    const QVector<AudioFileRecord> files = m_scanner.scan(baseFilePath);

    if (files.isEmpty())
        return false;

    m_fileRenamer = QSharedPointer<FileRenamer>::create(
        templatePattern,
        baseFilePath
    );

    clearError();

    return startOperation(m_fileRenamer, files);
}