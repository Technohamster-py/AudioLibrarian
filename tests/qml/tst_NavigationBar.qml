import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for the global navigation bar.
 */
TestCase {
    id: testCase

    name: "NavigationBar"

    Component {
        id: component

        NavigationBar {
            width: 56
            height: 600
        }
    }

    function test_default_section() {
        const navigation = createTemporaryObject(component, testCase)

        compare(navigation.currentSection, "files")
    }

    function test_section_selection_signal() {
        const navigation = createTemporaryObject(component, testCase)
        const spy = signalSpy(navigation, "sectionSelected")

        navigation.sectionSelected("albums")

        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], "albums")
    }

    function test_navigation_items_exist() {
        const navigation = createTemporaryObject(component, testCase)

        verify(findChild(
            navigation,
            "filesNavigationItem"
        ) !== null)

        verify(findChild(
            navigation,
            "albumsNavigationItem"
        ) !== null)

        verify(findChild(
            navigation,
            "artistsNavigationItem"
        ) !== null)

        verify(findChild(
            navigation,
            "playlistsNavigationItem"
        ) !== null)

        verify(findChild(
            navigation,
            "duplicatesNavigationItem"
        ) !== null)

        verify(findChild(
            navigation,
            "settingsNavigationItem"
        ) !== null)
    }

    function test_current_item_is_checked() {
        const navigation = createTemporaryObject(component, testCase)

        const files = findChild(
            navigation,
            "filesNavigationItem"
        )

        const albums = findChild(
            navigation,
            "albumsNavigationItem"
        )

        verify(files !== null)
        verify(albums !== null)

        compare(files.checked, true)
        compare(albums.checked, false)

        navigation.currentSection = "albums"

        compare(files.checked, false)
        compare(albums.checked, true)
    }
}