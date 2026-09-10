#pragma once

#include "batchprocesscontroller.h"
#include "duplicatefinder.h"
#include "duplicateresultmodel.h"

#include "library/scanner/libraryscanner.h"

#include <QAbstractItemModel>
#include <QSharedPointer>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

class DuplicateFinderController : public BatchProcessController
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QAbstractItemModel *resultModel READ resultModel CONSTANT)
    Q_PROPERTY(qsizetype analyzedFileCount READ analyzedFileCount NOTIFY resultChanged)
    Q_PROPERTY(qsizetype duplicateGroupCount READ duplicateGroupCount NOTIFY resultChanged)
    Q_PROPERTY(qsizetype duplicateFileCount READ duplicateFileCount NOTIFY resultChanged)
    Q_PROPERTY(qsizetype removableFileCount READ removableFileCount NOTIFY resultChanged)

public:
    explicit DuplicateFinderController(QObject *parent = nullptr);

    QAbstractItemModel *resultModel() { return &m_resultModel; }

    qsizetype analyzedFileCount() const { return m_analyzedFileCount; }
    qsizetype duplicateGroupCount() const { return m_duplicateGroupCount; }
    qsizetype duplicateFileCount() const { return m_duplicateFileCount; }
    qsizetype removableFileCount() const { return m_removableFileCount; }

    /**
     * @brief Starts duplicate search for files below the specified directory.
     *
     * @param baseFilePath Directory to scan recursively.
     * @param searchByHash Enables content-based search.
     * @param searchByMetadata Enables metadata-based search.
     * @param searchByFileName Enables file-name-based search.
     * @param durationTolerance Maximum allowed duration difference in seconds.
     * @return true if the operation was started.
     */
    Q_INVOKABLE bool start(const QString &baseFilePath, bool searchByHash, bool searchByMetadata, bool searchByFileName, int durationTolerance);
    Q_INVOKABLE bool openFileLocation(const QString &filePath);
    Q_INVOKABLE bool deleteFile(const QString &filePath);
    Q_INVOKABLE void keepFile(const QString &filePath, const DuplicateGroup &group);

signals:
    void resultChanged();

protected:
    void handleFinished() override;

private:
    void resetResult();

    LibraryScanner m_scanner;
    QSharedPointer<DuplicateFinder> m_duplicateFinder;
    DuplicateResultModel m_resultModel;

    qsizetype m_analyzedFileCount = 0;
    qsizetype m_duplicateGroupCount = 0;
    qsizetype m_duplicateFileCount = 0;
    qsizetype m_removableFileCount = 0;

    QString m_baseFilePath;
};