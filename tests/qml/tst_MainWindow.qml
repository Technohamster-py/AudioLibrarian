function test_default_navigation_section() {
    const window = createTemporaryObject(component, testCase)

    compare(window.activeSection, "files")

    const stack = findChild(window, "contentStack")

    verify(stack !== null)
    compare(stack.currentIndex, 0)
}

function test_section_index_mapping() {
    const window = createTemporaryObject(component, testCase)

    compare(window.sectionIndex("files"), 0)
    compare(window.sectionIndex("albums"), 1)
    compare(window.sectionIndex("artists"), 2)
    compare(window.sectionIndex("playlists"), 3)
    compare(window.sectionIndex("duplicates"), 4)
    compare(window.sectionIndex("settings"), 5)
}

function test_navigation_switches_content() {
    const window = createTemporaryObject(component, testCase)

    const navigation = findChild(
        window,
        "navigationBar"
    )

    const stack = findChild(
        window,
        "contentStack"
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

function test_switching_back_to_files() {
    const window = createTemporaryObject(component, testCase)

    const navigation = findChild(
        window,
        "navigationBar"
    )

    const stack = findChild(
        window,
        "contentStack"
    )

    navigation.sectionSelected("albums")

    compare(stack.currentIndex, 1)

    navigation.sectionSelected("files")

    compare(window.activeSection, "files")
    compare(stack.currentIndex, 0)

    verify(findChild(
        window,
        "filesWorkspace"
    ) !== null)
}

/**
 * @brief Verifies that the workspace stack is placed inside
 *        the main horizontal SplitView together with EditorView.
 */
function test_workspace_stack_structure() {
    const window = createTemporaryObject(component, testCase)

    const splitView = findChild(
        window,
        "mainSplitView"
    )

    const workspaceStack = findChild(
        window,
        "workspaceStack"
    )

    const libraryPane = findChild(
        window,
        "libraryPane"
    )

    const editorView = findChild(
        window,
        "editorView"
    )

    const playerBar = findChild(
        window,
        "playerBar"
    )

    verify(splitView !== null)
    verify(workspaceStack !== null)
    verify(libraryPane !== null)
    verify(editorView !== null)
    verify(playerBar !== null)

    compare(workspaceStack.parent, splitView)
    compare(libraryPane.parent, workspaceStack)
    compare(editorView.parent, splitView)
    compare(playerBar.parent, splitView)
}