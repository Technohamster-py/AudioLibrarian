#include "taglibmetadatabackend.h"

#include <taglib/fileref.h>
#include <taglib/tstring.h>

/**
 * @brief Stores an error message when the caller supplied a destination.
 *
 * @param destination Error destination.
 * @param message Error text.
*/
void TagLibMetadataBackend::setError(QString *destination, const QString &message) {
    if (destination)
        *destination = message;
}

/**
 * @brief Converts a TagLib PropertyMap to AudioMetadata.
 *
 * @param properties TagLib properties.
 * @return Format-independent metadata representation.
*/
AudioMetadata TagLibMetadataBackend::fromTagLib(const TagLib::PropertyMap &properties) {
    AudioMetadata metadata;

    /*
     * TagLib::PropertyMap stores Unicode strings. Using to8Bit(true)
     * explicitly requests UTF-8 conversion before constructing QString.
     */
    for (const auto &property: properties) {
        const QString key = QString::fromUtf8(property.first.to8Bit(true).c_str());

        QStringList values;

        for (const auto &tagValue: property.second) {
            values.append(QString::fromUtf8(tagValue.to8Bit(true).c_str()));
        }

        metadata.setValues(key, values);
    }

    return metadata;
}

/**
 * @brief Converts AudioMetadata to a TagLib PropertyMap.
 *
 * @param metadata Format-independent metadata representation.
 * @return TagLib property map.
*/
TagLib::PropertyMap TagLibMetadataBackend::toTagLib(
    const AudioMetadata &metadata
) {
    TagLib::PropertyMap properties;

    for (auto iterator = metadata.properties().cbegin(); iterator != metadata.properties().cend(); ++iterator) {
        const TagLib::String key(iterator.key().toUtf8().constData(), TagLib::String::UTF8);

        TagLib::StringList values;

        for (const QString &value: iterator.value()) {
            values.append(TagLib::String(value.toUtf8().constData(), TagLib::String::UTF8));
        }

        properties.insert(key, values);
    }

    return properties;
}

/**
 * @brief Reads metadata from an audio file.
 *
 * TagLib automatically selects the appropriate file implementation based
 * on the file contents/extension and exposes textual metadata through its
 * unified PropertyMap interface.
 *
 * @param filePath Path to the audio file.
 * @param errorMessage Optional destination for a human-readable error.
 * @return Metadata on success, std::nullopt on failure.
 */
std::optional<AudioMetadata> TagLibMetadataBackend::read(const QString &filePath, QString *errorMessage) const {
    if (filePath.isEmpty()) {
        setError(errorMessage,QStringLiteral("Audio file path is empty."));
        return std::nullopt;
    }

    /*
     * FileRef is TagLib's format-independent file abstraction.
     *
     * Fast is sufficient here because this backend is responsible for
     * metadata, not for calculating precise audio duration.
     */
    const QByteArray encodedPath = filePath.toUtf8();

    TagLib::FileRef file(encodedPath.constData(), true, TagLib::AudioProperties::Fast);

    if (file.isNull()) {
        setError(errorMessage,QStringLiteral("Unable to open audio file: %1").arg(filePath));
        return std::nullopt;
    }

    return fromTagLib(file.properties());
}

/**
 * @brief Writes metadata to an audio file.
 *
 * The existing metadata is replaced by the supplied metadata. TagLib
 * performs the format-specific conversion internally.
 *
 * @param filePath Path to the audio file.
 * @param metadata Metadata to write.
 * @param errorMessage Optional destination for a human-readable error.
 * @return true when the metadata was successfully written.
 */
bool TagLibMetadataBackend::write(const QString &filePath, const AudioMetadata &metadata, QString *errorMessage) const {
    if (filePath.isEmpty()) {
        setError(errorMessage, QStringLiteral("Audio file path is empty."));
        return false;
    }

    const QByteArray encodedPath = filePath.toUtf8();

    TagLib::FileRef file(encodedPath.constData(), true, TagLib::AudioProperties::Fast);

    if (file.isNull()) {
        setError(errorMessage,QStringLiteral("Unable to open audio file: %1").arg(filePath));
        return false;
    }

    /*
     * TagLib::FileRef::setProperties() returns properties which could not be
     * written for the target format. An empty map means that all requested
     * properties were accepted.
     */
    const TagLib::PropertyMap rejectedProperties = file.setProperties(toTagLib(metadata));

    if (!rejectedProperties.isEmpty()) {
        setError(errorMessage, QStringLiteral("Some metadata properties could not be written to: %1").arg(filePath));
        return false;
    }

    if (!file.save()) {
        setError(errorMessage,QStringLiteral("Unable to save audio file: %1").arg(filePath));
        return false;
    }

    return true;
}
