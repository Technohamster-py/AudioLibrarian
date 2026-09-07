#include "duplicatefindercontroller.h"

DuplicateFinderController::DuplicateFinderController(QObject *parent)
    : QObject(parent),
      m_processor(this),
      m_duplicateFinder(new DuplicateFinder)
{
    connect(
        &m_processor,
        &BatchProcessor::progressChanged,
        this,
        &DuplicateFinderController::handleProgress
    );

    connect(
        &m_processor,
        &BatchProcessor::finished,
        this,
        [this]() {
            const auto &result = m_duplicateFinder->result();

            m_duplicateGroupCount = result.groups.size();
            m_duplicateFileCount = result.duplicateFileCount();
            m_removableFileCount = result.removableFileCount();

            emit resultChanged();

            setRunning(false);
        }
    );

    connect(
        &m_processor,
        &BatchProcessor::failed,
        this,
        [this](const QString &error) {
            setErrorMessage(error);
            setRunning(false);
        }
    );

    connect(
        &m_processor,
        &BatchProcessor::cancelled,
        this,
        [this]() {
            setRunning(false);
        }
    );
}

bool DuplicateFinderController::start(
    const QString &basePath,
    bool searchByHash,
    bool searchByMetadata,
    bool searchByFileName,
    int durationTolerance
) {
    if (m_running)
        return false;

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

    setErrorMessage({});
    resetResult();

    const QVector<AudioFileRecord> files = m_scanner.scan(basePath);

    if (files.isEmpty()) {
        setErrorMessage(tr("No audio files found in the selected directory"));
        return false;
    }

    m_duplicateFinder->setSearchModes(searchModes);
    m_duplicateFinder->setDurationTolerance(durationTolerance);

    if (!m_processor.start(m_duplicateFinder, files)) {
        setErrorMessage(tr("Unable to start duplicate search"));
        return false;
    }

    setRunning(true);

    return true;
}

void DuplicateFinderController::cancel() {
    m_processor.cancel();
}

void DuplicateFinderController::setRunning(const bool running) {
    if (m_running == running)
        return;

    m_running = running;
    emit runningChanged();
}

void DuplicateFinderController::setErrorMessage(const QString &message) {
    if (m_errorMessage == message)
        return;

    m_errorMessage = message;
    emit errorMessageChanged();
}

void DuplicateFinderController::resetResult() {
    m_progressCurrent = 0;
    m_progressTotal = 0;
    m_phase.clear();
    m_currentFile.clear();

    m_duplicateGroupCount = 0;
    m_duplicateFileCount = 0;
    m_removableFileCount = 0;

    emit progressChanged();
    emit resultChanged();
}

void DuplicateFinderController::handleProgress(
    const qsizetype current,
    const qsizetype total,
    const QString &phase,
    const QString &currentFile
) {
    m_progressCurrent = current;
    m_progressTotal = total;
    m_phase = phase;
    m_currentFile = currentFile;

    emit progressChanged();
}