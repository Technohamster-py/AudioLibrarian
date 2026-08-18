import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Structural tests for the main application window.
 */
TestCase {
    name: "MainWindow"

    Component {
        id: component

        MainWindow {
            visible: false
        }
    }

    function test_window_is_created() {
        const window = createTemporaryObject(component, null)

        verify(window !== null)

        verify(window.minimumWidth > 0)
        verify(window.minimumHeight > 0)
    }

    function test_main_split_view_has_two_panes() {
        const window = createTemporaryObject(component, null)
        const splitView = findChild(window, "mainSplitView")

        verify(splitView !== null)
        compare(splitView.count, 2)
    }

    function test_main_sections_are_present() {
        const window = createTemporaryObject(component, null)

        verify(findChild(window, "navigationBar") !== null)
        verify(findChild(window, "navigationPane") !== null)
        verify(findChild(window, "contentView") !== null)
    }
}