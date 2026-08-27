#include <QtQuickTest>
#include <QtQml/QQmlExtensionPlugin>

/**
 * @brief Imports the generated AudioLibrarian QML plugin.
 *
 * This is required so that QML tests can instantiate QML_ELEMENT types
 * such as AudioFileTableModel, PlayerController and SettingsManager.
 */
Q_IMPORT_QML_PLUGIN(AudioLibrarianPlugin)

/**
 * @brief Entry point for the QML test suite.
 *
 * QUICK_TEST_MAIN discovers tst_*.qml files in QUICK_TEST_SOURCE_DIR.
 */
QUICK_TEST_MAIN(AudioLibrarianTests)