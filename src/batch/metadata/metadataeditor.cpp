#include "metadataeditor.h"
#include "metadata/taglibmetadatabackend.h"

MetadataEditor::MetadataEditor(QObject *parent) : AbstractBatchOperation(parent) {
}

void MetadataEditor::setChanges(const QVector<MetadataChange> &changes) {
    m_changes = changes;
}

BatchOperationResult MetadataEditor::execute(const QVector<AudioFileRecord> &files, const std::atomic_bool &cancellationRequested) {
    if (m_changes.isEmpty() || files.isEmpty())
        return {.state = BatchOperationState::Fail, .errorMessage = tr("No changes or files provided")};

    m_results.clear();
    m_results.reserve(files.size());

    TagLibMetadataBackend backend;

    const qsizetype total = files.size();
    qsizetype processed = 0;

    reportProgress(processed, total, QStringLiteral("Editing metadata"), {});

    for (const AudioFileRecord &file : files) {
        if (cancellationRequested.load(std::memory_order_relaxed))
            return {.state = BatchOperationState::Cancelled};

        MetadataEditFileResult fileResult;
        fileResult.filePath = file.filePath;

        QString errorMessage;
        const auto metadata = backend.read(file.filePath, &errorMessage);

        if (!metadata) {
            fileResult.errorMessage = errorMessage;
            m_results.append(std::move(fileResult));

            ++processed;
            reportProgress(processed, total, QStringLiteral("Editing metadata"), file.filePath);
            continue;
        }

        AudioMetadata updatedMetadata = *metadata;

        for (const MetadataChange &change : m_changes) {
            if (change.remove)
                updatedMetadata.remove(change.key);
            else
                updatedMetadata.setValues(change.key, change.values);
        }

        errorMessage.clear();

        if (!backend.write(file.filePath, updatedMetadata, &errorMessage))
            fileResult.errorMessage = errorMessage;
        else
            fileResult.success = true;

        m_results.append(std::move(fileResult));

        ++processed;
        reportProgress(processed, total, QStringLiteral("Editing metadata"), file.filePath);
    }

    return {.state = BatchOperationState::Success};
}
