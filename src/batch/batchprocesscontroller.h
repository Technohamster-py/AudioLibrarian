#pragma once

#include "batchprocessor.h"
#include "duplicates/duplicatefinder.h"
#include "library/scanner/libraryscanner.h"

#include <QObject>
#include <QSharedPointer>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

/**
 * @brief QML-facing controller for batch processing operations.
 *
 * Coordinates file scanning, batch operation configuration and asynchronous
 * execution through BatchProcessor.
 */
class BatchProcessController : public QObject {
    Q_OBJECT

    QML_ELEMENT

    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(qsizetype progressCurrent READ progressCurrent NOTIFY progressChanged)
    Q_PROPERTY(qsizetype progressTotal READ progressTotal NOTIFY progressChanged)
    Q_PROPERTY(QString progressPhase READ progressPhase NOTIFY progressChanged)
    Q_PROPERTY(QString currentFile READ currentFile NOTIFY progressChanged)
    Q_PROPERTY(qsizetype duplicateGroupCount READ duplicateGroupCount NOTIFY resultChanged)
    Q_PROPERTY(qsizetype duplicateFileCount READ duplicateFileCount NOTIFY resultChanged)
    Q_PROPERTY(qsizetype removableFileCount READ removableFileCount NOTIFY resultChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
    explicit BatchProcessController(QObject *parent = nullptr);

    bool running() const { return m_processor.isRunning(); }

    qsizetype progressCurrent() const { return m_progressCurrent; }
    qsizetype progressTotal() const { return m_progressTotal; }
    QString progressPhase() const { return m_progressPhase; }
    QString currentFile() const { return m_currentFile; }

    qsizetype duplicateGroupCount() const { return m_duplicateGroupCount; }
    qsizetype duplicateFileCount() const { return m_duplicateFileCount; }
    qsizetype removableFileCount() const { return m_removableFileCount; }

    QString errorMessage() const { return m_errorMessage; }

    /**
     * @brief Starts duplicate search for files below the specified directory.
     *
     * @param baseFilePath Directory to scan recursively.
     * @param searchByHash Enables content-based search.
     * @param searchByMetadata Enables metadata-based search.
     * @param searchByFileName Enables file-name-based search.
     * @param durationTolerance Maximum allowed duration difference in seconds.
     *
     * @return true if the operation was successfully started.
     */
    Q_INVOKABLE bool startDuplicateSearch(
        const QString &baseFilePath,
        bool searchByHash,
        bool searchByMetadata,
        bool searchByFileName,
        int durationTolerance
    );

    /**
     * @brief Requests cancellation of the current operation.
     */
    Q_INVOKABLE void cancel();

signals:
    void runningChanged();
    void progressChanged();
    void resultChanged();
    void errorMessageChanged();

private:
    void handleProgress(
        qsizetype current,
        qsizetype total,
        const QString &phase,
        const QString &currentFile
    );

    void handleFinished();
    void handleFailed(const QString &error);
    void handleCancelled();

    void setErrorMessage(const QString &message);
    void resetResult();

    LibraryScanner m_scanner;
    BatchProcessor m_processor;
    QSharedPointer<DuplicateFinder> m_duplicateFinder;

    qsizetype m_progressCurrent = 0;
    qsizetype m_progressTotal = 0;
    QString m_progressPhase;
    QString m_currentFile;

    qsizetype m_duplicateGroupCount = 0;
    qsizetype m_duplicateFileCount = 0;
    qsizetype m_removableFileCount = 0;

    QString m_errorMessage;
};