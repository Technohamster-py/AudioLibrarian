#pragma once

#include "audiometadata.h"

#include <QString>

namespace MetadataUtils {
    QString formatDuration(int seconds);
    QString extractYear(const QString &date);
    bool hasLyrics(const AudioMetadata &metadata);
}