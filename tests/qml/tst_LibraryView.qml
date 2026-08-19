import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for the library view.
 */
TestCase {
    id: testCase

    name: "LibraryView"

    Component {
        id: component

        LibraryView {
            width: 800
            height: 600
        }
    }

    function test_library_is_created() {
        const view = createTemporaryObject(component, testCase)

        verify(view !== null)
    }

    function test_mock_model_contains_expected_files() {
        const view = createTemporaryObject(component, testCase)
        const model = findChild(view, "libraryModel")

        verify(model !== null)
        compare(model.count, 3)
    }

    function test_first_file_is_selected() {
        const view = createTemporaryObject(component, testCase)

        compare(view.selectedIndex, 0)
    }

    function test_select_file() {
        const view = createTemporaryObject(component, testCase)
        const spy = signalSpy(view, "fileSelected")

        view.selectFile(1)

        compare(view.selectedIndex, 1)
        compare(spy.count, 1)

        compare(spy.signalArguments[0][0], "02 - Another Song.mp3")
        compare(spy.signalArguments[0][1], "Another Artist")
        compare(spy.signalArguments[0][2], "Another Album")
    }

    function test_invalid_selection_is_ignored() {
        const view = createTemporaryObject(component, testCase)
        const spy = signalSpy(view, "fileSelected")

        view.selectFile(-1)

        compare(view.selectedIndex, 0)
        compare(spy.count, 1)

        view.selectFile(100)

        compare(view.selectedIndex, 0)
        compare(spy.count, 1)
    }
}