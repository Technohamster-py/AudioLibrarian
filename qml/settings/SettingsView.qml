import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Application settings page.
 *
 * Provides the user-facing interface for persistent application settings.
 *
 * The page intentionally starts with general application settings.
 * Window geometry and other internal application state are managed by
 * SettingsManager but are not exposed as user-editable preferences.
 */
Item {
    id: root

    Rectangle {
        anchors.fill: parent

        color: AppColors.background

        ScrollView {
            anchors.fill: parent

            clip: true

            ColumnLayout {
                width: Math.min(
                    parent.width,
                    900
                )

                anchors.horizontalCenter: parent.horizontalCenter

                spacing: AppMetrics.spacingLarge

                Label {
                    text: qsTr("Settings")

                    color: AppColors.textPrimary

                    font.pixelSize: 28
                    font.bold: true
                }

                Label {
                    text: qsTr("General")

                    color: AppColors.textPrimary

                    font.pixelSize: 20
                    font.bold: true

                    Layout.topMargin: AppMetrics.spacingMedium
                }

                // General settings will be added here.
            }
        }
    }
}