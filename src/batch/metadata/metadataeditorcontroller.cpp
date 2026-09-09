#include "metadataeditorcontroller.h"

#include <QDir>

MetadataEditorController::MetadataEditorController(QObject *parent): BatchProcessController(parent), m_metadataEditor(QSharedPointer<MetadataEditor>::create()) {
    connect(processor(), &BatchProcessor::finished, this, &MetadataEditorController::handleFinished);
}

bool MetadataEditorController::start(const QString &baseFilePath, const QVariantList &changes) {
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

void MetadataEditorController::handleFinished()
{
    /*
     * MetadataEditor keeps per-file results itself.
     * The controller currently only needs to expose the execution state
     * through BatchProcessController.
     */
}