import QtQuick
import AudioLibrarian

/**
 * @brief Entry point of the AudioLibrarian QML application.
 *
 * The main window itself is implemented by MainWindow.
 * Keeping this file minimal makes it possible to change
 * application initialization without touching the UI structure.
 */
MainWindow {
    Component.onCompleted: {
        Qt.uiLanguage = SettingsManager.language === "system" ? Qt.locale().name : SettingsManager.language
    }

    Connections {
        target: SettingsManager

        function onLanguageChanged(value) {
            Qt.uiLanguage = value === "system" ? Qt.locale().name : value
        }
    }
}
