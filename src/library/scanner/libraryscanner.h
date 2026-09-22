#pragma once

#include "library/audiofilerecord.h"

#include <QVector>
#include <QString>

#include <optional>
#include <functional>
#include <QSet>

struct LibraryScanProgress {
    qsizetype current = 0;
    qsizetype total = 0;
    QString currentFile;
};

using LibraryScannerCallback = std::function<void(const LibraryScanProgress &)>;

class LibraryScanner {
public:
    QVector<AudioFileRecord> scan(const QString &path, const LibraryScannerCallback &progress = {}) const;

    std::optional<AudioFileRecord> readFile(const QString &filePath) const;

    static bool isAudioFile(const QString &filePath);

private:
    inline static const QSet<QString> m_musicFileSuffixes{
        "mp3",
        "flac",
        "ogg",
        "oga",
        "wav",
        "m4a",
        "aac",
        "opus",
        "wma",
        "aiff",
        "aif",
    };
};
