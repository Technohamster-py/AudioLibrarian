#include "taglibmetadatabackend.h"

#include  <taglib/audioproperties.h>
#include <taglib/fileref.h>
#include <taglib/tbytevector.h>
#include <taglib/tvariant.h>
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
 *
 * @return Format-independent metadata representation.
 */
AudioMetadata TagLibMetadataBackend::fromTagLib(const TagLib::PropertyMap &properties) {
    AudioMetadata metadata;
    /*
     * TagLib::PropertyMap stores Unicode strings. Explicit UTF-8 conversion
     * prevents accidental dependence on the process locale.
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
 * @param metadata Format-independent metadata.
 *
 * @return TagLib property map.
 */
TagLib::PropertyMap TagLibMetadataBackend::toTagLib(const AudioMetadata &metadata) {
    TagLib::PropertyMap properties;
    for (auto iterator = metadata.properties().cbegin(); iterator != metadata.properties().cend(); ++iterator) {
        const TagLib::String key(iterator.key().toUtf8().constData(),TagLib::String::UTF8);
        TagLib::StringList values;

        for (const QString &value: iterator.value()) {
            values.append(TagLib::String(value.toUtf8().constData(), TagLib::String::UTF8));
        }
        properties.insert(key, values);
    }
    return properties;
}

/**
 * @brief Reads complete information from an audio file.
 *
 * FileRef provides a format-independent interface for metadata, audio
 * properties and complex properties such as embedded pictures.
 *
 * @param filePath Path to the audio file.
 * @param errorMessage Optional destination for an error message.
 *
 * @return Audio information on success, std::nullopt otherwise.
 */
std::optional<AudioFileInfo> TagLibMetadataBackend::readFile(const QString &filePath, QString *errorMessage) const {
    if (filePath.isEmpty()) {
        setError(errorMessage, QStringLiteral("Audio file path is empty."));
        return std::nullopt;
    }

    const QByteArray encodedPath = filePath.toUtf8();

    TagLib::FileRef file(encodedPath.constData(), true, TagLib::AudioProperties::Fast);

    if (file.isNull()) {
        setError(errorMessage,QStringLiteral("Unable to open audio file: %1").arg(filePath));
        return std::nullopt;
    }

    AudioFileInfo result;

    result.metadata = fromTagLib(file.properties());

    if (const TagLib::AudioProperties *properties = file.audioProperties())
        result.durationSeconds = properties->lengthInSeconds();

    const TagLib::List<TagLib::VariantMap> pictures = file.complexProperties(TagLib::String("PICTURE", TagLib::String::UTF8));

    if (!pictures.isEmpty()) {
        const TagLib::VariantMap &picture = pictures.front();
        const auto dataIterator = picture.find(TagLib::String("data", TagLib::String::UTF8));

        if (dataIterator != picture.end()) {
            const TagLib::ByteVector data = dataIterator->second.toByteVector();
            result.coverData = QByteArray(data.data(),static_cast<qsizetype>(data.size()));
        }
    }
    return result;
}

/**
 * @brief Reads textual metadata from an audio file.
 *
 * This method delegates to readFile() and returns only the metadata portion.
 *
 * @param filePath Path to the audio file.
 * @param errorMessage Optional destination for an error message.
 *
 * @return Metadata on success, std::nullopt otherwise.
 */
std::optional<AudioMetadata> TagLibMetadataBackend::read(const QString &filePath, QString *errorMessage) const {
    const auto result = readFile(filePath, errorMessage);
    if (!result)
        return std::nullopt;
    return result->metadata;
}

/**
 * @brief Writes metadata to an audio file.
 *
 * @param filePath Path to the audio file.
 * @param metadata Metadata to write.
 * @param errorMessage Optional destination for an error message.
 *
 * @return true when all metadata was accepted and the file was saved.
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

    const TagLib::PropertyMap rejectedProperties = file.setProperties(toTagLib(metadata));

    if (!rejectedProperties.isEmpty()) {
        setError(errorMessage, QStringLiteral("Some metadata properties could not be written to: %1").arg(filePath));
        return false;
    }

    if (!file.save()) {
        setError(errorMessage, QStringLiteral("Unable to save audio file: %1").arg(filePath));
        return false;
    }
    return true;
}
