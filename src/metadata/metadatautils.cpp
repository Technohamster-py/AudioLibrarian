#include "metadatautils.h"

namespace MetadataUtils {
    QString formatDuration(int seconds) {
        if (seconds <= 0)
            return QStringLiteral("00:00");

        const int hours = seconds / 3600;
        const int minutes = (seconds % 3600) / 60;
        const int remainingSeconds = seconds % 60;

        if (hours > 0) {
            return QStringLiteral("%1:%2:%3")
                .arg(hours)
                .arg(minutes, 2, 10, QChar('0'))
                .arg(remainingSeconds, 2, 10, QChar('0'));
        }

        return QStringLiteral("%1:%2")
            .arg(minutes, 2, 10, QChar('0'))
            .arg(remainingSeconds, 2, 10, QChar('0'));
    }

    QString extractYear(const QString &date)
    {
        if (date.size() < 4)
            return {};

        const QString year = date.left(4);

        bool ok = false;
        year.toInt(&ok);

        return ok ? year : QString();
    }

    bool hasLyrics(const AudioMetadata &metadata)
    {
        static const QStringList lyricsKeys = {
            QStringLiteral("LYRICS"),
            QStringLiteral("UNSYNCEDLYRICS"),
            QStringLiteral("UNSYNCED_LYRICS"),
            QStringLiteral("USLT")
        };

        for (const QString &key : lyricsKeys) {
            const QStringList values = metadata.values(key);

            for (const QString &value : values) {
                if (!value.trimmed().isEmpty())
                    return true;
            }
        }

        for (auto iterator = metadata.properties().cbegin();
             iterator != metadata.properties().cend();
             ++iterator) {

            if (!iterator.key().contains(
                    QStringLiteral("LYRIC"),
                    Qt::CaseInsensitive))
                continue;

            for (const QString &value : iterator.value()) {
                if (!value.trimmed().isEmpty())
                    return true;
            }
             }

        return false;
    }
}