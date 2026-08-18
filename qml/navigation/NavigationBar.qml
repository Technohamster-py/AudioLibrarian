import QtQuick
import QtQuick.Layouts

/**
 * @brief Narrow global navigation bar.
 *
 * Each button represents a top-level application section. The actual
 * navigation state is intentionally local for now and will later be
 * connected to a navigation model.
 */
Item {
    id: root

    signal sectionSelected(string section)

    Rectangle {
        anchors.fill: parent
        color: AppColors.navigationBar

        ColumnLayout {
            anchors.fill: parent

            anchors.topMargin: 6
            anchors.bottomMargin: 6

            spacing: 2

            AppToolButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 48

                icon: "▣" //TODO: find a real svg
                tooltipText: qsTr("Files")

                onClicked: root.sectionSelected("files")
            }

            AppToolButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 48

                icon: "●" //TODO: find a real svg
                tooltipText: qsTr("Albums")

                onClicked: root.sectionSelected("albums")
            }

            AppToolButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 48

                icon: "≡" //TODO: find a real svg
                tooltipText: qsTr("Artists")

                onClicked: root.sectionSelected("artists")
            }

            AppToolButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 48

                icon: "♫" //TODO: find a real svg
                tooltipText: qsTr("Playlists")

                onClicked: root.sectionSelected("playlists")
            }

            AppToolButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 48

                icon: "◉" //TODO: find a real svg
                tooltipText: qsTr("Duplicates")

                onClicked: root.sectionSelected("duplicates")
            }

            Item {
                Layout.fillHeight: true
            }

            AppToolButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 48

                icon: "⚙" //TODO: find a real svg
                tooltipText: qsTr("Settings")

                onClicked: root.sectionSelected("settings")
            }
        }
    }
}