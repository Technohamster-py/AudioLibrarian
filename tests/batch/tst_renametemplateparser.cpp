#include <QtTest>

#include "../../src/batch/rename/renametemplateparser.h"

class RenameTemplateParserTest final : public QObject
{
    Q_OBJECT

private slots:
    /**
     * @brief Parses a template containing literal text and metadata fields.
     */
    void parsesTemplate();

    /**
     * @brief Parses all supported metadata fields.
     */
    void parsesAllFields();

    /**
     * @brief Rejects an empty template.
     */
    void rejectsEmptyTemplate();

    /**
     * @brief Rejects an unknown field.
     */
    void rejectsUnknownField();

    /**
     * @brief Rejects a field without a closing brace.
     */
    void rejectsUnclosedField();

    /**
     * @brief Rejects an unexpected closing brace.
     */
    void rejectsUnexpectedClosingBrace();

    /**
     * @brief Rejects an empty field.
     */
    void rejectsEmptyField();

    /**
     * @brief Accepts field names regardless of their letter case.
     */
    void acceptsCaseInsensitiveFields();
};

void RenameTemplateParserTest::parsesTemplate()
{
    const auto result = RenameTemplateParser::parse(
        QStringLiteral("{ARTIST}/{ALBUM}/{TRACKNUMBER}_{TITLE}")
    );

    QVERIFY(result.valid);
    QCOMPARE(result.errorMessage, QString());
    QCOMPARE(result.tokens.size(), 7);

    QCOMPARE(
        result.tokens.at(0).type,
        RenameTemplateParser::Token::Type::Field
    );
    QCOMPARE(
        result.tokens.at(0).field,
        RenameTemplateParser::Field::Artist
    );

    QCOMPARE(
        result.tokens.at(1).type,
        RenameTemplateParser::Token::Type::Literal
    );
    QCOMPARE(result.tokens.at(1).value, QStringLiteral("/"));

    QCOMPARE(
        result.tokens.at(2).field,
        RenameTemplateParser::Field::Album
    );

    QCOMPARE(result.tokens.at(3).value, QStringLiteral("/"));

    QCOMPARE(
        result.tokens.at(4).field,
        RenameTemplateParser::Field::TrackNumber
    );

    QCOMPARE(result.tokens.at(5).value, QStringLiteral("_"));

    QCOMPARE(
        result.tokens.at(6).field,
        RenameTemplateParser::Field::Title
    );
}

void RenameTemplateParserTest::parsesAllFields()
{
    const auto result = RenameTemplateParser::parse(
        QStringLiteral(
            "{TITLE}/{ARTIST}/{ALBUM}/{ALBUMARTIST}/{GENRE}/"
            "{DATE}/{TRACKNUMBER}/{DISCNUMBER}/{FILENAME}"
        )
    );

    QVERIFY(result.valid);
    QCOMPARE(result.tokens.size(), 17);

    const QVector<RenameTemplateParser::Field> expectedFields{
        RenameTemplateParser::Field::Title,
        RenameTemplateParser::Field::Artist,
        RenameTemplateParser::Field::Album,
        RenameTemplateParser::Field::AlbumArtist,
        RenameTemplateParser::Field::Genre,
        RenameTemplateParser::Field::Date,
        RenameTemplateParser::Field::TrackNumber,
        RenameTemplateParser::Field::DiscNumber,
        RenameTemplateParser::Field::FileName
    };

    int fieldIndex = 0;

    for (const auto &token : result.tokens) {
        if (token.type != RenameTemplateParser::Token::Type::Field)
            continue;

        QCOMPARE(token.field, expectedFields.at(fieldIndex));
        ++fieldIndex;
    }

    QCOMPARE(fieldIndex, expectedFields.size());
}

void RenameTemplateParserTest::rejectsEmptyTemplate()
{
    const auto result = RenameTemplateParser::parse({});

    QVERIFY(!result.valid);
    QVERIFY(!result.errorMessage.isEmpty());
    QVERIFY(result.tokens.isEmpty());
}

void RenameTemplateParserTest::rejectsUnknownField()
{
    const auto result = RenameTemplateParser::parse(
        QStringLiteral("{UNKNOWN}")
    );

    QVERIFY(!result.valid);
    QCOMPARE(result.tokens.size(), 0);
    QVERIFY(result.errorMessage.contains(QStringLiteral("UNKNOWN")));
}

void RenameTemplateParserTest::rejectsUnclosedField()
{
    const auto result = RenameTemplateParser::parse(
        QStringLiteral("{ARTIST}/{ALBUM")
    );

    QVERIFY(!result.valid);
    QCOMPARE(result.tokens.size(), 2);
    QVERIFY(result.errorMessage.contains(QStringLiteral("closing brace")));
}

void RenameTemplateParserTest::rejectsUnexpectedClosingBrace()
{
    const auto result = RenameTemplateParser::parse(
        QStringLiteral("Artist}")
    );

    QVERIFY(!result.valid);
    QVERIFY(result.errorMessage.contains(QStringLiteral("closing brace")));
}

void RenameTemplateParserTest::rejectsEmptyField()
{
    const auto result = RenameTemplateParser::parse(
        QStringLiteral("Artist/{}")
    );

    QVERIFY(!result.valid);
    QVERIFY(result.errorMessage.contains(QStringLiteral("Empty field")));
}

void RenameTemplateParserTest::acceptsCaseInsensitiveFields()
{
    const auto result = RenameTemplateParser::parse(
        QStringLiteral("{artist}/{Album}/{tRaCkNuMbEr}")
    );

    QVERIFY(result.valid);
    QCOMPARE(result.tokens.size(), 5);

    QCOMPARE(
        result.tokens.at(0).field,
        RenameTemplateParser::Field::Artist
    );

    QCOMPARE(
        result.tokens.at(2).field,
        RenameTemplateParser::Field::Album
    );

    QCOMPARE(
        result.tokens.at(4).field,
        RenameTemplateParser::Field::TrackNumber
    );
}

QTEST_GUILESS_MAIN(RenameTemplateParserTest)

#include "tst_renametemplateparser.moc"