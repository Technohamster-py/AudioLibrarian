#include "duplicatefinder.h"

#include <QCryptographicHash>
#include <QFile>
#include <QFileInfo>
#include <QHash>

namespace {
    constexpr qint64 HashChunkSize = 1024 * 1024;
}

/**
 * @brief Creates SHA-256 hash for the complete file contents.
 */
QByteArray DuplicateFinder::calculateHash(const QString &filePath, const std::atomic_bool &cancellationRequested) {
    QFile file(filePath);

    if (!file.open(QIODevice::ReadOnly))
        return {};

    QCryptographicHash hash(QCryptographicHash::Sha256);

    while (!file.atEnd()) {
        if (cancellationRequested.load(std::memory_order_relaxed))
            return {};

        const QByteArray chunk = file.read(HashChunkSize);

        if (chunk.isEmpty() && !file.atEnd())
            return {};

        hash.addData(chunk);
    }

    return hash.result();
}

DuplicateFinder::DuplicateFinder(QObject *parent) : AbstractBatchOperation(parent) {
}

BatchOperationResult DuplicateFinder::execute(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested) {
    m_result = {};

    QHash<qint64, QVector<AudioFileRecord> > filesBySize;

    for (const AudioFileRecord &record: files) {
        if (cancellationRequested.load(std::memory_order_relaxed))
            return {.success = false, .canceled = true};

        const QFileInfo fileInfo(record.filePath);

        if (!fileInfo.exists() || !fileInfo.isFile())
            continue;

        filesBySize[fileInfo.size()].append(record);
    }

    qsizetype candidates = 0;

    for (auto it = filesBySize.cbegin(); it != filesBySize.cend(); ++it) {
        if (it.value().size() > 1)
            candidates += it.value().size();
    }

    qsizetype processed = 0;

    reportProgress(0, candidates, QStringLiteral("Hashing"), {});

    for (const auto &records: filesBySize) {
        if (records.size() < 2)
            continue;

        QHash<QByteArray, DuplicateGroup> groupsByHash;

        for (const AudioFileRecord &record: records) {
            if (cancellationRequested.load(std::memory_order_relaxed))
                return {.success = false, .canceled = true};

            const QFileInfo fileInfo(record.filePath);

            const QByteArray hash = calculateHash(record.filePath, cancellationRequested);

            if (hash.isEmpty()) {
                if (cancellationRequested.load(std::memory_order_relaxed)) {
                    return {.success = false, .canceled = true};
                }

                ++processed;

                reportProgress(processed, candidates, QStringLiteral("Hashing"), record.filePath);

                continue;
            }

            DuplicateFile duplicateFile;
            duplicateFile.filePath = record.filePath;
            duplicateFile.fileSize = fileInfo.size();
            duplicateFile.hash = hash;
            duplicateFile.record = record;

            groupsByHash[hash].files.append(std::move(duplicateFile));

            ++processed;

            reportProgress(processed, candidates,QStringLiteral("Hashing"), record.filePath);
        }

        for (auto it = groupsByHash.cbegin(); it != groupsByHash.cend(); ++it) {
            if (it.value().files.size() > 1)
                m_result.groups.append(it.value());
        }
    }

    return {.success = true, .canceled = false};
}

const DuplicateSearchResult &DuplicateFinder::result() const {
    return m_result;
}
