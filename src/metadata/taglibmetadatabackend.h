#pragma once

#include "audiometadata.h"

#include <QString>
#include <optional>
#include <taglib/tpropertymap.h>

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
    [[nodiscard]] std::optional<AudioMetadata> read(const QString &filePath, QString *errorMessage=nullptr) const;
    [[nodiscard]] bool write(const QString &filePath, const AudioMetadata &metadata, QString *errorMessage=nullptr) const;
private:
    [[nodiscard]] static AudioMetadata fromTagLib(const TagLib::PropertyMap &properties);
    [[nodiscard]] static TagLib::PropertyMap toTagLib(const AudioMetadata &metadata);

    static void setError(QString *destination, const QString &message);
};