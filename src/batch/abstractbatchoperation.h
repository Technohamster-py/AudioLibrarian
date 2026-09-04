#pragma once

#include "library/audiofilerecord.h"

#include <QObject>
#include <QString>
#include <QVector>

#include <atomic>

struct BatchOperationResult {
    bool success;
    bool canceled;
    QString errorMessage;
};

/**
 * @brief Base class for operations executed by BatchProcessor.
 *
 * A batch operation contains the actual processing logic. It does not own
 * the input files and does not control the lifetime of the processor.
 */

class AbstractBatchOperation : public QObject {
    Q_OBJECT

public:
    explicit AbstractBatchOperation(QObject *parent = nullptr);
    ~AbstractBatchOperation() override = default;

    /**
     * @brief Executes the operation.
     *
     * @param files Input files.
     * @param cancellationRequested Shared cancellation flag.
     * @return Operation result.
     */
    virtual BatchOperationResult execute(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested) = 0;

signals:
    void progressChanged(qsizetype current, qsizetype total, const QString &phase, const QString &currentFile);

protected:
    void reportProgress(qsizetype current, qsizetype total, const QString &phase, const QString &currentFile);
};