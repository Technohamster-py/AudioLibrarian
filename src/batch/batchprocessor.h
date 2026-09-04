#pragma once

#include "abstractbatchoperation.h"

#include <QObject>
#include <QFuture>
#include <QFutureWatcher>
#include <QString>
#include <QVector>

#include <atomic>

class BatchProcessor final : public QObject {
    Q_OBJECT

public:
    enum class State {
        Idle,
        Running,
        Cancelling,
        Finished,
        Failed,
        Cancelled
    };

    Q_ENUM(State)

    explicit BatchProcessor(QObject *parent = nullptr);
    ~BatchProcessor() override;

    bool start(const QSharedDataPointer<AbstractBatchOperation> &operation, const QVector<AudioFileRecord> &files);
    void cancel();

    State state() const {return m_state;};
    bool isRunning() const;

signals:
    void stateChanged();

    void progressChanged(qsizetype current, qsizetype total, const QString &phase, const QString &currentFile);

    void finished();
    void failed(const QString &error);
    void cancelled();

private:
    void setState(State state);

    State m_state = State::Idle;
    std::atomic_bool m_cancellationRequested = false;

    QFutureWatcher<BatchOperationResult> m_watcher;
    QSharedPointer<AbstractBatchOperation> m_operation;

private slots:
    void handleFinished();
};


