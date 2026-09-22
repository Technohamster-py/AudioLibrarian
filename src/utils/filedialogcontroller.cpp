#include "filedialogcontroller.h"

#include <QFileDialog>

/**
 * @brief Constructs the native file dialog controller.
 *
 * @param parent QObject parent.
 */
FileDialogController::FileDialogController(QObject *parent)
    : QObject(parent) {
}

/**
 * @brief Opens the native directory selection dialog.
 *
 * @param title Dialog title.
 * @param initialDirectory Initial directory shown by the dialog.
 * @return Selected directory path or an empty string if the dialog was cancelled.
 */
QString FileDialogController::getExistingDirectory(const QString &title, const QString &initialDirectory) {
    return QFileDialog::getExistingDirectory(nullptr, title, initialDirectory);
}