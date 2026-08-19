import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Main application window.
 *
 * The window consists of three logical areas:
 *
 * - NavigationBar: global application navigation;
 * - LibraryPane: currently visible library and audio player;
 * - EditorView: editor associated with the selected library item.
 *
 * LibraryPane and EditorView are separated by a draggable SplitView handle.
 *
 * The currently selected audio file is represented by simple properties
 * for this UI-only vertical slice. They will later be replaced by a
 * C++-based selection/model mechanism.
 */
ApplicationWindow {
    id: root

    width: 1440
    height: 900

    minimumWidth: 960
    minimumHeight: 600

    visible: true
    title: qsTr("AudioLibrarian")

    color: AppColors.background

    /**
     * @brief Currently selected audio file metadata.
     *
     * This is deliberately kept in the window for now because there is
     * no C++ model yet. Later the selection will belong to the library
     * model/controller rather than MainWindow.
     */
    property string selectedFileName: ""
    property string selectedArtist: ""
    property string selectedAlbum: ""
    property string selectedGenre: ""
    property int selectedYear: 0
    property string selectedDuration: ""

    RowLayout {
        anchors.fill: parent
        spacing: 0

        NavigationBar {
            objectName: "navigationBar"

            Layout.fillHeight: true
            Layout.preferredWidth: AppMetrics.navigationBarWidth
        }

        SplitView {
            id: mainSplitView

            objectName: "mainSplitView"

            Layout.fillWidth: true
            Layout.fillHeight: true

            orientation: Qt.Horizontal

            handle: Rectangle {
                implicitWidth: 1

                color: SplitHandle.pressed
                    ? AppColors.accent
                    : AppColors.separator
            }

            LibraryPane {
                id: libraryPane

                objectName: "libraryPane"

                SplitView.preferredWidth: AppMetrics.libraryWidth
                SplitView.minimumWidth: AppMetrics.libraryMinimumWidth
                SplitView.maximumWidth: AppMetrics.libraryMaximumWidth

                /**
                 * Propagate the selected file from the library to the
                 * application window.
                 */
                onFileSelected: function(fileName, artist, album, genre,
                                         year, duration) {
                    root.selectedFileName = fileName
                    root.selectedArtist = artist
                    root.selectedAlbum = album
                    root.selectedGenre = genre
                    root.selectedYear = year
                    root.selectedDuration = duration
                }
            }

            EditorView {
                id: editorView

                objectName: "editorView"

                SplitView.fillWidth: true

                fileName: root.selectedFileName
                artist: root.selectedArtist
                album: root.selectedAlbum
                genre: root.selectedGenre
                year: root.selectedYear
                duration: root.selectedDuration
            }
        }
    }
}