import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for LibraryView.
 *
 * LibraryView must use the real AudioFileTableModel rather than
 * constructing a temporary QML model.
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

    Component {
        id: signalSpyComponent

        SignalSpy {}
    }

    function test_library_is_created() {
        const view = createTemporaryObject(component, testCase)

        verify(view !== null)
    }

    function test_real_model_is_used() {
        const view = createTemporaryObject(component, testCase)

        const model = findChild(view, "libraryModel")

        verify(model !== null)

        verify(model instanceof AudioFileTableModel)
    }

    function test_model_has_expected_columns() {
        const view = createTemporaryObject(component, testCase)

        const model = findChild(view, "libraryModel")

        verify(model !== null)

        compare(model.columnCount(), AudioFileTableModel.ColumnCount)
    }

    function test_model_has_expected_roles() {
        const view = createTemporaryObject(component, testCase)

        const model = findChild(view, "libraryModel")

        verify(model !== null)

        compare(model.roleName(AudioFileTableModel.FileNameRole), "fileName")

        compare(model.roleName(AudioFileTableModel.TitleRole), "title")

        compare(model.roleName(AudioFileTableModel.ArtistRole), "artist")

        compare(model.roleName(AudioFileTableModel.AlbumRole), "album")

        compare(model.roleName(AudioFileTableModel.DurationRole), "duration")
    }

    function test_select_invalid_index_is_ignored() {
        const view = createTemporaryObject(component, testCase)

        const spy = createTemporaryObject(signalSpyComponent, testCase)

        spy.target = view
        spy.signalName = "fileSelected"

        view.selectFile(-1)

        compare(view.selectedIndex, -1)

        compare(spy.count, 0)

        view.selectFile(100000)

        compare(view.selectedIndex, -1)

        compare(spy.count, 0)
    }
}
