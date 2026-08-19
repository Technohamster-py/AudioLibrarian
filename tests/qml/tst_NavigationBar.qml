import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for the global navigation bar.
 */
TestCase {
    id: testCase

    name: "NavigationBar"

    /**
     * @brief Component used to instantiate isolated NavigationBar objects.
     */
    Component {
        id: component

        NavigationBar {
            width: 56
            height: 600
        }
    }

    SignalSpy {
        id: sectionSpy
    }

    /**
     * @brief Verifies the default selected section.
     */
    function test_default_section() {
        const navigation = createTemporaryObject(
            component,
            testCase
        )

        compare(
            navigation.currentSection,
            "files"
        )
    }

    /**
     * @brief Verifies that a navigation item emits the expected
     *        section through NavigationBar.
     *
     * The test uses the real NavigationItem interaction instead of
     * relying on a nonexistent signalSpy() helper.
     */
    function test_section_selection() {
        const navigation = createTemporaryObject(
            component,
            testCase
        )

        sectionSpy.target = navigation
        sectionSpy.signalName = "sectionSelected"

        const albums = findChild(
            navigation,
            "albumsNavigationItem"
        )

        verify(albums !== null)

        albums.clicked()

        compare(sectionSpy.count, 1)
        compare(
            sectionSpy.signalArguments[0][0],
            "albums"
        )
    }

    /**
     * @brief Verifies that all expected navigation items exist.
     */
    function test_navigation_items_exist() {
        const navigation = createTemporaryObject(
            component,
            testCase
        )

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
            "libraryNavigationItem"
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

    /**
     * @brief Verifies that only the current navigation item is checked.
     */
    function test_current_item_is_checked() {
        const navigation = createTemporaryObject(
            component,
            testCase
        )

        const files = findChild(
            navigation,
            "filesNavigationItem"
        )

        const library = findChild(
            navigation,
            "libraryNavigationItem"
        )

        verify(files !== null)
        verify(library !== null)

        compare(files.checked, true)
        compare(library.checked, false)

        navigation.currentSection = "library"

        compare(files.checked, false)
        compare(library.checked, true)
    }
}