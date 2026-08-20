#pragma once

#include "audiometadata.h"

#include <QByteArray>
#include <QString>
#include <optional>
#include <taglib/tpropertymap.h>

/**
 * @brief Complete information extracted from an audio file.
 *
 * AudioFileInfo combines textual metadata with technical information and
 * binary embedded cover data.
 *
 * TagLib-specific types are deliberately not exposed outside the metadata
 * backend.
 */
struct AudioFileInfo {
    AudioMetadata metadata; ///< Format-independent textual metadata.
    int durationSeconds = 0; ///< Duration in whole seconds.
    QByteArray coverData; ///< Embedded cover image data, if available.
};

/**
 * @brief TagLib-based backend for reading and writing audio metadata.
 *
 * This class is the only component in the metadata layer that directly
 * depends on TagLib.
 *
 * AudioMetadata remains independent of TagLib and can therefore be used by
 * the rest of the application without exposing TagLib types.
 */
class TagLibMetadataBackend {
public:
    /**
     * @brief Reads complete information from an audio file.
     *
     * The operation reads textual metadata, audio duration and the first
     * embedded picture, if one exists.
     *
     * @param filePath Path to the audio file.
     * @param errorMessage Optional destination for a human-readable error.
     *
     * @return Extracted information on success, std::nullopt on failure.
     */
    [[nodiscard]] std::optional<AudioFileInfo> readFile(const QString &filePath, QString *errorMessage = nullptr) const;

    /**
     * @brief Reads textual metadata from an audio file.
     *
     * This method is kept as a convenience API for code that does not need
     * technical information or cover art.
     *
     * @param filePath Path to the audio file.
     * @param errorMessage Optional destination for a human-readable error.
     *
     * @return Metadata on success, std::nullopt on failure.
     */
    [[nodiscard]] std::optional<AudioMetadata> read(const QString &filePath, QString *errorMessage = nullptr) const;

    /**
     * @brief Writes metadata to an audio file.
     *
     * The existing textual metadata is replaced by the supplied metadata.
     *
     * @param filePath Path to the audio file.
     * @param metadata Metadata to write.
     * @param errorMessage Optional destination for a human-readable error.
     *
     * @return true when the metadata was successfully written.
     */
    [[nodiscard]] bool write(const QString &filePath, const AudioMetadata &metadata, QString *errorMessage = nullptr) const;

private:
    /**
     * @brief Converts a TagLib PropertyMap to AudioMetadata.
     *
     * @param properties TagLib properties.
     *
     * @return Format-independent metadata representation.
     */
    [[nodiscard]] static AudioMetadata fromTagLib(const TagLib::PropertyMap &properties);


    /**
     * @brief Converts AudioMetadata to a TagLib PropertyMap.
     *
     * @param metadata Format-independent metadata.
     *
     * @return TagLib property map.
     */
    [[nodiscard]] static TagLib::PropertyMap toTagLib(const AudioMetadata &metadata);

    /**
     * @brief Stores an error message when the caller supplied a destination.
     *
     * @param destination Error destination.
     * @param message Error text.
     */
    static void setError(QString *destination, const QString &message);
};
