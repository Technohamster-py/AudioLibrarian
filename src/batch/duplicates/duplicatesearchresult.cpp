#include "duplicatesearchresult.h"

qsizetype DuplicateSearchResult::duplicateFileCount() const {
    qsizetype count = 0;

    for (const DuplicateGroup &group : groups)
        count += group.files.size();

    return count;
}

qsizetype DuplicateSearchResult::removableFileCount() const {
    qsizetype count = 0;

    for (const DuplicateGroup &group : groups)
        count += qMax<qsizetype>(0, group.files.size() - 1);

    return count;
}
