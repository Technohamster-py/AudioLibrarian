#pragma once

#include <batch/abstractbatchoperation.h>
#include "duplicatesearchresult.h"

#include <QVector>
#include <QSet>

class DuplicateFinder final : public AbstractBatchOperation {
    Q_OBJECT

public:
    explicit DuplicateFinder(QObject *parent = nullptr);

    BatchOperationResult execute(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested) override;

    void setSearchModes(const QSet<DuplicateSearchMode> &searchModes);
    QSet<DuplicateSearchMode> searchModes() const {return m_searchModes;};

    const DuplicateSearchResult &result() const;

protected:
    BatchOperationResult findByContent(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested, DuplicateSearchResult &result);
    BatchOperationResult findByMetadata(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested, DuplicateSearchResult &result);
    BatchOperationResult findByFileName(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested, DuplicateSearchResult &result);

private:
    static QByteArray calculateHash(const QString &filePath, const std::atomic_bool &cancellationRequested);

    static QString metadataKey(const AudioFileRecord &record);
    static QString normalizeMetadataValue(const QString &value);

    QSet<DuplicateSearchMode> m_searchModes;

    DuplicateSearchResult m_result;
};
