import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Structural and integration tests for MainWindow.
 *
 * The tests verify the composition of the first UI vertical slice and
 * the propagation of library selection into the tag editor.
 */
TestCase {
    id: testCase

    name: "MainWindow"

    Component {
        id: component

        MainWindow {
            visible: false
        }
    }

    function test_window_is_created() {
        const window = createTemporaryObject(component, testCase)

        verify(window !== null)

        verify(window.minimumWidth > 0)
        verify(window.minimumHeight > 0)
    }

    function test_main_split_view_has_two_panes() {
        const window = createTemporaryObject(component, testCase)
        const splitView = findChild(window, "mainSplitView")

        verify(splitView !== null)
        compare(splitView.count, 2)
    }

    function test_main_sections_are_present() {
        const window = createTemporaryObject(component, testCase)

        verify(findChild(window, "navigationBar") !== null)
        verify(findChild(window, "libraryPane") !== null)
        verify(findChild(window, "editorView") !== null)
    }

    function test_first_library_file_is_selected() {
        const window = createTemporaryObject(component, testCase)

        compare(
            window.selectedFileName,
            "01 - Example Song.flac"
        )

        compare(
            window.selectedArtist,
            "Example Artist"
        )

        compare(
            window.selectedAlbum,
            "Example Album"
        )
    }

    function test_selection_is_propagated_to_editor() {
        const window = createTemporaryObject(component, testCase)

        const libraryView = findChild(window, "libraryView")
        const editorView = findChild(window, "editorView")

        verify(libraryView !== null)
        verify(editorView !== null)

        libraryView.selectFile(1)

        compare(
            editorView.fileName,
            "02 - Another Song.mp3"
        )

        compare(
            editorView.artist,
            "Another Artist"
        )

        compare(
            editorView.album,
            "Another Album"
        )

        compare(
            editorView.genre,
            "Rock"
        )

        compare(
            editorView.year,
            2025
        )
    }
}