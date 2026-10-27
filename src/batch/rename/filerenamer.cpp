#include "filerenamer.h"

#include  "utils/filenamesanitizer.h"

#include <QFile>
#include <QFileInfo>
#include <QHash>
#include <QSet>

FileRenamer::FileRenamer(const QString& templatePattern, const QString& baseDirectory, QObject* parent) :
    AbstractBatchOperation(parent), m_template(RenameTemplateParser::parse(templatePattern)),
    m_baseDirectory(QDir(baseDirectory).absolutePath())
{
}

BatchOperationResult FileRenamer::execute(const QVector<AudioFileRecord>& files,
                                          const std::atomic_bool& cancellationRequested)
{
    QVector<RenamePlanEntry> plan;
    QString planError;

    if (!buildPlan(files, &plan, &planError))
        return {BatchOperationState::Fail, planError};

    if (files.isEmpty())
        return {BatchOperationState::Success, {}};

    const qsizetype total = plan.size();

    for (qsizetype index = 0; index < total; ++index)
    {
        if (cancellationRequested.load())
            return {
                BatchOperationState::Cancelled,
                {}
            };

        const auto& entry = plan.at(index);

        const QFileInfo targetInfo(entry.targetPath);
        const QString targetDirectory = targetInfo.absolutePath();

        if (!QDir().mkpath(targetDirectory))
        {
            return {
                BatchOperationState::Fail,
                QStringLiteral("Failed to create directory: %1").arg(targetDirectory)
            };
        }

        QFile sourceFile(entry.sourcePath);

        if (!sourceFile.rename(entry.targetPath))
        {
            return {
                BatchOperationState::Fail,
                QStringLiteral("Failed to rename '%1' to '%2': %3")
                    .arg(entry.sourcePath, entry.targetPath, sourceFile.errorString())
            };
        }

        reportProgress(index + 1, total, QStringLiteral("Renaming files"), entry.targetPath);
    }

    return {
        BatchOperationState::Success,
        {}
    };
}

QString FileRenamer::buildTargetPath(const AudioFileRecord& file) const
{
    QString path;

    for (const auto& token : m_template.tokens)
    {
        if (token.type == RenameTemplateParser::Token::Type::Literal)
        {
            path.append(token.value);
            continue;
        }

        path.append(FilenameSanitizer::sanitize(fieldValue(file, token.field)));
    }

    const QFileInfo sourceInfo(file.filePath);

    if (!sourceInfo.suffix().isEmpty())
    {
        path += QStringLiteral(".") + sourceInfo.suffix();
    }

    return QDir::cleanPath(path);
}

QString FileRenamer::fieldValue(const AudioFileRecord& file, const RenameTemplateParser::Field field) const
{
    const auto& metadata = file.fileInfo.metadata;

    QString value;

    switch (field)
    {
    case RenameTemplateParser::Field::Title: value = metadata.title();
        break;
    case RenameTemplateParser::Field::Artist: value = metadata.artist();
        break;
    case RenameTemplateParser::Field::Album: value = metadata.album();
        break;
    case RenameTemplateParser::Field::AlbumArtist: value = metadata.albumArtist();
        break;
    case RenameTemplateParser::Field::Genre: value = metadata.genre();
        break;
    case RenameTemplateParser::Field::Date: value = metadata.date();
        break;
    case RenameTemplateParser::Field::TrackNumber: value = metadata.trackNumber();
        break;
    case RenameTemplateParser::Field::DiscNumber: value = metadata.discNumber();
        break;
    case RenameTemplateParser::Field::FileName: value = QFileInfo(file.filePath).completeBaseName();
        break;
    }

    if (value.trimmed().isEmpty())
        return QStringLiteral("UNKNOWN");

    return value;
}

QString FileRenamer::validatePlan(const QVector<RenamePlanEntry>& plan) const
{
    QHash<QString, qsizetype> sourceIndices;
    QSet<QString> targetPaths;

    for (qsizetype index = 0; index < plan.size(); ++index)
    {
        const auto& entry = plan.at(index);
        const QString sourcePath = QDir::cleanPath(QFileInfo(entry.sourcePath).absoluteFilePath());
        const QString targetPath = QDir::cleanPath(QFileInfo(entry.targetPath).absoluteFilePath());

        if (sourcePath == targetPath)
            continue;

        if (targetPaths.contains(targetPath))
        {
            return QStringLiteral("Multiple files have the same target path: %1").arg(targetPath);
        }

        targetPaths.insert(targetPath);
        sourceIndices.insert(sourcePath, index);
    }

    for (const auto& entry : plan)
    {
        const QString sourcePath = QDir::cleanPath(QFileInfo(entry.sourcePath).absoluteFilePath());
        const QString targetPath = QDir::cleanPath(QFileInfo(entry.targetPath).absoluteFilePath());

        if (sourcePath == targetPath)
            continue;

        const QFileInfo targetInfo(targetPath);

        if (!targetInfo.exists())
            continue;

        if (!sourceIndices.contains(targetPath))
        {
            return QStringLiteral("Target file already exists: %1").arg(targetPath);
        }
    }

    return {};
}

