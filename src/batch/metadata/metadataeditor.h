#pragma once

#include "batch/abstractbatchoperation.h"

#include <QString>
#include <QStringList>

struct MetadataChange {
    QString key;
    QStringList values;
    bool remove = false;
};

struct MetadataEditFileResult {
    QString filePath;
    bool success = false;
    QString errorMessage;
};

class MetadataEditor : public AbstractBatchOperation {
    Q_OBJECT

public:
    explicit MetadataEditor(QObject *parent = nullptr);

    void setChanges(const QVector<MetadataChange> &changes);

    BatchOperationResult execute(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested) override;

    const QVector<MetadataEditFileResult> &result() const {return m_results;};

private:
    QVector<MetadataChange> m_changes;

    QVector<MetadataEditFileResult> m_results;
};


