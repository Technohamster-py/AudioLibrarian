#pragma once

#include "duplicatesearchresult.h"
#include <QAbstractItemModel>

#include <memory>
#include <vector>

class DuplicateResultModel : public QAbstractItemModel {
public:
    enum Role {
        FilePathRole = Qt::UserRole + 1,
        RelativeFilePathRole,
        NodeTypeRole,
        SearchModeRole,
        GroupIndexRole,
        ActiveRole
    };

    enum class NodeType {
        Mode,
        Group,
        File
    };

    explicit DuplicateResultModel(QObject *parent = nullptr);

    void setResult(const DuplicateSearchResult &result);
    void setBaseDirectory(const QString &baseDirectory);

    int columnCount(const QModelIndex &parent = {}) const override;
    int rowCount(const QModelIndex &parent = {}) const override;
    QModelIndex index(int row, int column, const QModelIndex &parent = {}) const override;
    QModelIndex parent(const QModelIndex &index) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setFileInactive(const QString &filePath);

private:
    struct Node {
        NodeType type;
        QString display;
        QString filePath;
        QString relativeFilePath;
        DuplicateSearchMode searchMode = DuplicateSearchMode::Content;
        int groupIndex = -1;
        Node *parent = nullptr;
        std::vector<std::unique_ptr<Node>> children;
        bool active = true;
    };

    static QString modeDisplayName(DuplicateSearchMode mode);

    Node *nodeFromIndex(const QModelIndex &index) const;
    Node *findModeNode(DuplicateSearchMode mode) const;
    Node *appendModeNode(DuplicateSearchMode mode);

    std::unique_ptr<Node> m_root;
    QString m_baseDirectory;
};


