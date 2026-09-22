#pragma once

#include "abstractbatchoperation.h"
#include "batchprocessor.h"

#include <QObject>
#include <QSharedPointer>
#include <QString>

class BatchProcessController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(qsizetype progressCurrent READ progressCurrent NOTIFY progressChanged)
    Q_PROPERTY(qsizetype progressTotal READ progressTotal NOTIFY progressChanged)
    Q_PROPERTY(QString progressPhase READ progressPhase NOTIFY progressChanged)
    Q_PROPERTY(QString currentFile READ currentFile NOTIFY progressChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
    explicit BatchProcessController(QObject *parent = nullptr);
    ~BatchProcessController() override = default;

    bool running() const { return m_processor.isRunning(); }

    qsizetype progressCurrent() const { return m_progressCurrent; }
    qsizetype progressTotal() const { return m_progressTotal; }
    QString progressPhase() const { return m_progressPhase; }
    QString currentFile() const { return m_currentFile; }

    QString errorMessage() const { return m_errorMessage; }

    void cancel();

signals:
    void runningChanged();
    void progressChanged();
    void errorMessageChanged();

protected:
    bool startOperation(const QSharedPointer<AbstractBatchOperation> &operation, const QVector<AudioFileRecord> &files);
    BatchProcessor *processor() { return &m_processor; }
    void clearError();
    virtual void handleFinished() = 0;

private:
    void handleProgress(qsizetype current, qsizetype total, const QString &phase, const QString &currentFile);

    void handleFailed(const QString &error);
    void handleCancelled();

    void setErrorMessage(const QString &message);

    BatchProcessor m_processor;

    qsizetype m_progressCurrent = 0;
    qsizetype m_progressTotal = 0;
    QString m_progressPhase;
    QString m_currentFile;

    QString m_errorMessage;
};