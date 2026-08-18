import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for NavigationItem.
 */
TestCase {
    id: testCase

    name: "NavigationItem"
    when: windowShown

    Component {
        id: component

        NavigationItem {
            width: 300
            height: 48
        }
    }

    function test_default_state() {
        const item = createTemporaryObject(component, testCase)

        verify(item !== null)
        compare(item.selected, false)
        compare(item.text, "")
    }

    function test_selection_state() {
        const item = createTemporaryObject(component, testCase)

        item.text = "Artists"
        item.selected = true

        compare(item.text, "Artists")
        compare(item.selected, true)
    }

    function test_click_signal() {
        const item = createTemporaryObject(component, testCase)
        const spy = signalSpy(item, "clicked")

        mouseClick(item)

        compare(spy.count, 1)
    }
}