#include "libraryscanner.h"

#include <QDirIterator>
#include <QFileInfo>
#include <algorithm>

QVector<AudioFileRecord> LibraryScanner::scan(const QString &path, const LibraryScannerCallback &progress) const {
    QVector<AudioFileRecord> result;

    if (path.isEmpty())
        return result;

    const QFileInfo rootInfo(path);

    if (!rootInfo.exists() || !rootInfo.isDir())
        return result;

    QStringList files;

    QDirIterator iterator(path, QDir::Files | QDir::Readable, QDirIterator::Subdirectories);

    while (iterator.hasNext()) {
        const QString filePath = iterator.next();

        if (isAudioFile(filePath))
            files.append(filePath);
    }

    const qsizetype total = files.size();
    qsizetype current = 0;

    if (progress)
        progress({current, total, {}});

    result.reserve(total);

    for (const QString &filePath : std::as_const(files)) {
        if (progress)
            progress({current, total, filePath});

        const auto record = readFile(filePath);

        if (record)
            result.append(*record);

        ++current;

        if (progress)
            progress({current, total, {}});
    }

    std::sort(result.begin(), result.end(), [](const AudioFileRecord &left, const AudioFileRecord &right) {
        return QString::compare(left.filePath, right.filePath, Qt::CaseInsensitive) < 0;
    });

    return result;
}

std::optional<AudioFileRecord> LibraryScanner::readFile(const QString &filePath) const {
    if (filePath.isEmpty() || !isAudioFile(filePath))
        return std::nullopt;

    TagLibMetadataBackend backend;
    const auto fileInfo = backend.readFile(filePath);

    if (!fileInfo)
        return std::nullopt;

    AudioFileRecord record;
    record.filePath = QFileInfo(filePath).absoluteFilePath();
    record.fileInfo = *fileInfo;

    return record;
}

bool LibraryScanner::isAudioFile(const QString &filePath) {
    const QString suffix = QFileInfo(filePath).suffix().toLower();

    return m_musicFileSuffixes.contains(suffix);
}

