#include "filerenamercontroller.h"

#include <QDir>

Q_LOGGING_CATEGORY(renamerControllerCategory, "renamerController")

FileRenamerController::FileRenamerController(QObject *parent) : BatchProcessController(parent) {
    connect(processor(), &BatchProcessor::finished, this, &FileRenamerController::handleFinished);
}

bool FileRenamerController::start(const QString &baseFilePath, const QString &templatePattern)
{
    const QDir directory(baseFilePath);
    qCDebug(renamerControllerCategory, "Starting file renaming process for directory: %s", qPrintable(baseFilePath));

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

    qCDebug(renamerControllerCategory, "Renaming process for directory %s is started", qPrintable(baseFilePath));
    return startOperation(m_fileRenamer, files);
}

void FileRenamerController::handleFinished()
{
}


QVariantMap FileRenamerController::preparePreview(const QString &baseFilePath, const QString &templatePattern) {
    discardPreview();

    if (running() || templatePattern.trimmed().isEmpty()) {
        clearError();
        return {
            {QStringLiteral("entries"), QVariantList{}},
            {QStringLiteral("error"), QStringLiteral("Can't start now")}
        };
    }

    const QDir directory(baseFilePath);
    if (!directory.exists()) {
        return {
            {QStringLiteral("entries"), QVariantList{}},
            {QStringLiteral("error"), QStringLiteral("Invalid directory")}
        };
    }

    m_pendingFiles = m_scanner.scan(baseFilePath);
    if (m_pendingFiles.isEmpty()) {
        m_pendingFiles.clear();
        return {
            {QStringLiteral("entries"), QVariantList{}},
            {QStringLiteral("error"), QStringLiteral("No files found")}
        };
    }

    m_pendingBaseDirectory = directory.absolutePath();
    m_pendingTemplate = templatePattern;

    const FileRenamer renamer(m_pendingTemplate, m_pendingBaseDirectory);
    QString error;
    m_previewEntries = renamer.preview(m_pendingFiles, &error);

    if (!error.isEmpty() || m_previewEntries.isEmpty()) {
        m_pendingFiles.clear();
        m_pendingTemplate.clear();
        m_pendingBaseDirectory.clear();
        m_previewEntries.clear();
        return {
            {QStringLiteral("entries"), QVariantList{}},
            {QStringLiteral("error"), error}
        };
    }

    clearError();
    return {
        {QStringLiteral("entries"), m_previewEntries},
        {QStringLiteral("error"), error}
    };}

bool FileRenamerController::confirmRename()
{
    if (running() || m_pendingFiles.isEmpty() || m_pendingTemplate.isEmpty())
        return false;

    m_fileRenamer = QSharedPointer<FileRenamer>::create(
        m_pendingTemplate, m_pendingBaseDirectory);

    const bool started = startOperation(m_fileRenamer, m_pendingFiles);
    if (started)
        discardPreview();

    return started;
}

void FileRenamerController::discardPreview()
{
    m_pendingFiles.clear();
    m_pendingTemplate.clear();
    m_pendingBaseDirectory.clear();
    m_previewEntries.clear();
}