#pragma once

#include "metadataeditor.h"

#include <QAbstractListModel>

/**
 * @brief Model containing results of batch metadata editing.
 */
class MetadataEditResultModel final : public QAbstractListModel {
    Q_OBJECT

public:
    enum Role {
        FilePathRole = Qt::UserRole + 1,
        SuccessRole,
        ErrorMessageRole
    };
    Q_ENUM(Role)

    explicit MetadataEditResultModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    /**
     * @brief Replaces the model contents with operation results.
     */
    void setResults(const QVector<MetadataEditFileResult> &results);

    /**
     * @brief Removes all results from the model.
     */
    void clear();

private:
    QVector<MetadataEditFileResult> m_results;
};