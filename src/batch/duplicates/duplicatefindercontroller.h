#pragma once

#include "batch/batchprocessor.h"
#include "duplicatefinder.h"
#include "library/scanner/libraryscanner.h"

#include <QObject>
#include <QSharedPointer>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

/**
 * @brief QML-facing controller for duplicate file search.
 *
 * Prepares DuplicateFinder settings, scans the selected directory and
 * delegates asynchronous execution to BatchProcessor.
 */
class DuplicateFinderController : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(qint64 progressCurrent READ progressCurrent NOTIFY progressChanged)
    Q_PROPERTY(qint64 progressTotal READ progressTotal NOTIFY progressChanged)
    Q_PROPERTY(QString phase READ phase NOTIFY progressChanged)
    Q_PROPERTY(QString currentFile READ currentFile NOTIFY progressChanged)

    Q_PROPERTY(qint64 duplicateGroupCount READ duplicateGroupCount NOTIFY resultChanged)
    Q_PROPERTY(qint64 duplicateFileCount READ duplicateFileCount NOTIFY resultChanged)
    Q_PROPERTY(qint64 removableFileCount READ removableFileCount NOTIFY resultChanged)

    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
    explicit DuplicateFinderController(QObject *parent = nullptr);

    bool running() const { return m_running; }

    qint64 progressCurrent() const { return m_progressCurrent; }
    qint64 progressTotal() const { return m_progressTotal; }

    QString phase() const { return m_phase; }
    QString currentFile() const { return m_currentFile; }

    qint64 duplicateGroupCount() const { return m_duplicateGroupCount; }
    qint64 duplicateFileCount() const { return m_duplicateFileCount; }
    qint64 removableFileCount() const { return m_removableFileCount; }

    QString errorMessage() const { return m_errorMessage; }

    /**
     * @brief Starts duplicate search for the selected directory.
     *
     * @param basePath Root directory to scan recursively.
     * @param searchByHash Enables content-based search.
     * @param searchByMetadata Enables metadata-based search.
     * @param searchByFileName Enables file-name-based search.
     * @param durationTolerance Maximum allowed metadata duration difference.
     *
     * @return true when the operation was successfully started.
     */
    Q_INVOKABLE bool start(
        const QString &basePath,
        bool searchByHash,
        bool searchByMetadata,
        bool searchByFileName,
        int durationTolerance
    );

    /** @brief Requests cancellation of the current search. */
    Q_INVOKABLE void cancel();

signals:
    void runningChanged();
    void progressChanged();
    void resultChanged();
    void errorMessageChanged();

private:
    void setRunning(bool running);
    void setErrorMessage(const QString &message);
    void resetResult();
    void handleProgress(
        qsizetype current,
        qsizetype total,
        const QString &phase,
        const QString &currentFile
    );

    BatchProcessor m_processor;
    QSharedPointer<DuplicateFinder> m_duplicateFinder;
    LibraryScanner m_scanner;

    bool m_running = false;

    qint64 m_progressCurrent = 0;
    qint64 m_progressTotal = 0;

    QString m_phase;
    QString m_currentFile;
    QString m_errorMessage;

    qint64 m_duplicateGroupCount = 0;
    qint64 m_duplicateFileCount = 0;
    qint64 m_removableFileCount = 0;
};