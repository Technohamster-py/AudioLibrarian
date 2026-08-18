import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Contextual navigation view.
 *
 * Displays the current library navigation mode and a small mock file
 * hierarchy. The model is intentionally static until the C++ filesystem
 * model is introduced.
 */
Item {
    id: root

    property int selectedIndex: 0

    Rectangle {
        anchors.fill: parent
        color: AppColors.panel

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Label {
                Layout.fillWidth: true
                Layout.preferredHeight: 52

                leftPadding: AppMetrics.spacingLarge
                rightPadding: AppMetrics.spacingLarge

                text: qsTr("Navigation")
                color: AppColors.textPrimary
                font.pixelSize: 18

                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                Layout.fillWidth: true

                height: 1
                color: AppColors.separator
            }

            ListView {
                id: navigationList

                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true

                model: [
                    qsTr("Music"),
                    qsTr("Albums"),
                    qsTr("Artists"),
                    qsTr("Genres"),
                    qsTr("Playlists"),
                    qsTr("Filesystem")
                ]

                delegate: NavigationItem {
                    width: navigationList.width
                    height: AppMetrics.navigationItemHeight

                    text: modelData
                    selected: index === root.selectedIndex

                    onClicked: root.selectedIndex = index
                }
            }
        }
    }
}