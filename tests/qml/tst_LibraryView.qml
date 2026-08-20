import QtQuick
import QtTest

import AudioLibrarian

/**
 * @brief Tests for the library view.
 *
 * LibraryView uses AudioFileTableModel directly. No temporary QML model
 * is created by the view.
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
        const view = createTemporaryObject(
            component,
            testCase
        )

        verify(view !== null)
    }

    function test_real_model_is_used() {
        const view = createTemporaryObject(
            component,
            testCase
        )

        const model = findChild(
            view,
            "libraryModel"
        )

        verify(model !== null)

        verify(
            model instanceof AudioFileTableModel
        )
    }

    function test_model_has_expected_columns() {
        const view = createTemporaryObject(
            component,
            testCase
        )

        const model = findChild(
            view,
            "libraryModel"
        )

        verify(model !== null)

        compare(
            model.columnCount(),
            AudioFileTableModel.ColumnCount
        )
    }

    function test_model_exposes_cover_role() {
        const view = createTemporaryObject(
            component,
            testCase
        )

        const model = findChild(
            view,
            "libraryModel"
        )

        verify(model !== null)

        const index = model.index(
            0,
            AudioFileTableModel.Cover
        )

        /*
         * The role itself must be exposed to QML. The actual value depends
         * on the user's Music directory and therefore must not be asserted
         * by this UI test.
         */
        verify(
            model.data(
                index,
                AudioFileTableModel.CoverRole
            ) !== undefined
        )
    }

    function test_select_invalid_index_is_ignored() {
        const view = createTemporaryObject(
            component,
            testCase
        )

        const spy = createTemporaryObject(
            signalSpyComponent,
            testCase
        )

        spy.target = view
        spy.signalName = "fileSelected"

        view.selectFile(-1)

        compare(
            view.selectedIndex,
            -1
        )

        compare(
            spy.count,
            0
        )

        view.selectFile(100000)

        compare(
            view.selectedIndex,
            -1
        )

        compare(
            spy.count,
            0
        )
    }
}