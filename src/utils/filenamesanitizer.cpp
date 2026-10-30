#include "filenamesanitizer.h"

namespace {

    constexpr QChar replacementCharacter = u'_';

    /**
     * @brief Checks whether a character is forbidden in a Windows filename.
     *
     * @param character Character to check.
     * @return true when the character is forbidden.
     */
    bool isInvalidCharacter(const QChar character)
    {
        if (character.unicode() < 0x20)
            return true;

        switch (character.unicode()) {
        case '<':
        case '>':
        case ':':
        case '"':
        case '/':
        case '\\':
        case '|':
        case '?':
        case '*':
            return true;
        default:
            return false;
        }
    }

} // namespace

QString FilenameSanitizer::sanitize(const QString &value)
{
    QString result;
    result.reserve(value.size());

    for (const QChar character : value) {
        if (isInvalidCharacter(character))
            result.append(replacementCharacter);
        else
            result.append(character);
    }

    // Windows does not allow spaces or dots at the end of a filename
    // component.
    while (!result.isEmpty() && (result.back() == u' ' || result.back() == u'.'))
        result.chop(1);

    if (result.isEmpty())
        return QStringLiteral("_");

    if (isReservedName(result))
        return result.prepend(u'_');

    return result;
}

bool FilenameSanitizer::isReservedName(const QString &name)
{
    const QString normalizedName = name.toUpper();

    if (normalizedName == QStringLiteral("CON") ||
        normalizedName == QStringLiteral("PRN") ||
        normalizedName == QStringLiteral("AUX") ||
        normalizedName == QStringLiteral("NUL")) {
        return true;
        }

    if (normalizedName.size() == 4 &&
        (normalizedName.startsWith(QStringLiteral("COM")) ||
         normalizedName.startsWith(QStringLiteral("LPT")))) {
        const QChar number = normalizedName.at(3);

        return number >= u'1' && number <= u'9';
         }

    return false;
}