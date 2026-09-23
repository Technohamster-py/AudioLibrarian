#pragma once

#include "abstractbatchoperation.h"
#include "renamefileresult.h"
#include "renametemplateparser.h"

class FileRenamer : public AbstractBatchOperation {
    Q_OBJECT

public:
    explicit FileRenamer(QObject* parent = nullptr);

    void setPattern(const QString& pattern);
    const QVector<RenameFileResult> &result() const;

    BatchOperationResult execute(const QVector<AudioFileRecord>& files, const std::atomic_bool &cancellationRequested) override;

private:
    QString m_pattern;
    QVector<RenameFileResult> m_results;
};