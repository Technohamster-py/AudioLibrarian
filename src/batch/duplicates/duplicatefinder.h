#pragma once

#include <batch/abstractbatchoperation.h>
#include "duplicatesearchresult.h"

#include <QVector>

class DuplicateFinder final : public AbstractBatchOperation {
    Q_OBJECT

public:
    explicit DuplicateFinder(QObject *parent = nullptr);

    BatchOperationResult execute(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested) override;

    const DuplicateSearchResult &result() const;

private:
    static QByteArray calculateHash(const QString &filePath, const std::atomic_bool &cancellationRequested);

    DuplicateSearchResult m_result;
};
