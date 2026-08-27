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

    required property PlayerController player

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

                    iconSource: AppAssets.backward
                    tooltipText: qsTr("Previous")
                    onClicked: root.progress = 0
                }

                AppToolButton {
                    objectName: "playPauseButton"

                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 32

                    iconSource: root.player.playing ? AppAssets.pause : AppAssets.play
                    tooltipText: root.player.playing ? qsTr("Pause") : qsTr("Play")
                    onClicked: root.player.togglePlayback()
                }

                AppToolButton {
                    objectName: "nextButton"

                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 32

                    iconSource: AppAssets.forward
                    tooltipText: qsTr("Next")
                    onClicked: root.progress = 0
                }

                Label {
                    Layout.fillWidth: true

                    text: {
                        if (root.player.artist.length > 0 && root.player.title.length > 0) {
                            return root.player.artist + " - " + root.player.title
                        }

                        if (root.player.title.length > 0) {
                            return root.player.title
                        }

                        return qsTr("No track selected")
                    }

                    color: AppColors.playerForeground

                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Slider {
                id: progressSlider

                Layout.fillWidth: true

                from: 0
                to: root.player.duration

                value: root.player.position

                onMoved: root.player.position = value
            }
        }
    }
}
