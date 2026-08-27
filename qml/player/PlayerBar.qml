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

    /**
     * @brief Formats milliseconds as MM:SS or HH:MM:SS.
     *
     * @param milliseconds Duration in milliseconds.
     * @return Formatted time string.
     */
    function formatTime(milliseconds) {
        if (milliseconds <= 0)
            return "00:00"

        const totalSeconds = Math.floor(milliseconds / 1000)
        const seconds = totalSeconds % 60
        const totalMinutes = Math.floor(totalSeconds / 60)
        const minutes = totalMinutes % 60
        const hours = Math.floor(totalMinutes / 60)

        const paddedSeconds = seconds.toString().padStart(2, "0")

        const paddedMinutes = minutes.toString().padStart(2, "0")

        if (hours > 0) {
            const paddedHours = hours.toString().padStart(2, "0")
            return paddedHours + ":" + paddedMinutes + ":" + paddedSeconds
        }
        return paddedMinutes + ":" + paddedSeconds
    }

    Rectangle {
        anchors.fill: parent
        color: AppColors.playerBackground

        RowLayout {
            anchors.fill: parent
            anchors.margins: AppMetrics.spacingMedium

            Image {
                id: coverImage

                Layout.preferredWidth: parent.height
                Layout.preferredHeight: parent.height

                fillMode: Image.PreserveAspectFit

                source: root.player.coverUrl

                asynchronous: true
                cache: false

                visible: source.toString().length > 0
            }

            Rectangle {
                Layout.preferredWidth: coverImage.width
                Layout.preferredHeight: coverImage.height

                visible: !coverImage.visible

                color: AppColors.background

                Image {
                    anchors.centerIn: parent

                    width: parent.width * 0.45
                    height: parent.height * 0.45

                    source: AppAssets.music

                    fillMode: Image.PreserveAspectFit
                }
            }


            ColumnLayout {
                anchors.margins: 8

                spacing: AppMetrics.spacingSmall

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: AppMetrics.iconButtonSize

                    AppToolButton {
                        objectName: "previousButton"

                        Layout.preferredWidth: AppMetrics.iconButtonSize - AppMetrics.spacingMedium
                        Layout.preferredHeight: AppMetrics.iconButtonSize - AppMetrics.spacingMedium

                        iconSource: AppAssets.backward
                        tooltipText: qsTr("Previous")

                        /*
                         * Previous-track functionality is not implemented yet.
                         */
                        enabled: false
                    }

                    AppToolButton {
                        objectName: "playPauseButton"

                        Layout.preferredWidth: AppMetrics.iconButtonSize
                        Layout.preferredHeight: AppMetrics.iconButtonSize

                        iconSource: root.player.playing ? AppAssets.pause : AppAssets.play
                        tooltipText: root.player.playing ? qsTr("Pause") : qsTr("Play")
                        onClicked: root.player.togglePlayback()
                    }

                    AppToolButton {
                        objectName: "nextButton"

                        Layout.preferredWidth: AppMetrics.iconButtonSize - AppMetrics.spacingMedium
                        Layout.preferredHeight: AppMetrics.iconButtonSize - AppMetrics.spacingMedium

                        iconSource: AppAssets.forward
                        tooltipText: qsTr("Next")

                        /*
                         * Next-track functionality is not implemented yet.
                         */
                        enabled: false
                    }

                    /**
                     * Title and artist label
                     */
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

                    Item {
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignVCenter

                        spacing: AppMetrics.spacingSmall

                        AppToolButton {
                            objectName: "muteButton"
                            Layout.preferredWidth: AppMetrics.iconButtonSize - AppMetrics.spacingLarge

                            iconSource: root.player.muted ? AppAssets.mute : AppAssets.unmute
                            tooltipText: root.player.muted ? qsTr("Unmute") : qsTr("Mute")
                            onClicked: {
                                root.player.muted = !root.player.muted
                            }
                        }

                        Slider {
                            id: volumeSlider
                            objectName: "volumeSlider"

                            Layout.preferredWidth: 100

                            from: 0
                            to: 100

                            value: root.player.volume
                            onMoved: {
                                root.player.volume = Math.round(value)
                            }
                        }
                    }
                }



                // /**
                //  * Album label
                //  */
                // Label {
                //     Layout.fillWidth: true
                //     text: root.player.album
                //     color: AppColors.playerForeground
                //
                //     opacity: 0.75
                //
                //     elide: Text.ElideRight
                //     verticalAlignment: Text.AlignVCenter
                //
                //     visible: text.length > 0
                // }

                Item {
                    Layout.fillHeight: true
                }

                /**
                 * Progress
                 */
                RowLayout {
                    Layout.fillWidth: true
                    spacing: AppMetrics.spacingMedium

                    Label {
                        text: formatTime(root.player.position)
                        color: AppColors.playerForeground

                        Layout.preferredWidth: implicitWidth
                        horizontalAlignment: Text.AlignRight
                    }

                    Slider {
                        id: progressSlider

                        Layout.fillWidth: true

                        from: 0
                        to: root.player.duration

                        value: root.player.position

                        onMoved: root.player.position = value
                    }

                    Label {
                        text: formatTime(root.player.duration)
                        color: AppColors.playerForeground

                        Layout.preferredWidth: implicitWidth
                        horizontalAlignment: Text.AlignLeft
                    }
                }
            }
        }
    }
}
