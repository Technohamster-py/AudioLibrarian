#include "audiometadata.h"

/**
    * @brief Returns all metadata properties.
    *
    * @return Constant reference to the property map.
    */
const AudioMetadata::Properties &AudioMetadata::properties() const {
    return m_properties;
}

/**
 * @brief Returns all values associated with a property.
 *
 * Property names are treated case-insensitively.
 *
 * @param key Property name.
 * @return List of values. An empty list is returned when the property
 *         does not exist.
 */
QStringList AudioMetadata::values(const QString &key) const {
    return m_properties.value(normalizeKey(key));
}

/**
 * @brief Returns the first value associated with a property.
 *
 * @param key Property name.
 * @return First property value or an empty string if the property does
 *         not exist or has no values.
 */
QString AudioMetadata::value(const QString &key) const {
    const QStringList propertyValues = values(key);
    return propertyValues.isEmpty()? QString() : propertyValues.constFirst();
}

/**
 * @brief Replaces all values of a property.
 *
 * Passing an empty list removes the property.
 *
 * @param key Property name.
 * @param values New property values.
 */
void AudioMetadata::setValues(const QString &key, const QStringList &values) {
    const QString normalizedKey = normalizeKey(key);
    if (normalizedKey.isEmpty())
        return;
    /*
     * An empty value list represents an absent property.
     *
     * This mirrors the semantics of TagLib::PropertyMap, where removing the
     * values effectively removes the property.
     */
    if (values.isEmpty()) {
        m_properties.remove(normalizedKey);
        return;
    }
    m_properties.insert(normalizedKey, values);
}
/**
 * @brief Replaces a property with a single value.
 *
 * Passing an empty string removes the property.
 *
 * @param key Property name.
 * @param value New property value.
 */
void AudioMetadata::setValue(const QString &key, const QString &value) {
    if (value.isEmpty()) {
        remove(key);
        return;
    }

    setValues(key, {value});
}

/**
 * @brief Removes a property.
 *
 * @param key Property name.
 */
void AudioMetadata::remove(const QString &key) {
    m_properties.remove(normalizeKey(key));
}

/**
 * @brief Checks whether a property exists.
 *
 * @param key Property name.
 * @return true if the property exists.
 */
bool AudioMetadata::contains(const QString &key) const {
    return m_properties.contains(normalizeKey(key));
}

/**
 * @brief Checks whether no properties are stored.
 *
 * @return true if the metadata object is empty.
 */
bool AudioMetadata::isEmpty() const {
    return m_properties.isEmpty();
}

/**
 * @brief Returns the track title.
 *
 * @return TITLE property.
 */
QString AudioMetadata::title() const {
    return value(QStringLiteral("TITLE"));
}

/**
 * @brief Sets the track title.
 *
 * @param value New title.
 */
void AudioMetadata::setTitle(const QString &value) {
    setValue(QStringLiteral("TITLE"), value);
}

/**
 * @brief Returns the artist.
 *
 * @return ARTIST property.
 */
QString AudioMetadata::artist() const {
    return value(QStringLiteral("ARTIST"));
}

/**
 * @brief Sets the artist.
 *
 * @param value New artist.
 */
void AudioMetadata::setArtist(const QString &value) {
    setValue(QStringLiteral("ARTIST"), value);
}

/**
 * @brief Returns the album.
 *
 * @return ALBUM property.
 */
QString AudioMetadata::album() const {
    return value(QStringLiteral("ALBUM"));
}

/**
 * @brief Sets the album.
 *
 * @param value New album.
 */
void AudioMetadata::setAlbum(const QString &value) {
    setValue(QStringLiteral("ALBUM"), value);
}

/**
 * @brief Returns the album artist.
 *
 * @return ALBUMARTIST property.
 */
QString AudioMetadata::albumArtist() const {
    return value(QStringLiteral("ALBUMARTIST"));
}

/**
 * @brief Sets the album artist.
 *
 * @param value New album artist.
 */
void AudioMetadata::setAlbumArtist(const QString &value) {
    setValue(QStringLiteral("ALBUMARTIST"), value);
}

/**
 * @brief Returns the genre.
 *
 * @return GENRE property.
 */
QString AudioMetadata::genre() const {
    return value(QStringLiteral("GENRE"));
}

/**
 * @brief Sets the genre.
 *
 * @param value New genre.
 */
void AudioMetadata::setGenre(const QString &value) {
    setValue(QStringLiteral("GENRE"), value);
}

/**
 * @brief Returns the comment.
 *
 * @return COMMENT property.
 */
QString AudioMetadata::comment() const {
    return value(QStringLiteral("COMMENT"));
}


/**
 * @brief Sets the comment.
 *
 * @param value New comment.
 */
void AudioMetadata::setComment(const QString &value) {
    setValue(QStringLiteral("COMMENT"), value);
}

/**
 * @brief Returns the date.
 *
 * @return DATE property.
 */
QString AudioMetadata::date() const {
    return value(QStringLiteral("DATE"));
}

/**
 * @brief Sets the date.
 *
 * @param value New date.
 */
void AudioMetadata::setDate(const QString &value) {
    setValue(QStringLiteral("DATE"), value);
}

/**
 * @brief Returns the track number representation.
 *
 * The value deliberately remains a string because formats may represent
 * track numbers as values such as "3/12".
 *
 * @return TRACKNUMBER property.
 */
QString AudioMetadata::trackNumber() const {
    return value(QStringLiteral("TRACKNUMBER"));
}

/**
 * @brief Sets the track number representation.
 *
 * @param value Track number, optionally including the total count.
 */
void AudioMetadata::setTrackNumber(const QString &value) {
    setValue(QStringLiteral("TRACKNUMBER"), value);
}

/**
 * @brief Returns the disc number representation.
 *
 * @return DISCNUMBER property.
 */
QString AudioMetadata::discNumber() const {
    return value(QStringLiteral("DISCNUMBER"));
}

/**
 * @brief Sets the disc number representation.
 *
 * @param value Disc number, optionally including the total count.
 */
void AudioMetadata::setDiscNumber(const QString &value) {
    setValue(QStringLiteral("DISCNUMBER"), value);
}

/**
 * @brief Normalizes a property key.
 *
 * TagLib property names are case-insensitive. Keeping keys normalized
 * inside AudioMetadata prevents duplicate entries such as "artist" and
 * "ARTIST".
 *
 * @param key Property name.
 * @return Normalized property name.
 */
QString AudioMetadata::normalizeKey(const QString &key) {
    return key.trimmed().toUpper();
}