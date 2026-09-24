#include "filerenamer.h"

#include <QFile>
#include <QFileInfo>
#include <QHash>
#include <QSet>

FileRenamer::FileRenamer(const QString& templatePattern, const QString& baseDirectory, QObject *parent): AbstractBatchOperation(parent), m_template(RenameTemplateParser::parse(templatePattern)), m_baseDirectory(QDir(baseDirectory).absolutePath()){
}

BatchOperationResult FileRenamer::execute(const QVector<AudioFileRecord> &files,const std::atomic_bool &cancellationRequested){
    if (!m_template.valid)
        return {
            BatchOperationState::Fail,
            m_template.errorMessage
        };

    if (m_baseDirectory.isEmpty())
        return {
            BatchOperationState::Fail,
        QStringLiteral("Base directory cannot be empty")
        };

    if (files.isEmpty())
        return {
            BatchOperationState::Success,
            {}
        };

    QVector<RenamePlanEntry> plan;
    plan.reserve(files.size());

    for (const auto &file : files) {
        if (cancellationRequested.load())
            return {
                BatchOperationState::Cancelled,
                {}
            };

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

        const QString relativeTarget = buildTargetPath(file);

        if (relativeTarget.isEmpty())
            return {
                BatchOperationState::Fail,
                QStringLiteral("Generated target path is empty for: %1").arg(file.filePath)
            };

        if (!isSafeRelativePath(relativeTarget))
            return {
                BatchOperationState::Fail,
                QStringLiteral("Generated target path escapes base directory: %1").arg(relativeTarget)
            };

        RenamePlanEntry entry;
        entry.sourcePath = sourceInfo.absoluteFilePath();
        entry.targetPath = QDir(m_baseDirectory).filePath(relativeTarget);

        plan.append(std::move(entry));
    }

    if (const QString validationError = validatePlan(plan);
        !validationError.isEmpty()) {
        return {
            BatchOperationState::Fail,
            validationError
        };
    }

    const qsizetype total = plan.size();

    for (qsizetype index = 0; index < total; ++index) {
        if (cancellationRequested.load())
            return {
                BatchOperationState::Cancelled,
                {}
            };

        const auto &entry = plan.at(index);

        const QFileInfo targetInfo(entry.targetPath);
        const QString targetDirectory = targetInfo.absolutePath();

        if (!QDir().mkpath(targetDirectory)) {
            return {
                BatchOperationState::Fail,
                QStringLiteral("Failed to create directory: %1").arg(targetDirectory)
            };
        }

        if (!QFile::rename(entry.sourcePath, entry.targetPath)) {
            return {
                BatchOperationState::Fail,
                QStringLiteral("Failed to rename '%1' to '%2'").arg(entry.sourcePath, entry.targetPath)
            };
        }

        reportProgress(index + 1, total, QStringLiteral("Renaming files"), entry.targetPath);
    }

    return {
        BatchOperationState::Success,
        {}
    };
}

QString FileRenamer::buildTargetPath(const AudioFileRecord &file) const{
    QString path;

    for (const auto &token : m_template.tokens) {
        if (token.type == RenameTemplateParser::Token::Type::Literal) {
            path.append(token.value);
            continue;
        }

        path.append(fieldValue(file, token.field));
    }

    const QFileInfo sourceInfo(file.filePath);

    if (!sourceInfo.suffix().isEmpty()) {
        path += QStringLiteral(".") + sourceInfo.suffix();
    }

    return QDir::cleanPath(path);
}

QString FileRenamer::fieldValue(const AudioFileRecord &file, const RenameTemplateParser::Field field) const {
    const auto &metadata = file.fileInfo.metadata;

    switch (field) {
        case RenameTemplateParser::Field::Title: return metadata.title();
        case RenameTemplateParser::Field::Artist: return metadata.artist();
        case RenameTemplateParser::Field::Album: return metadata.album();
        case RenameTemplateParser::Field::AlbumArtist:return metadata.albumArtist();
        case RenameTemplateParser::Field::Genre: return metadata.genre();
        case RenameTemplateParser::Field::Date: return metadata.date();
        case RenameTemplateParser::Field::TrackNumber: return metadata.trackNumber();
        case RenameTemplateParser::Field::DiscNumber: return metadata.discNumber();
        case RenameTemplateParser::Field::FileName: return QFileInfo(file.filePath).completeBaseName();
    }

    return {};
}

QString FileRenamer::validatePlan(const QVector<RenamePlanEntry> &plan) const {
    QHash<QString, qsizetype> sourceIndices;
    QSet<QString> targetPaths;

    for (qsizetype index = 0; index < plan.size(); ++index) {
        const auto &entry = plan.at(index);
        const QString sourcePath = QDir::cleanPath(QFileInfo(entry.sourcePath).absoluteFilePath());
        const QString targetPath = QDir::cleanPath(QFileInfo(entry.targetPath).absoluteFilePath());

        if (sourcePath == targetPath)
            continue;

        if (targetPaths.contains(targetPath)) {
            return QStringLiteral("Multiple files have the same target path: %1").arg(targetPath);
        }

        targetPaths.insert(targetPath);
        sourceIndices.insert(sourcePath, index);
    }

    for (const auto &entry : plan) {
        const QString sourcePath = QDir::cleanPath(QFileInfo(entry.sourcePath).absoluteFilePath());
        const QString targetPath = QDir::cleanPath(QFileInfo(entry.targetPath).absoluteFilePath());

        if (sourcePath == targetPath)
            continue;

        const QFileInfo targetInfo(targetPath);

        if (!targetInfo.exists())
            continue;

        if (!sourceIndices.contains(targetPath)) {
            return QStringLiteral("Target file already exists: %1").arg(targetPath);
        }
    }

    return {};
}

bool FileRenamer::isSafeRelativePath(const QString &relativePath) const {
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