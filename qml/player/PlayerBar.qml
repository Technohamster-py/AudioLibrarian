import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Minimal audio player control bar.
 *
 * This component represents the UI contract of the future audio player.
 * It contains only local mock state; actual playback will later be
 * provided by a C++ audio service.
 */
Item {
    id: root
    //TODO: Implement audio service
    property bool playing: false
    property real progress: 0.35

    Rectangle {
        anchors.fill: parent
        color: AppColors.playerBackground

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8

            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 32

                AppToolButton {
                    objectName: "previousButton"

                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 32

                    iconText: "◀" //TODO: find a real svg
                    tooltipText: qsTr("Previous")

                    onClicked: root.progress = 0
                }

                AppToolButton {
                    objectName: "playPauseButton"

                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 32

                    iconText: root.playing ? "Ⅱ" : "▶" //TODO: find a real svg

                    tooltipText: root.playing
                        ? qsTr("Pause")
                        : qsTr("Play")

                    onClicked: root.playing = !root.playing
                }

                AppToolButton {
                    objectName: "nextButton"

                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 32

                    iconText: "▶" //TODO: find a real svg
                    tooltipText: qsTr("Next")

                    onClicked: root.progress = 0
                }

                Label {
                    Layout.fillWidth: true

                    text: qsTr("Example Artist — Example Track")

                    color: AppColors.playerForeground

                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Slider {
                id: progressSlider

                Layout.fillWidth: true

                from: 0
                to: 1

                value: root.progress

                onMoved: root.progress = value
            }
        }
    }
}
