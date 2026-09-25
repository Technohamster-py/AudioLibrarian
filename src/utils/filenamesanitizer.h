#pragma once

#include <QString>

/**
 * @brief Sanitizes a single filesystem name component.
 *
 * The sanitizer removes characters that cannot be used in Windows filenames,
 * replaces control characters and prevents reserved Windows device names.
 *
 * Path separators are treated as invalid characters here. The sanitizer
 * operates on one path component and must not be used on a complete path.
 */
class FilenameSanitizer
{
public:
    /**
     * @brief Sanitizes one filename or directory name.
     *
     * @param value Original name component.
     * @return Filesystem-safe name component.
     */
    [[nodiscard]] static QString sanitize(const QString &value);

private:
    /**
     * @brief Checks whether a name is reserved by Windows.
     *
     * @param name Name without extension.
     * @return true when the name is a reserved Windows device name.
     */
    [[nodiscard]] static bool isReservedName(const QString &name);
};