bool FileRenamer::isSafeRelativePath(const QString& relativePath) const
{
    if (relativePath.isEmpty())
        return false;

    const QFileInfo pathInfo(relativePath);

    if (pathInfo.isAbsolute())
        return false;

    const QString cleanedPath = QDir::cleanPath(relativePath);

    if (cleanedPath == QStringLiteral(".."))
        return false;

    if (cleanedPath.startsWith(QStringLiteral("../")))
        return false;

    if (cleanedPath.contains(QStringLiteral("/../")))
        return false;

#ifdef Q_OS_WIN
    if (QDir::isAbsolutePath(cleanedPath))
        return false;
#endif

    return true;
}

BatchOperationResult FileRenamer::isSourceFileValid(const AudioFileRecord& file) const
{
    if (file.filePath.isEmpty())
        return {
            BatchOperationState::Fail,
            QStringLiteral("Source file path cannot be empty")
        };

    const QFileInfo sourceInfo(file.filePath);

    if (!sourceInfo.exists() || !sourceInfo.isFile())
        return {
            BatchOperationState::Fail,
            QStringLiteral("Source file does not exist: %1").arg(file.filePath)
        };
}

QVariantList FileRenamer::preview(const QVector<AudioFileRecord>& files, QString* error) const
{
    QVector<RenamePlanEntry> plan;

    if (!buildPlan(files, &plan, error))
        return {};

    QVariantList result;
    for (const auto& entry : plan)
    {
        result.append(QVariantMap{
            {QStringLiteral("sourcePath"), entry.sourcePath}, {QStringLiteral("targetPath"), entry.targetPath}
        });
    }

    return result;
}


/**
 * @brief Builds a rename plan and resolves duplicate target paths.
 * @param files Files to process.
 * @param plan Receives the validated rename plan.
 * @param error Receives the error description.
 * @return true when the plan is valid.
 */
bool FileRenamer::buildPlan(const QVector<AudioFileRecord>& files, QVector<RenamePlanEntry>* plan, QString* error) const
{
    const auto fail = [error](const QString& message)
    {
        if (error)
            *error = message;
        return false;
    };

    plan->clear();

    if (!m_template.valid)
        return fail(m_template.errorMessage);

    if (m_baseDirectory.isEmpty())
        return fail(QStringLiteral("Base directory cannot be empty"));

    QSet<QString> sourcePaths;

    for (const auto& file : files)
    {
        if (file.filePath.isEmpty())
            return fail(QStringLiteral("Source file path cannot be empty"));

        const QFileInfo sourceInfo(file.filePath);
        if (!sourceInfo.exists() || !sourceInfo.isFile())
            return fail(QStringLiteral("Source file does not exist: %1").arg(file.filePath));

        const QString relativeTarget = buildTargetPath(file);
        if (relativeTarget.isEmpty())
            return fail(QStringLiteral("Generated target path is empty for: %1").arg(file.filePath));

        if (!isSafeRelativePath(relativeTarget))
            return fail(QStringLiteral("Generated target path escapes base directory: %1").arg(relativeTarget));

        const QString absoluteSource = QDir::cleanPath(sourceInfo.absoluteFilePath());
        sourcePaths.insert(absoluteSource);
        plan->append({absoluteSource, QDir(m_baseDirectory).filePath(relativeTarget)});
    }

    const auto pathKey = [](const QString& path)
    {
        const QString normalized = QDir::cleanPath(QFileInfo(path).absoluteFilePath());
#ifdef Q_OS_WIN
        return normalized.toCaseFolded();
#else
        return normalized;
#endif
    };

    QHash<QString, qsizetype> targetCounts;
    for (const auto& entry : *plan)
        ++targetCounts[pathKey(entry.targetPath)];

    for (auto& entry : *plan)
    {
        if (targetCounts.value(pathKey(entry.targetPath)) < 2)
            continue;

        const QFileInfo sourceInfo(entry.sourcePath);
        entry.targetPath = QDir(QFileInfo(entry.targetPath).absolutePath()).filePath(sourceInfo.fileName());
    }

    QSet<QString> reservedTargets;

    for (auto& entry : *plan)
    {
        const QFileInfo targetInfo(entry.targetPath);
        const QString directory = targetInfo.absolutePath();
        const QString baseName = targetInfo.completeBaseName();
        const QString suffix = targetInfo.suffix();

        const auto makeCandidate = [&](const QString& name)
        {
            const QString fileName = suffix.isEmpty()
                                         ? name
                                         : name + QStringLiteral(".") + suffix;
            return QDir(directory).filePath(fileName);
        };

        const auto isAvailable = [&](const QString& candidate)
        {
            const QString key = pathKey(candidate);
            const bool occupiedByAnotherTarget = reservedTargets.contains(key);
            const bool occupiedByUnrelatedFile = QFileInfo::exists(candidate)
                && !sourcePaths.contains(key);

            return !occupiedByAnotherTarget && !occupiedByUnrelatedFile;
        };

        const QString originalCandidate = entry.targetPath;
        if (!isAvailable(originalCandidate))
        {
            qsizetype number = 1;
            QString candidate;

            do
            {
                candidate = makeCandidate(QStringLiteral("%1 (%2)").arg(baseName).arg(number++));
            }
            while (!isAvailable(candidate));

            entry.targetPath = candidate;
        }

        reservedTargets.insert(pathKey(entry.targetPath));
    }

    if (const QString validationError = validatePlan(*plan); !validationError.isEmpty())
        return fail(validationError);

    if (error)
        error->clear();

    return true;
}
