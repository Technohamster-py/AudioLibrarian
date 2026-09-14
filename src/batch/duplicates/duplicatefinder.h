#pragma once

#include <batch/abstractbatchoperation.h>
#include "duplicatesearchresult.h"

#include <QRegularExpression>
#include <QSet>
#include <QVector>

#include <algorithm>

class DuplicateFinder final : public AbstractBatchOperation {
    Q_OBJECT

    Q_PROPERTY(int durationTolerance
                READ durationTolerance
                WRITE setDurationTolerance
                NOTIFY durationToleranceChanged)

public:
    explicit DuplicateFinder(QObject *parent = nullptr);

    BatchOperationResult execute(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested) override;

    void setSearchModes(const QSet<DuplicateSearchMode> &searchModes);
    QSet<DuplicateSearchMode> searchModes() const {return m_searchModes;};

    const DuplicateSearchResult &result() const;

    int durationTolerance() const {return m_durationTolerance;}
    void setDurationTolerance(int durationTolerance);

signals:
    void durationToleranceChanged();

protected:
    BatchOperationResult findByContent(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested, DuplicateSearchResult &result);
    BatchOperationResult findByMetadata(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested, DuplicateSearchResult &result);
    BatchOperationResult findByFileName(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested, DuplicateSearchResult &result);
private:
    static QByteArray calculateHash(const QString &filePath, const std::atomic_bool &cancellationRequested);

    static QString metadataKey(const AudioFileRecord &record);
    static QString normalizeMetadataValue(const QString &value);

    int m_durationTolerance = 2;
    QSet<DuplicateSearchMode> m_searchModes;

    DuplicateSearchResult m_result;
};
