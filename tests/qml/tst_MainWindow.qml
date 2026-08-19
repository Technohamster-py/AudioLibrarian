import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for the main application window.
 *
 * The tests verify the structure and navigation behaviour of the
 * first UI vertical slice.
 */
TestCase {
    id: testCase

    name: "MainWindow"

    /**
     * @brief Component used to instantiate isolated MainWindow objects.
     */
    Component {
        id: component

        MainWindow {
            visible: false
        }
    }

    /**
     * @brief Verifies the default navigation section.
     */
    function test_default_navigation_section() {
        const window = createTemporaryObject(
            component,
            testCase
        )

        compare(window.activeSection, "files")

        const stack = findChild(
            window,
            "workspaceStack"
        )

        verify(stack !== null)
        compare(stack.currentIndex, 0)
    }

    /**
     * @brief Verifies the mapping between navigation sections
     *        and StackLayout indexes.
     */
    function test_section_index_mapping() {
        const window = createTemporaryObject(
            component,
            testCase
        )

        compare(window.sectionIndex("files"), 0)
        compare(window.sectionIndex("albums"), 1)
        compare(window.sectionIndex("artists"), 2)
        compare(window.sectionIndex("library"), 3)
        compare(window.sectionIndex("duplicates"), 4)
        compare(window.sectionIndex("settings"), 5)

        // Unknown sections must fall back to the Files page.
        compare(window.sectionIndex("unknown"), 0)
    }

    /**
     * @brief Verifies that navigation changes the active workspace.
     */
    function test_navigation_switches_content() {
        const window = createTemporaryObject(
            component,
            testCase
        )

        const navigation = findChild(
            window,
            "navigationBar"
        )

        const stack = findChild(
            window,
            "workspaceStack"
        )

        verify(navigation !== null)
        verify(stack !== null)

        navigation.sectionSelected("albums")

        compare(window.activeSection, "albums")
        compare(stack.currentIndex, 1)

        verify(findChild(
            window,
            "albumsView"
        ) !== null)
    }

    /**
     * @brief Verifies switching from another workspace back to Files.
     */
    function test_switching_back_to_files() {
        const window = createTemporaryObject(
            component,
            testCase
        )

        const navigation = findChild(
            window,
            "navigationBar"
        )

        const stack = findChild(
            window,
            "workspaceStack"
        )

        verify(navigation !== null)
        verify(stack !== null)

        navigation.sectionSelected("albums")

        compare(window.activeSection, "albums")
        compare(stack.currentIndex, 1)

        navigation.sectionSelected("files")

        compare(window.activeSection, "files")
        compare(stack.currentIndex, 0)

        verify(findChild(
            window,
            "filesView"
        ) !== null)
    }

    /**
     * @brief Verifies the actual hierarchy of the main workspace.
     *
     * Expected structure:
     *
     * RowLayout
     * ├── NavigationBar
     * └── SplitView
     *     └── contentItem (Qt Quick Controls internal item)
     *         ├── ColumnLayout
     *         │   ├── StackLayout
     *         │   │   └── LibraryPane
     *         │   └── PlayerBar
     *         └── EditorView
     */
    function test_workspace_structure() {
        const window = createTemporaryObject(
            component,
            testCase
        )

        const splitView = findChild(
            window,
            "mainSplitView"
        )

        const navigationLayout = findChild(
            window,
            "navigationLayout"
        )

        const workspaceStack = findChild(
            window,
            "workspaceStack"
        )

        const libraryPane = findChild(
            window,
            "libraryPane"
        )

        const playerBar = findChild(
            window,
            "playerBar"
        )

        const editorView = findChild(
            window,
            "editorView"
        )

        verify(splitView !== null)
        verify(navigationLayout !== null)
        verify(workspaceStack !== null)
        verify(libraryPane !== null)
        verify(playerBar !== null)
        verify(editorView !== null)

        /*
         * StackLayout and PlayerBar belong to the left-side
         * ColumnLayout, while EditorView is a direct child of the
         * SplitView's content item.
         */
        compare(
            navigationLayout.parent,
            splitView.contentItem
        )

        compare(
            workspaceStack.parent,
            navigationLayout
        )

        compare(
            libraryPane.parent,
            workspaceStack
        )

        compare(
            playerBar.parent,
            navigationLayout
        )

        compare(
            editorView.parent,
            splitView.contentItem
        )
    }

    /**
     * @brief Verifies that the PlayerBar exists independently
     *        of the selected navigation workspace.
     */
    function test_player_is_outside_workspace_stack() {
        const window = createTemporaryObject(
            component,
            testCase
        )

        const navigation = findChild(
            window,
            "navigationBar"
        )

        const stack = findChild(
            window,
            "workspaceStack"
        )

        const playerBar = findChild(
            window,
            "playerBar"
        )

        verify(navigation !== null)
        verify(stack !== null)
        verify(playerBar !== null)

        /*
         * Switch through several workspaces. PlayerBar must remain
         * present because it is a sibling of StackLayout rather
         * than one of its pages.
         */
        navigation.sectionSelected("albums")
        verify(playerBar.visible)

        navigation.sectionSelected("artists")
        verify(playerBar.visible)

        navigation.sectionSelected("duplicates")
        verify(playerBar.visible)

        navigation.sectionSelected("settings")
        verify(playerBar.visible)

        navigation.sectionSelected("files")
        verify(playerBar.visible)
    }
}
