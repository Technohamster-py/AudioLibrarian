#pragma once

#include "abstractbatchoperation.h"
#include "renamefileresult.h"
#include "renametemplateparser.h"

#include <QDir>
#include <QString>
#include <QVector>

#include <atomic>

/**
 * @brief Renames and sorts audio files according to a metadata template.
 *
 * The operation uses metadata already stored in AudioFileRecord and does not
 * access TagLib directly. The complete rename plan is validated before any
 * filesystem changes are performed.
 */
class FileRenamer : public AbstractBatchOperation {
    Q_OBJECT

public:
    /**
     * @brief Creates a file renamer.
     *
     * @param templatePattern Relative rename template.
     * @param baseDirectory Root directory for generated paths.
     * @param parent Parent QObject.
     */

     FileRenamer(const QString &templatePattern, const QString &baseDirectory, QObject *parent = nullptr);

    /**
     * @brief Executes the rename operation.
     *
     * @param files Files to rename.
     * @param cancellationRequested Shared cancellation flag.
     * @return Operation result.
     */
    BatchOperationResult execute(const QVector<AudioFileRecord>& files, const std::atomic_bool &cancellationRequested) override;

private:
    struct RenamePlanEntry {
        QString sourcePath;
        QString targetPath;
    };

    /**
     * @brief Builds a target path from one audio file and parsed tokens.
     *
     * @param file Source file.
     * @return Generated relative target path.
     */
    QString buildTargetPath(const AudioFileRecord &file) const;

    /**
     * @brief Returns the value of a metadata field.
     *
     * @param file Audio file containing metadata.
     * @param field Template field.
     * @return Field value.
     */
    QString fieldValue(const AudioFileRecord &file,RenameTemplateParser::Field field) const;

    /**
     * @brief Validates a complete rename plan before modifying files.
     *
     * @param plan Rename operations.
     * @return Empty string when the plan is valid, otherwise an error.
     */
    QString validatePlan(const QVector<RenamePlanEntry> &plan) const;

    /**
     * @brief Checks whether a generated path is safe to use below the base directory.
     *
     * @param relativePath Generated relative path.
     * @return true when the path does not escape the base directory.
     */
    bool isSafeRelativePath(const QString &relativePath) const;

    RenameTemplateParser::Result m_template;
    QString m_baseDirectory;
};