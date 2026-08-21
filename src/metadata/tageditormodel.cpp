#include "tageditormodel.h"

#include <QVariant>

TagEditorModel::TagEditorModel(QObject *parent) : QAbstractListModel(parent){
}

QString TagEditorModel::filePath() const {
    return m_filePath;
}

void TagEditorModel::setFilePath(const QString &filePath) {
    if (m_filePath == filePath)
        return;
    m_filePath = filePath;
    emit filePathChanged();

    beginResetModel();
    m_metadata = AudioMetadata{};
    m_entries.clear();
    endResetModel();

    if (m_filePath.isEmpty())
        return;

    QString errorMessage;
    const auto result = m_backend.read(m_filePath, &errorMessage);

    if (!result.has_value()) {
        emit errorOccurred(errorMessage);
        return;
    }

    setMetadata(*result);
}

int TagEditorModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;

    return m_entries.size();
}

QVariant TagEditorModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid())
        return {};

    if (index.row() < 0 ||index.row() >= m_entries.size())
        return {};

    const TagEntry &entry = m_entries.at(index.row());

    switch (role) {
        case Qt::DisplayRole:
        case KeyRole: return entry.key;
        case ValueRole: return formatValue(entry.key, entry.values);
        case ValuesRole: return entry.values;
        case DisplayNameRole: return displayNameForKey(entry.key);
        case IsLyricsRole: return isLyricsKey(entry.key);
        default: return {};
    }
}

QHash<int, QByteArray> TagEditorModel::roleNames() const {
    return {
        {KeyRole, "key"},
        {ValueRole, "value"},
        {ValuesRole, "values"},
        {DisplayNameRole, "displayName"},
        {IsLyricsRole, "isLyrics"}
    };
}

void TagEditorModel::setMetadata(const AudioMetadata &metadata) {
    QVector<TagEntry> entries;
    entries.reserve(metadata.properties().size());

    for (auto iterator = metadata.properties().cbegin(); iterator != metadata.properties().cend(); ++iterator) {
        TagEntry entry;
        entry.key = iterator.key();
        entry.values = iterator.value();
        entry.priority = sortPriorityForKey(entry.key);
        entries.append(std::move(entry));
    }

    std::stable_sort(entries.begin(), entries.end(), [](const TagEntry &left, const TagEntry &right) {return left.priority < right.priority;});

    beginResetModel();

    m_metadata = metadata;
    m_entries = std::move(entries);

    endResetModel();
}

QString TagEditorModel::displayNameForKey(const QString &key) {
    const QString normalized = key.toUpper();

    if (isLyricsKey(normalized))
        return QStringLiteral("Lyrics");

    if (normalized == QStringLiteral("TITLE"))
        return QStringLiteral("Title");

    if (normalized == QStringLiteral("ARTIST"))
        return QStringLiteral("Artist");

    if (normalized == QStringLiteral("GENRE"))
        return QStringLiteral("Genre");

    if (normalized == QStringLiteral("ALBUM"))
        return QStringLiteral("Album");

    if (normalized == QStringLiteral("DISCNUMBER"))
        return QStringLiteral("Disc number");

    if (normalized == QStringLiteral("TRACKNUMBER"))
        return QStringLiteral("Track number");

    if (normalized == QStringLiteral("DATE"))
        return QStringLiteral("Date");

    if (normalized == QStringLiteral("LENGTH"))
        return QStringLiteral("Duration");

    if (normalized == QStringLiteral("ALBUMARTIST"))
        return QStringLiteral("Album artist");

    if (normalized == QStringLiteral("COMMENT"))
        return QStringLiteral("Comment");

    if (normalized == QStringLiteral("COMPOSER"))
        return QStringLiteral("Composer");

    if (normalized == QStringLiteral("COPYRIGHT"))
        return QStringLiteral("Copyright");

    if (normalized == QStringLiteral("LABEL"))
        return QStringLiteral("Label");

    if (normalized == QStringLiteral("DISCNUMBER"))
        return QStringLiteral("Disc number");

    if (normalized == QStringLiteral("MEDIA"))
        return QStringLiteral("Media type");

    /*
     * Fallback for unknown properties.
     */
    return key;
}

int TagEditorModel::sortPriorityForKey(const QString &key) {
    const QString normalized =
        key.toUpper();

    if (normalized == QStringLiteral("TITLE"))
        return 0;

    if (normalized == QStringLiteral("ARTIST"))
        return 1;

    if (normalized == QStringLiteral("GENRE"))
        return 2;

    if (normalized == QStringLiteral("ALBUM"))
        return 3;

    if (normalized == QStringLiteral("DISCNUMBER"))
        return 4;

    if (normalized == QStringLiteral("TRACKNUMBER"))
        return 5;

    if (normalized == QStringLiteral("DATE"))
        return 6;

    if (normalized == QStringLiteral("LENGTH"))
        return 7;

    if (isLyricsKey(normalized))
        return 8;

    return 9;
}

QString TagEditorModel::formatValue(const QString &key, const QStringList &values) {
    if (values.isEmpty())
        return {};

    if (key.compare(QStringLiteral("LENGTH"), Qt::CaseInsensitive) == 0) {
        bool ok = false;
        const qint64 milliseconds = values.first().toLongLong(&ok);

        if (ok)
            return formatDuration(milliseconds);
    }

    /*
     * Multiple values are kept visible instead of silently discarding all
     * values except the first one.
     */
    return values.join(QStringLiteral("; "));
}

bool TagEditorModel::isLyricsKey(const QString &key) {
    const QString normalized =
        key.toUpper();

    /*
     * TagLib can expose lyrics in several forms depending on the format.
     * LYRICS:<description> is also supported.
     */
    return normalized == QStringLiteral("LYRICS") ||
           normalized.startsWith(QStringLiteral("LYRICS:")) ||
           normalized == QStringLiteral("UNSYNCEDLYRICS") ||
           normalized == QStringLiteral("UNSYNCED_LYRICS") ||
           normalized == QStringLiteral("USLT");
}

QString TagEditorModel::formatDuration(quint64 milliseconds) {
    if (milliseconds <= 0)
        return QStringLiteral("00:00");

    const qint64 totalSeconds = milliseconds / 1000;

    const qint64 hours = totalSeconds / 3600;

    const qint64 minutes = (totalSeconds % 3600) / 60;

    const qint64 seconds = totalSeconds % 60;

    if (hours > 0)
        return QStringLiteral("%1:%2:%3").arg(hours).arg(minutes, 2, 10, QChar('0')).arg(seconds, 2, 10, QChar('0'));
    return QStringLiteral("%1:%2").arg(minutes, 2, 10, QChar('0')).arg(seconds, 2, 10, QChar('0'));
}

