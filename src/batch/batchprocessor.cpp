#include "batchprocessor.h"

#include  <QtConcurrent/QtConcurrentRun>

BatchProcessor::BatchProcessor(QObject *parent) {
    connect(&m_watcher, &QFutureWatcher<BatchOperationResult>::finished, this, &BatchProcessor::handleFinished);
}

BatchProcessor::~BatchProcessor() {
    m_cancellationRequested.store(true, std::memory_order_relaxed);

    if (m_watcher.isRunning())
        m_watcher.waitForFinished();
}

bool BatchProcessor::start(const QSharedDataPointer<AbstractBatchOperation> &operation, const QVector<AudioFileRecord> &files) {
    if (!operation || isRunning())
        return false;

    m_operation = operation;
    m_cancellationRequested.store(false, std::memory_order_relaxed);

    connect(m_operation.data(), &AbstractBatchOperation::progressChanged, this, &BatchProcessor::progressChanged, Qt::UniqueConnection);

    setState(State::Running);

    const QSharedPointer<AbstractBatchOperation> operationCopy = m_operation;
    const QVector<AudioFileRecord> filesCopy = files;

    m_watcher.setFuture(QtConcurrent::run([this, operationCopy, filesCopy]() {
            return operationCopy->execute(filesCopy, m_cancellationRequested);
        }
    ));

    return true;
}

void BatchProcessor::cancel() {
    if (!isRunning())
        return;

    if (m_state == State::Cancelled)
        return;

    m_cancellationRequested.store(true, std::memory_order_relaxed);

    setState(State::Cancelling);
}

bool BatchProcessor::isRunning() const {
    return m_state == State::Running || m_state == State::Cancelling;
}

void BatchProcessor::setState(State state) {
    if (m_state == state)
        return;

    m_state = state;
    emit stateChanged();
}

void BatchProcessor::handleFinished() {
    const BatchOperationResult result = m_watcher.result();

    if (result.canceled) {
        setState(State::Cancelled);
        emit cancelled();
    }else if (!result.success) {
        setState(State::Failed);
        emit failed(result.errorMessage);
    }else {
        setState(State::Finished);
        emit finished();
    }

    m_operation.clear();
}
