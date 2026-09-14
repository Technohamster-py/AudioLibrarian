#include "batchprocesscontroller.h"

BatchProcessController::BatchProcessController(QObject *parent): QObject(parent) {
    connect(&m_processor, &BatchProcessor::stateChanged, this, &BatchProcessController::runningChanged);
    connect(&m_processor, &BatchProcessor::progressChanged, this, &BatchProcessController::handleProgress);
    connect(&m_processor, &BatchProcessor::failed, this, &BatchProcessController::handleFailed);
    connect(&m_processor, &BatchProcessor::cancelled, this, &BatchProcessController::handleCancelled);
}

bool BatchProcessController::startOperation(const QSharedPointer<AbstractBatchOperation> &operation, const QVector<AudioFileRecord> &files) {
    if (m_processor.isRunning())
        return false;

    clearError();

    if (!m_processor.start(operation, files)) {
        setErrorMessage(tr("Failed to start operation"));
        return false;
    }
    return true;
}

void BatchProcessController::cancel() {
    m_processor.cancel();
}

void BatchProcessController::clearError() {
    setErrorMessage({});
}

void BatchProcessController::handleProgress(const qsizetype current, const qsizetype total, const QString &phase, const QString &currentFile) {
    m_progressCurrent = current;
    m_progressTotal = total;
    m_progressPhase = phase;
    m_currentFile = currentFile;

    emit progressChanged();
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