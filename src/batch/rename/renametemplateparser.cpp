#include "renametemplateparser.h"

RenameTemplateParser::Result RenameTemplateParser::parse(const QString &pattern)
{
    Result result;

    if (pattern.isEmpty()) {
        result.errorMessage = QStringLiteral("Template cannot be empty");
        return result;
    }

    QString literal;

    const auto appendLiteral = [&result, &literal]() {
        if (literal.isEmpty())
            return;

        Token token;
        token.type = Token::Type::Literal;
        token.value = std::move(literal);

        result.tokens.append(std::move(token));
        literal.clear();
    };

    for (qsizetype index = 0; index < pattern.size(); ++index) {
        const QChar character = pattern.at(index);

        if (character == u'}') {
            result.errorMessage = QStringLiteral(
                "Unexpected closing brace at position %1"
            ).arg(index);

            return result;
        }

        if (character != u'{') {
            literal.append(character);
            continue;
        }

        appendLiteral();

        const qsizetype closingBrace = pattern.indexOf(u'}', index + 1);

        if (closingBrace < 0) {
            result.errorMessage = QStringLiteral(
                "Missing closing brace for field at position %1"
            ).arg(index);

            return result;
        }

        const QString name = pattern.sliced(
            index + 1,
            closingBrace - index - 1
        );

        if (name.isEmpty()) {
            result.errorMessage = QStringLiteral(
                "Empty field at position %1"
            ).arg(index);

            return result;
        }

        Field field;

        if (!parseField(name, field)) {
            result.errorMessage = QStringLiteral(
                "Unknown field '%1'"
            ).arg(name);

            return result;
        }

        Token token;
        token.type = Token::Type::Field;
        token.field = field;

        result.tokens.append(std::move(token));

        index = closingBrace;
    }

    appendLiteral();

    result.valid = true;
    return result;
}

bool RenameTemplateParser::parseField(
    const QString &name,
    Field &field
)
{
    const QString normalizedName = name.toUpper();

    static const QVector<std::pair<QString, Field>> fields{
        {QStringLiteral("TITLE"), Field::Title},
        {QStringLiteral("ARTIST"), Field::Artist},
        {QStringLiteral("ALBUM"), Field::Album},
        {QStringLiteral("ALBUMARTIST"), Field::AlbumArtist},
        {QStringLiteral("GENRE"), Field::Genre},
        {QStringLiteral("DATE"), Field::Date},
        {QStringLiteral("TRACKNUMBER"), Field::TrackNumber},
        {QStringLiteral("DISCNUMBER"), Field::DiscNumber},
        {QStringLiteral("FILENAME"), Field::FileName}
    };

    for (const auto &[fieldNameValue, fieldValue] : fields) {
        if (normalizedName == fieldNameValue) {
            field = fieldValue;
            return true;
        }
    }

    return false;
}
