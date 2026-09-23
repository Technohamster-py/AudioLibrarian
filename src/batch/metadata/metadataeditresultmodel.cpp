#include "metadataeditresultmodel.h"

MetadataEditResultModel::MetadataEditResultModel(QObject *parent) : QAbstractListModel(parent) {
}

int MetadataEditResultModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid())
        return 0;

    return m_results.size();
}

QVariant MetadataEditResultModel::data(const QModelIndex &index, const int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= m_results.size())
        return {};

    const MetadataEditFileResult &result = m_results.at(index.row());

    switch (role) {
        case FilePathRole: return result.filePath;
        case SuccessRole: return result.success;
        case ErrorMessageRole: return result.errorMessage;
        default: return {};
    }
}

QHash<int, QByteArray> MetadataEditResultModel::roleNames() const {
    return {
        {FilePathRole, "filePath"},
        {SuccessRole, "success"},
        {ErrorMessageRole, "errorMessage"}
    };
}

void MetadataEditResultModel::setResults(const QVector<MetadataEditFileResult> &results) {
    beginResetModel();
    m_results = results;
    endResetModel();
}

void MetadataEditResultModel::clear() {
    if (m_results.isEmpty())
        return;

    beginResetModel();
    m_results.clear();
    endResetModel();
}