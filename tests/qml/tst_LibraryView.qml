import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for the static library view.
 */
TestCase {
    name: "LibraryView"

    Component {
        id: component

        LibraryView {
            width: 800
            height: 600
        }
    }

    function test_library_is_created() {
        const view = createTemporaryObject(component, null)

        verify(view !== null)
    }

    function test_mock_model_contains_expected_files() {
        const view = createTemporaryObject(component, null)
        const model = findChild(view, "libraryModel")

        verify(model !== null)
        compare(model.count, 3)
    }
}