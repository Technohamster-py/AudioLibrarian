import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Static library mockup used by the first UI vertical slice.
 *
 * The model is intentionally a local ListModel. It will later be replaced
 * with a C++ QAbstractListModel representing actual audio files.
 */
Item {
    id: root
    //TODO: Replace with a C++ QAbstractListModel
    ListModel {
        id: libraryModel

        objectName: "libraryModel"

        ListElement {
            fileName: "01 - Example Song.flac"
            artist: "Example Artist"
            album: "Example Album"
            year: 2026
            duration: "03:42"
        }

        ListElement {
            fileName: "02 - Another Song.mp3"
            artist: "Another Artist"
            album: "Another Album"
            year: 2025
            duration: "04:18"
        }

        ListElement {
            fileName: "03 - Third Song.ogg"
            artist: "Third Artist"
            album: "Third Album"
            year: 2024
            duration: "05:07"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppMetrics.spacingLarge

        spacing: AppMetrics.spacingMedium

        Label {
            Layout.fillWidth: true

            text: qsTr("Library")

            color: AppColors.textPrimary
            font.pixelSize: 28
        }

        Label {
            Layout.fillWidth: true

            text: qsTr("%1 files").arg(libraryModel.count)

            color: AppColors.textSecondary
        }

        Rectangle {
            Layout.fillWidth: true

            height: 1
            color: AppColors.separator
        }

        ListView {
            id: fileList

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            spacing: 2

            model: libraryModel

            delegate: AudioFileDelegate {
                width: fileList.width
                height: 56

                fileName: model.fileName
                artist: model.artist
                album: model.album
                year: model.year
                duration: model.duration

                onActivated: {
                    console.log("Selected:", fileName)
                }
            }
        }
    }
}