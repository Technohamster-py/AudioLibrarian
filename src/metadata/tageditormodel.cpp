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

    return m_metadata.properties().size();
}

QVariant TagEditorModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() < 0)
        return {};

    const auto &properties = m_metadata.properties();
    if (index.row() >= properties.size())
        return {};

    auto iterator = properties.cbegin();

    std::advance(iterator, index.row());

    if (iterator == properties.cend())
        return {};

    switch (role) {
        case Qt::DisplayRole:
        case KeyRole: return iterator.key();
        case ValueRole: return iterator.value().join(QStringLiteral("; "));
        case ValuesRole: return iterator.value();
        default: return {};
    }
}

QHash<int, QByteArray> TagEditorModel::roleNames() const {
    return {
        {KeyRole, "key"},
        {ValueRole, "value"},
        {ValuesRole, "values"}
    };
}

void TagEditorModel::setMetadata(const AudioMetadata &metadata) {
    beginResetModel();
    m_metadata = metadata;
    endResetModel();
}

