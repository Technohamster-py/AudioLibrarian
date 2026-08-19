import QtQuick
import QtQuick.Layouts

/**
 * @brief Left workspace pane containing the library and player.
 *
 * The pane represents the part of the application responsible for
 * browsing and selecting audio files.
 *
 * The player is deliberately placed below the library because it is
 * visually and functionally associated with the currently browsed
 * collection.
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

    implicitWidth: AppMetrics.libraryWidth

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        LibraryView {
            id: libraryView

            objectName: "libraryView"

            Layout.fillWidth: true
            Layout.fillHeight: true

            onFileSelected: function(fileName, artist, album, genre,
                                     year, duration) {
                root.fileSelected(
                    fileName,
                    artist,
                    album,
                    genre,
                    year,
                    duration
                )
            }
        }

        PlayerBar {
            objectName: "playerBar"

            Layout.fillWidth: true
            Layout.preferredHeight: AppMetrics.playerHeight
        }
    }
}