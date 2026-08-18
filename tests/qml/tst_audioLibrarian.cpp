#include <QtQuickTest>
#include <QtQml/QQmlExtensionPlugin>

Q_IMPORT_QML_PLUGIN(AudioLibrarianPlugin)

/**
 * @brief Entry point for the QML test suite.
 *
 * QUICK_TEST_MAIN creates the C++ test harness and discovers tst_*.qml
 * files below QUICK_TEST_SOURCE_DIR.
 */
QUICK_TEST_MAIN(AudioLibrarianTests)