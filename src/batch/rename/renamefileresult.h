#pragma once

struct RenameFileResult {
    QString sourcePath;
    QString targetPath;
    bool success = false;
    QString errorMessage;
};