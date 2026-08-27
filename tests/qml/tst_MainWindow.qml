import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for the main application window.
 *
 * The tests verify the current workspace structure, navigation mapping,
 * player integration and editor selection propagation.
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

    function test_default_navigation_section() {
        const window = createTemporaryObject(component, testCase)

        verify(window !== null)

        compare(window.activeSection, "files")

        const stack = findChild(window, "workspaceStack")

        verify(stack !== null)

        compare(stack.currentIndex, 0)
    }

    function test_section_index_mapping() {
        const window = createTemporaryObject(component, testCase)

        compare(window.sectionIndex("files"), 0)

        compare(window.sectionIndex("albums"), 1)

        compare(window.sectionIndex("artists"), 2)

        compare(window.sectionIndex("library"), 3)

        compare(window.sectionIndex("duplicates"), 4)

        compare(window.sectionIndex("settings"), 5)

        compare(window.sectionIndex("unknown"), 0)
    }

    function test_workspace_structure() {
        const window = createTemporaryObject(component, testCase)

        const splitView = findChild(window, "mainSplitView")

        const navigationLayout = findChild(window, "navigationLayout")

        const workspaceStack = findChild(window, "workspaceStack")

        const libraryPane = findChild(window, "libraryPane")

        const playerBar = findChild(window, "playerBar")

        const editorView = findChild(window, "editorView")

        verify(splitView !== null)
        verify(navigationLayout !== null)
        verify(workspaceStack !== null)
        verify(libraryPane !== null)
        verify(playerBar !== null)
        verify(editorView !== null)

        compare(navigationLayout.parent, splitView.contentItem)

        compare(workspaceStack.parent, navigationLayout)

        compare(libraryPane.parent, workspaceStack)

        compare(playerBar.parent, navigationLayout)

        compare(editorView.parent, splitView.contentItem)
    }

    function test_player_controller_is_connected() {
        const window = createTemporaryObject(component, testCase)

        const player = findChild(window, "playerController")

        const playerBar = findChild(window, "playerBar")

        verify(player !== null)
        verify(playerBar !== null)

        compare(playerBar.player, player)
    }

    function test_player_is_outside_workspace_stack() {
        const window = createTemporaryObject(component, testCase)

        const stack = findChild(window, "workspaceStack")

        const playerBar = findChild(window, "playerBar")

        verify(stack !== null)
        verify(playerBar !== null)

        verify(playerBar.parent !== stack)

        compare(playerBar.parent, findChild(window, "navigationLayout"))
    }

    function test_navigation_changes_workspace() {
        const window = createTemporaryObject(component, testCase)

        const navigation = findChild(window, "navigationBar")

        const stack = findChild(window, "workspaceStack")

        verify(navigation !== null)
        verify(stack !== null)

        navigation.sectionSelected("albums")

        compare(window.activeSection, "albums")

        compare(stack.currentIndex, 1)

        navigation.sectionSelected("artists")

        compare(window.activeSection, "artists")

        compare(stack.currentIndex, 2)

        navigation.sectionSelected("settings")

        compare(window.activeSection, "settings")

        compare(stack.currentIndex, 5)
    }

    function test_switching_back_to_files() {
        const window = createTemporaryObject(component, testCase)

        const navigation = findChild(window, "navigationBar")

        const stack = findChild(window, "workspaceStack")

        verify(navigation !== null)
        verify(stack !== null)

        navigation.sectionSelected("library")

        compare(stack.currentIndex, 3)

        navigation.sectionSelected("files")

        compare(window.activeSection, "files")

        compare(stack.currentIndex, 0)
    }

    function test_editor_is_bound_to_selected_file() {
        const window = createTemporaryObject(component, testCase)

        const editor = findChild(window, "editorView")

        verify(editor !== null)

        compare(window.selectedFilePath, "")

        compare(editor.filePath, "")

        /*
         * selectedFilePath is intentionally tested through the public
         * property. LibraryPane is responsible for assigning it after
         * fileSelected().
         */
        window.selectedFilePath = "/tmp/test.wav"

        compare(editor.filePath, "/tmp/test.wav")
    }
}