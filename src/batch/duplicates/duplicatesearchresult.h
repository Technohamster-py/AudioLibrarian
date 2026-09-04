#pragma once

#include "library/audiofilerecord.h"

#include <QByteArray>
#include <QString>
#include <QVector>

struct DuplicateFile
{
    QString filePath;
    qint64 fileSize = 0;
    QByteArray hash;
    AudioFileRecord record;
};

/**
 * @brief Represents one group of files with identical content.
 */
struct DuplicateGroup
{
    QVector<DuplicateFile> files;
};

/**
 * @brief Contains the result of an exact duplicate search.
 */
struct DuplicateSearchResult
{
    QVector<DuplicateGroup> groups;

    /**
     * @brief Returns the number of files participating in duplicate groups.
     */
    qsizetype duplicateFileCount() const;

    /**
     * @brief Returns the number of files that can be removed while keeping
     * one file from every duplicate group.
     */
    qsizetype removableFileCount() const;
};