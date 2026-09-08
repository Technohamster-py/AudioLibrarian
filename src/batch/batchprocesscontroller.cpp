#include "batchprocesscontroller.h"

#include <QDir>
#include <QSet>

BatchProcessController::BatchProcessController(QObject *parent): QObject(parent), m_duplicateFinder(QSharedPointer<DuplicateFinder>::create()) {
    connect(&m_processor,&BatchProcessor::stateChanged, this, &BatchProcessController::runningChanged);
    connect(&m_processor, &BatchProcessor::progressChanged, this,&BatchProcessController::handleProgress);
    connect(&m_processor,&BatchProcessor::finished,this,&BatchProcessController::handleFinished);
    connect(&m_processor,&BatchProcessor::failed,this,&BatchProcessController::handleFailed);
    connect(&m_processor,&BatchProcessor::cancelled,this,&BatchProcessController::handleCancelled);
}

bool BatchProcessController::startDuplicateSearch(const QString &baseFilePath,const bool searchByHash,const bool searchByMetadata,const bool searchByFileName,const int durationTolerance) {
    if (m_processor.isRunning())
        return false;

    const QDir directory(baseFilePath);

    if (!directory.exists()) {
        setErrorMessage(tr("Directory does not exist"));
        return false;
    }

    QSet<DuplicateSearchMode> searchModes;

    if (searchByHash)
        searchModes.insert(DuplicateSearchMode::Content);

    if (searchByMetadata)
        searchModes.insert(DuplicateSearchMode::Metadata);

    if (searchByFileName)
        searchModes.insert(DuplicateSearchMode::FileName);

    if (searchModes.isEmpty()) {
        setErrorMessage(tr("No search mode selected"));
        return false;
    }

    resetResult();
    setErrorMessage({});

    m_duplicateFinder->setSearchModes(searchModes);
    m_duplicateFinder->setDurationTolerance(durationTolerance);

    const QVector<AudioFileRecord> files = m_scanner.scan(baseFilePath);

    if (!m_processor.start(m_duplicateFinder, files)) {
        setErrorMessage(tr("Failed to start duplicate search"));
        return false;
    }

    emit runningChanged();

    return true;
}

void BatchProcessController::cancel() {
    m_processor.cancel();
}

void BatchProcessController::handleProgress(const qsizetype current, const qsizetype total, const QString &phase, const QString &currentFile) {
    m_progressCurrent = current;
    m_progressTotal = total;
    m_progressPhase = phase;
    m_currentFile = currentFile;

    emit progressChanged();
}

void BatchProcessController::handleFinished() {
    const DuplicateSearchResult &result = m_duplicateFinder->result();

    m_duplicateGroupCount = result.groups.size();
    m_duplicateFileCount = result.duplicateFileCount();
    m_removableFileCount = result.removableFileCount();

    emit resultChanged();
}

void BatchProcessController::handleFailed(const QString &error) {
    setErrorMessage(error);
}

void BatchProcessController::handleCancelled() {
    setErrorMessage(tr("Operation cancelled"));
}

void BatchProcessController::setErrorMessage(const QString &message) {
    if (m_errorMessage == message)
        return;

    m_errorMessage = message;
    emit errorMessageChanged();
}

void BatchProcessController::resetResult() {
    m_progressCurrent = 0;
    m_progressTotal = 0;
    m_progressPhase.clear();
    m_currentFile.clear();

    m_duplicateGroupCount = 0;
    m_duplicateFileCount = 0;
    m_removableFileCount = 0;

    emit progressChanged();
    emit resultChanged();
}