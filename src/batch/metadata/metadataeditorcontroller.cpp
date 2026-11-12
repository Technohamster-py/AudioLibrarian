#include "metadataeditorcontroller.h"

#include <QDir>

MetadataEditorController::MetadataEditorController(QObject *parent) : BatchProcessController(parent), m_metadataEditor(QSharedPointer<MetadataEditor>::create()) {
    connect(processor(), &BatchProcessor::finished, this, &MetadataEditorController::handleFinished);
    connect(processor(), &BatchProcessor::cancelled, this, &MetadataEditorController::handleFinished);
}

bool MetadataEditorController::start(const QString &baseFilePath, const QVariantList &changes) {
    if (running())
        return false;

    const QDir directory(baseFilePath);

    if (!directory.exists() || changes.isEmpty())
        return false;

    QVector<MetadataChange> metadataChanges;
    metadataChanges.reserve(changes.size());

    for (const QVariant &changeVariant : changes) {
        const QVariantMap changeMap = changeVariant.toMap();

        const QString key = changeMap.value(QStringLiteral("key")).toString();

        if (key.isEmpty())
            continue;

        MetadataChange change;
        change.key = key;
        change.values = changeMap.value(QStringLiteral("values")).toStringList();
        change.remove = changeMap.value(QStringLiteral("remove")).toBool();

        metadataChanges.append(std::move(change));
    }

    if (metadataChanges.isEmpty())
        return false;

    const QVector<AudioFileRecord> files = m_scanner.scan(baseFilePath);

    m_selectedFileCount = files.size();
    emit selectedFileCountChanged();

    if (files.isEmpty())
        return false;

    clearError();

    m_metadataEditor->setChanges(metadataChanges);

    return startOperation(m_metadataEditor, files);
}

bool MetadataEditorController::renameAlbum(const QStringList &filePaths, const QString &name)
{
    return renameFiles(filePaths, name, QStringLiteral("ALBUM"));
}

bool MetadataEditorController::renameArtist(const QStringList &filePaths, const QString &name)
{
    return renameFiles(filePaths, name, QStringLiteral("ARTIST"));
}

bool MetadataEditorController::renameFiles(const QStringList &filePaths, const QString &name, const QString &key)
{
    if (running() || filePaths.isEmpty() || name.trimmed().isEmpty())
        return false;

    QVector<AudioFileRecord> files;
    QSet<QString> seen;
    for (const QString &path : filePaths) {
        if (!seen.contains(path)) {
            seen.insert(path);
            files.append(AudioFileRecord{path, {}});
        }
    }
    m_selectedFileCount = files.size();
    emit selectedFileCountChanged();
    clearError();
    m_metadataEditor->setChanges({MetadataChange{key, {name}, false}});
    if (!startOperation(m_metadataEditor, files))
        return false;
    m_renameKey = key;
    return true;
}

void MetadataEditorController::handleFinished()
{
    m_resultModel.setResults(m_metadataEditor->result());
    QStringList updatedPaths;
    for (const auto &result : m_metadataEditor->result()) {
        if (result.success)
            updatedPaths.append(result.filePath);
    }
    if (!updatedPaths.isEmpty())
        emit filesUpdated(updatedPaths);
    const QString key = m_renameKey;
    m_renameKey.clear();
    if (key == QStringLiteral("ALBUM"))
        emit albumRenameFinished();
    else if (key == QStringLiteral("ARTIST"))
        emit artistRenameFinished();
}