#pragma once

#include <QString>
#include <QVector>

/**
 * @brief Parses file rename templates into literal and metadata tokens.
 *
 * Supported fields are enclosed in braces, for example:
 * {ARTIST}/{ALBUM}/{TRACKNUMBER}_{TITLE}
 *
 * The parser does not expand metadata values or validate filesystem paths.
 */
class RenameTemplateParser
{
public:
    /**
     * @brief Metadata fields supported by rename templates.
     */
    enum class Field {
        Title,
        Artist,
        Album,
        AlbumArtist,
        Genre,
        Date,
        TrackNumber,
        DiscNumber,
        FileName
    };

    /**
     * @brief Represents one parsed part of a template.
     */
    struct Token {
        enum class Type {
            Literal,
            Field
        };

        Type type = Type::Literal;
        QString value;
        Field field = Field::Title;
    };

    /**
     * @brief Result of template parsing.
     */
    struct Result {
        bool valid = false;
        QString errorMessage;
        QVector<Token> tokens;
    };

    /**
     * @brief Parses a rename template.
     *
     * @param pattern Template to parse.
     * @return Parsed template or an error.
     */
    [[nodiscard]] static Result parse(const QString &pattern);

private:
    /**
     * @brief Converts a textual field name to a supported metadata field.
     *
     * @param name Field name without braces.
     * @param field Destination field.
     * @return true when the field name is supported.
     */
    [[nodiscard]] static bool parseField(const QString &name, Field &field);
};
