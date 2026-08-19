import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Audio library view.
 *
 * Displays a static list of audio files for the first UI vertical slice.
 *
 * The local ListModel is temporary. It will later be replaced with a
 * C++ QAbstractListModel representing the actual audio library.
 */
Item {
    id: root

    signal fileSelected(
        string fileName,
        string artist,
        string album,
        string genre,
        int year,
        string duration
    )

    /**
     * @brief Index of the currently selected file.
     */
    property int selectedIndex: -1

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

    /**
     * @brief Selects an item and emits its metadata.
     *
     * @param index Index of the item in libraryModel.
     */
    function selectFile(index) {
        if (index < 0 || index >= libraryModel.count)
            return

        const item = libraryModel.get(index)

        root.selectedIndex = index

        root.fileSelected(
            item.fileName,
            item.artist,
            item.album,
            item.genre,
            item.year,
            item.duration
        )
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

            objectName: "fileList"

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

                selected: index === root.selectedIndex

                onActivated: root.selectFile(index)
            }
        }
    }

    /**
     * Select the first file when the mock library is initialized.
     *
     * This gives the tag editor useful content immediately after startup.
     */
    Component.onCompleted: {
        selectFile(0)
    }
}