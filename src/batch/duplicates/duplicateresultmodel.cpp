#include "duplicateresultmodel.h"

#include <algorithm>
#include  <array>

#include <QFileInfo>
#include <QDir>

DuplicateResultModel::DuplicateResultModel(QObject *parent) : QAbstractItemModel(parent),
                                                              m_root(std::make_unique<Node>(Node{
                                                                  NodeType::Mode,
                                                                  {},
                                                                  {},
                                                                  {},
                                                                  DuplicateSearchMode::Content,
                                                                  -1,
                                                                  nullptr,
                                                                  {}
                                                              })) {
}

void DuplicateResultModel::setResult(const DuplicateSearchResult &result) {
    beginResetModel();

    m_root->children.clear();

    std::array<int, 3>groupNumbers{0, 0, 0};

    for (const DuplicateGroup &group : result.groups) {
        Node *modeNode = findModeNode(group.mode);

        if (!modeNode) {
            modeNode = appendModeNode(group.mode);
        }

        const int modeIndex = static_cast<int>(group.mode);
        const int groupIndex = ++groupNumbers.at(modeIndex);

        auto groupNode = std::make_unique<Node>(Node {
            NodeType::Group,
            tr("Group %1").arg(groupIndex),
            {},
            {},
            group.mode,
            groupIndex,
            modeNode,
            {}
        });

        for (const DuplicateFile &file : group.files) {
            groupNode->children.push_back(std::make_unique<Node>(Node{
                    NodeType::File,
                    QFileInfo(file.filePath).fileName(),
                    file.filePath,
                    QDir(m_baseDirectory).relativeFilePath(file.filePath),
                    group.mode,
                    groupIndex,
                    groupNode.get(),
                    {}
                })
            );
        }
        modeNode->children.push_back(std::move(groupNode));
    }
    endResetModel();
}

void DuplicateResultModel::setBaseDirectory(const QString &baseDirectory) {
    m_baseDirectory = QDir::cleanPath(baseDirectory);
}

int DuplicateResultModel::columnCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    return 1;
}

int DuplicateResultModel::rowCount(const QModelIndex &parent) const {
    const Node *node = nodeFromIndex(parent);

    return static_cast<int>(node->children.size());
}

QModelIndex DuplicateResultModel::index(int row, int column, const QModelIndex &parent) const {
    if (column != 0)
        return {};

    const Node *parentNode = nodeFromIndex(parent);

    if (row < 0 || row >= static_cast<int>(parentNode->children.size()))
        return {};

    return createIndex(row, column, parentNode->children.at(row).get());
}

QModelIndex DuplicateResultModel::parent(const QModelIndex &index) const {
    if (!index.isValid())
        return {};

    const Node *node = nodeFromIndex(index);

    if (!node->parent || node->parent == m_root.get())
        return {};

    const Node *parentNode = node->parent;

    const auto it = std::find_if(parentNode->parent->children.begin(), parentNode->parent->children.end(), [parentNode](const std::unique_ptr<Node> &child) {
            return child.get() == parentNode;
        }
    );

    if (it == parentNode->parent->children.end())
        return {};

    const int row = std::distance(parentNode->parent->children.begin(), it);

    return createIndex(row, 0, parentNode);
}

QVariant DuplicateResultModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid())
        return {};

    const Node *node = nodeFromIndex(index);

    switch (role) {
        case Qt::DisplayRole: return node->display;
        case RelativeFilePathRole: return node->relativeFilePath;
        case FilePathRole: return node->filePath;
        case NodeTypeRole: return static_cast<int>(node->type);
        case SearchModeRole: return static_cast<int>(node->searchMode);
        case GroupIndexRole: return node->groupIndex;
        default: return {};
    }
}

QHash<int, QByteArray> DuplicateResultModel::roleNames() const {
    return {
        {Qt::DisplayRole, "display"},
        {RelativeFilePathRole, "relativeFilePath"},
        {FilePathRole, "filePath"},
        {NodeTypeRole, "nodeType"},
        {SearchModeRole, "searchMode"},
        {GroupIndexRole, "groupIndex"}
    };
}

QString DuplicateResultModel::modeDisplayName(DuplicateSearchMode mode) {
    switch (mode) {
        case DuplicateSearchMode::Content: return tr("Duplicates by content");
        case DuplicateSearchMode::Metadata: return tr("Duplicates by metadata");
        case DuplicateSearchMode::FileName: return tr("Duplicates by file name");
    }
    return {};
}

DuplicateResultModel::Node * DuplicateResultModel::nodeFromIndex(const QModelIndex &index) const {
    return index.isValid() ? static_cast<Node*>(index.internalPointer()) : m_root.get();
}

DuplicateResultModel::Node * DuplicateResultModel::findModeNode(DuplicateSearchMode mode) const {
    for (const auto &child : m_root->children) {
        if (child->type == NodeType::Mode && child->searchMode == mode)
            return child.get();
    }
    return nullptr;
}

DuplicateResultModel::Node * DuplicateResultModel::appendModeNode(DuplicateSearchMode mode) {
    auto node = std::make_unique<Node>(Node{
        NodeType::Mode,
        modeDisplayName(mode),
        {},
        {},
        mode,
        -1,
        m_root.get(),
        {}
    });

    Node *result = node.get();
    m_root->children.push_back(std::move(node));
    return result;
}


