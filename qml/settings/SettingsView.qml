import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
/**
 * @brief Application settings page.
 *
 * Provides the user-facing interface for persistent application settings.
 *
 * Internal application state such as window geometry and splitter position
 * is intentionally not exposed here.
 */
Item {
    id: root

    Rectangle {
        anchors.fill: parent

        color: AppColors.settingsBackground

        ScrollView {
            anchors.fill: parent

            clip: true

            ColumnLayout {
                width: Math.min(
                    parent.width - AppMetrics.spacingLarge * 2,
                    900
                )

                anchors.horizontalCenter: parent.horizontalCenter

                spacing: AppMetrics.spacingLarge

                Label {
                    text: qsTr("Settings")

                    color: AppColors.settingsTextPrimary

                    font.pixelSize: 28
                    font.bold: true
                }

                Label {
                    text: qsTr("General")

                    color: AppColors.settingsTextPrimary

                    font.pixelSize: 20
                    font.bold: true

                    Layout.topMargin: AppMetrics.spacingMedium
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1

                    color: AppColors.settingsSeparator
                }

                SettingsRow {
                    Layout.fillWidth: true

                    title: qsTr("Language")
                    description: qsTr(
                        "Language used by the application interface."
                    )

                    ComboBox {
                        Layout.fillWidth: true

                        model: [
                            {
                                text: qsTr("System"),
                                value: "system"
                            },
                            {
                                text: qsTr("English"),
                                value: "en"
                            },
                            {
                                text: qsTr("Russian"),
                                value: "ru"
                            }
                        ]

                        currentIndex: {
                            const value = SettingsManager.language

                            for (let i = 0; i < model.length; ++i) {
                                if (model[i].value === value)
                                    return i
                            }

                            return 0
                        }

                        onActivated: {
                            SettingsManager.language = model[currentIndex].value
                        }
                    }
                }

                SettingsRow {
                    Layout.fillWidth: true

                    title: qsTr("Theme")
                    description: qsTr(
                        "Appearance of the application interface."
                    )

                    ComboBox {
                        Layout.fillWidth: true

                        model: [
                            {
                                text: qsTr("Dark"),
                                value: "dark"
                            },
                            {
                                text: qsTr("Light"),
                                value: "light"
                            }
                        ]

                        currentIndex: {
                            const value = SettingsManager.theme

                            for (let i = 0; i < model.length; ++i) {
                                if (model[i].value === value)
                                    return i
                            }

                            return 0
                        }

                        onActivated: {
                            SettingsManager.theme = model[currentIndex].value
                        }
                    }
                }

                SettingsRow {
                    Layout.fillWidth: true

                    title: qsTr("Library default directory")
                    description: qsTr(
                        "Directory used as the default root of the music library."
                    )

                    RowLayout {
                        Layout.fillWidth: true

                        TextField {
                            id: baseDirField

                            Layout.fillWidth: true

                            text: SettingsManager.baseDir

                            readOnly: true
                        }

                        Button {
                            text: qsTr("Browse...")

                            onClicked: directoryDialog.open()
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }

    FolderDialog {
        id: directoryDialog

        title: qsTr("Select library directory")

        onAccepted: {
            SettingsManager.baseDir = selectedFolder.toLocalFile()
        }
    }
}
