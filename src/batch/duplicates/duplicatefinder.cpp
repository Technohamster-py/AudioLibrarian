#include "duplicatefinder.h"

#include <QCryptographicHash>
#include <QFile>
#include <QFileInfo>
#include <QHash>
#include <QRect>

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

QString DuplicateFinder::metadataKey(const AudioFileRecord &record) {
    QStringList artists;

    for (const QString &artist : record.fileInfo.metadata.values(QStringLiteral("Artist"))) {
        const QString normalizedArtist = normalizeMetadataValue(artist);

        if (!normalizedArtist.isEmpty())
            artists.append(normalizedArtist);
    }

    std::sort(artists.begin(), artists.end());

    const QString title = normalizeMetadataValue(record.fileInfo.metadata.value(QStringLiteral("TITLE")));

    if (artists.isEmpty() || title.isEmpty()) return {};

    return artists.join(QStringLiteral("\x1F")) + QStringLiteral("\x1E") + title;
}

QString DuplicateFinder::normalizeMetadataValue(const QString &value) {
    QRegularExpression re(QRegularExpression("\\s+"));
    return value.normalized(QString::NormalizationForm_C).toCaseFolded().split(re, Qt::SkipEmptyParts).join(QChar(' ')).trimmed();
}

DuplicateFinder::DuplicateFinder(QObject *parent) : AbstractBatchOperation(parent) {
}

BatchOperationResult DuplicateFinder::execute(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested) {
    m_result = {};

    return findByContent(files, cancellationRequested, m_result);
}

const DuplicateSearchResult &DuplicateFinder::result() const {
    return m_result;
}

/**
 * @brief Searches for byte-identical files using file size and SHA-256.
 */
BatchOperationResult DuplicateFinder::findByContent(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested, DuplicateSearchResult &result) {
    QHash<qint64, QVector<AudioFileRecord>> filesBySize;

    for (const AudioFileRecord &record : files) {
        if (cancellationRequested.load(std::memory_order_relaxed))
            return {.state = BatchOperationState::Cancelled};

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

    reportProgress(
        0,
        candidates,
        QStringLiteral("Hashing"),
        {}
    );

    for (const auto &records : filesBySize) {
        if (records.size() < 2)
            continue;

        QHash<QByteArray, DuplicateGroup> groupsByHash;

        for (const AudioFileRecord &record : records) {
            if (cancellationRequested.load(std::memory_order_relaxed))
                return {.state = BatchOperationState::Cancelled};

            const QFileInfo fileInfo(record.filePath);

            const QByteArray hash = calculateHash(
                record.filePath,
                cancellationRequested
            );

            if (hash.isEmpty()) {
                if (cancellationRequested.load(std::memory_order_relaxed))
                    return {.state = BatchOperationState::Cancelled};

                ++processed;

                reportProgress(processed, candidates, QStringLiteral("Hashing"), record.filePath);

                continue;
            }

            auto &group = groupsByHash[hash];
            if (group.files.isEmpty())
                group.mode = DuplicateSearchMode::Content;

            DuplicateFile duplicateFile;
            duplicateFile.filePath = record.filePath;
            duplicateFile.fileSize = fileInfo.size();
            duplicateFile.hash = hash;
            duplicateFile.record = record;

            group.files.append(std::move(duplicateFile));

            ++processed;

            reportProgress(processed, candidates, QStringLiteral("Hashing"), record.filePath);
        }

        for (auto it = groupsByHash.cbegin(); it != groupsByHash.cend(); ++it) {
            if (it.value().files.size() > 1)
                result.groups.append(it.value());
        }
    }

    return {.state = BatchOperationState::Success};
}

BatchOperationResult DuplicateFinder::findByMetadata(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested, DuplicateSearchResult &result) {
    constexpr int DurationTolerance = 2;

    QHash<QString, QVector<AudioFileRecord>> filesByMetadata;

    for (const AudioFileRecord &record : files) {
        if (cancellationRequested.load(std::memory_order_relaxed))
            return {.state = BatchOperationState::Cancelled};

        const QString key = metadataKey(record);

        if (key.isEmpty()) continue;

        filesByMetadata[key].append(record);
    }

    qsizetype candidates = 0;

    for (auto it = filesByMetadata.cbegin(); it != filesByMetadata.cend(); ++it) {
        if (it.value().size() > 1)
            candidates += it.value().size();
    }

    qsizetype processed = 0;

    reportProgress(0, candidates, QStringLiteral("Comparing metadata"), {});

    for (const auto &records : filesByMetadata) {
        if (records.size() < 2)
            continue;

        QVector<AudioFileRecord> sortedRecords = records;
        std::sort(sortedRecords.begin(), sortedRecords.end(), [](const AudioFileRecord &left, const AudioFileRecord &right) {
            return left.fileInfo.durationSeconds < right.fileInfo.durationSeconds;
        });

        DuplicateGroup currentGroup;
        currentGroup.mode = DuplicateSearchMode::Metadata;

        int groupStartDuration = 0;

        for (const AudioFileRecord &record : sortedRecords) {
            if (cancellationRequested.load(std::memory_order_relaxed))
                return {.state = BatchOperationState::Cancelled};

            const int duration = record.fileInfo.durationSeconds;

            if (currentGroup.files.isEmpty()) {
                groupStartDuration = duration;
            } else if (duration - groupStartDuration > DurationTolerance) {
                if (currentGroup.files.size() > 1)
                    result.groups.append(std::move(currentGroup));

                currentGroup = {};
                currentGroup.mode = DuplicateSearchMode::Metadata;
                groupStartDuration = duration;
            }

            DuplicateFile duplicateFile;
            duplicateFile.filePath = record.filePath;
            duplicateFile.fileSize = QFileInfo(record.filePath).size();
            duplicateFile.record = record;

            currentGroup.files.append(std::move(duplicateFile));

            ++processed;

            reportProgress(processed, candidates, QStringLiteral("Comparing Metadata"), record.filePath);
        }

        if (currentGroup.files.size() > 1)
            result.groups.append(std::move(currentGroup));
    }
    return {.state = BatchOperationState::Success};
}

BatchOperationResult DuplicateFinder::findByFileName(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested, DuplicateSearchResult &result) {
}
