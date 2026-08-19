#pragma once

#include <QMap>
#include <QString>
#include <QStringList>

/**
 * @brief Format-independent representation of audio metadata.
 *
 * AudioMetadata deliberately does not depend on TagLib or any particular
 * metadata format. It stores metadata as a case-insensitive set of textual
 * properties, where every property can contain multiple values.
 *
 * Standard fields such as TITLE, ARTIST and ALBUM are exposed through
 * convenience accessors, while arbitrary properties remain available through
 * the generic property interface.
 */
class AudioMetadata {
public:
    using Properties = QMap<QString, QStringList>;

    [[nodiscard]] const Properties &properties() const;

    [[nodiscard]] QStringList values(const QString &key) const;
    [[nodiscard]] QString value(const QString &key) const;


    void setValues(const QString &key, const QStringList &values);
    void setValue(const QString &key, const QString &value);

    void remove(const QString &key);

    [[nodiscard]] bool contains(const QString &key) const;

    [[nodiscard]] bool isEmpty() const;

    [[nodiscard]] QString title() const;
    void setTitle(const QString &value);

    [[nodiscard]] QString artist() const;
    void setArtist(const QString &value);

    [[nodiscard]] QString album() const;
    void setAlbum(const QString &value);

    [[nodiscard]] QString albumArtist() const;
    void setAlbumArtist(const QString &value);

    [[nodiscard]] QString genre() const;
    void setGenre(const QString &value);

    [[nodiscard]] QString comment() const;
    void setComment(const QString &value);

    [[nodiscard]] QString date() const;
    void setDate(const QString &value);

    [[nodiscard]] QString trackNumber() const;
    void setTrackNumber(const QString &value);

    [[nodiscard]] QString discNumber() const;
    void setDiscNumber(const QString &value);

private:

    [[nodiscard]] static QString normalizeKey(const QString &key);

    Properties m_properties; ///< Stored metadata properties.
};