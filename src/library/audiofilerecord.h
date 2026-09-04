#pragma once

#include "metadata/taglibmetadatabackend.h"

/**
 * @brief Represents one scanned audio file.
 *
 * Contains the filesystem path and all information extracted from
 * the audio file metadata backend.
 */
struct AudioFileRecord {
    QString filePath; ///< Absolute path to the audio file.
    AudioFileInfo fileInfo; ///< Metadata and technical file information.
};
