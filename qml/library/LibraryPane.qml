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

    signal fileSelected(string filePath)

    implicitWidth: AppMetrics.libraryWidth

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        LibraryView {
            id: libraryView

            objectName: "libraryView"

            Layout.fillWidth: true
            Layout.fillHeight: true

            onFileSelected: function(filePath) {
                root.fileSelected(filePath)
            }
        }
    }
}