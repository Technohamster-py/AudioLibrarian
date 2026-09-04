#include "libraryscanner.h"

#include <QDirIterator>
#include <QFileInfo>
#include <algorithm>

QVector<AudioFileRecord> LibraryScanner::scan(const QString &path) const {
    QVector<AudioFileRecord> result;

    if (path.isEmpty())
        return result;

    const QFileInfo rootInfo(path);

    if (!rootInfo.exists() || !rootInfo.isDir())
        return result;

    QDirIterator iterator(path, QDir::Files | QDir::Readable, QDirIterator::Subdirectories);

    while (iterator.hasNext()) {
        const QString filePath = iterator.next();
        const auto record = readFile(filePath);

        if (!record) continue;

        result.append(*record);
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

