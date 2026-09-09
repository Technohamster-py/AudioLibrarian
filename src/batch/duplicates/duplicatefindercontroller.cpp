#include "duplicatefindercontroller.h"

#include <QDir>
#include <QSet>

DuplicateFinderController::DuplicateFinderController(QObject *parent) : BatchProcessController(parent) , m_duplicateFinder(QSharedPointer<DuplicateFinder>::create()) {
    connect(processor(), &BatchProcessor::finished, this, &DuplicateFinderController::handleFinished);
}

bool DuplicateFinderController::start(const QString &baseFilePath, const bool searchByHash, const bool searchByMetadata, const bool searchByFileName, const int durationTolerance) {
    const QDir directory(baseFilePath);

    if (!directory.exists()) {
        return false;
    }

    QSet<DuplicateSearchMode> searchModes;

    if (searchByHash)
        searchModes.insert(DuplicateSearchMode::Content);

    if (searchByMetadata)
        searchModes.insert(DuplicateSearchMode::Metadata);

    if (searchByFileName)
        searchModes.insert(DuplicateSearchMode::FileName);

    if (searchModes.isEmpty())
        return false;

    resetResult();

    m_duplicateFinder->setSearchModes(searchModes);
    m_duplicateFinder->setDurationTolerance(durationTolerance);

    const QVector<AudioFileRecord> files = m_scanner.scan(baseFilePath);

    return startOperation(m_duplicateFinder, files);
}

void DuplicateFinderController::handleFinished()
{
    const DuplicateSearchResult &result = m_duplicateFinder->result();

    m_duplicateGroupCount = result.groups.size();
    m_duplicateFileCount = result.duplicateFileCount();
    m_removableFileCount = result.removableFileCount();

    m_resultModel.setResult(result);

    emit resultChanged();
}

void DuplicateFinderController::resetResult()
{
    m_duplicateGroupCount = 0;
    m_duplicateFileCount = 0;
    m_removableFileCount = 0;

    m_resultModel.setResult({});

    emit resultChanged();
}