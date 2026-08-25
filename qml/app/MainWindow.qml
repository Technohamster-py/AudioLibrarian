import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import AudioLibrarian

/**
 * @brief Main application window.
 *
 * The window consists of:
 *
 * - a narrow global navigation bar;
 * - a stacked workspace selected by the navigation bar.
 *
 * The Files workspace contains the library and tag editor. Other
 * workspaces currently contain placeholders and will be implemented
 * independently as their domain functionality is developed.
 */
ApplicationWindow {
    id: root

    width: SettingsManager.windowWidth
    height: SettingsManager.windowHeight

    minimumWidth: AppMetrics.appMinimumWidth
    minimumHeight: AppMetrics.appMinimumHeight

    maximumWidth: AppMetrics.appMaximumWidth
    maximumHeight: AppMetrics.appMaximumHeight

    visible: true

    title: qsTr("AudioLibrarian")

    color: AppColors.background

    /**
     * @brief Currently active top-level application section.
     */
    property string activeSection: SettingsManager.activeSection

    /**
     * @brief Currently selected audio file metadata.
     */
    property string selectedFilePath: ""

    onClosing: {
        SettingsManager.saveApplicationState(width, height, x, y, navigationLayout.width, activeSection)
    }

    /**
     * @brief Converts a navigation section name into StackLayout index.
     *
     * Keeping the mapping in one place prevents magic indexes from
     * spreading throughout the UI.
     *
     * @param section Navigation section identifier.
     * @return StackLayout index.
     */
    function sectionIndex(section) {
        switch (section) {
            case "files":
                return 0
            case "albums":
                return 1
            case "artists":
                return 2
            case "library":
                return 3
            case "duplicates":
                return 4
            case "settings":
                return 5
            default:
                return 0
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        NavigationBar {
            id: navigationBar
            objectName: "navigationBar"

            Layout.fillHeight: true
            Layout.preferredWidth: AppMetrics.navigationBarWidth
            currentSection: root.activeSection

            onSectionSelected: function(section) {
                root.activeSection = section
            }
        }

        SplitView {
            id: filesWorkspace
            objectName: "mainSplitView"

            Layout.fillWidth: true
            Layout.fillHeight: true

            orientation: Qt.Horizontal

            handle: Rectangle {
                implicitWidth: 3
                color: SplitHandle.pressed ? AppColors.accent : AppColors.separator
            }

            ColumnLayout{
                id: navigationLayout
                objectName: "navigationLayout"

                SplitView.preferredWidth: SettingsManager.navigationWidth
                SplitView.minimumWidth: AppMetrics.libraryMinimumWidth
                SplitView.maximumWidth: AppMetrics.libraryMaximumWidth

                StackLayout {
                    id: contentStack
                    objectName: "workspaceStack"

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    currentIndex: root.sectionIndex(root.activeSection)

                    NavigationPlaceholderView {
                        objectName: "filesView"
                        title: qsTr("Files")
                        iconSource: "qrc:/qt/qml/AudioLibrarian/assets/files.svg"
                    }

                    NavigationPlaceholderView {
                        objectName: "albumsView"
                        title: qsTr("Albums")
                        iconSource: "qrc:/qt/qml/AudioLibrarian/assets/albums.svg"
                    }

                    NavigationPlaceholderView {
                        objectName: "artistsView"
                        title: qsTr("Artists")
                        iconSource: "qrc:/qt/qml/AudioLibrarian/assets/artists.svg"
                    }

                    LibraryPane {
                        id: libraryPane

                        objectName: "libraryPane"

                        onFileSelected: function (filePath) {
                            root.selectedFilePath = filePath
                        }
                    }

                    NavigationPlaceholderView {
                        objectName: "duplicatesView"
                        title: qsTr("Duplicates")
                        iconSource: "qrc:/qt/qml/AudioLibrarian/assets/duplicate.svg"
                    }

                    SettingsView {
                        objectName: "settingsView"
                    }
                }

                PlayerBar {
                    objectName: "playerBar"

                    Layout.fillWidth: true
                    Layout.preferredHeight: AppMetrics.playerHeight
                }
            }

            EditorView {
                id: editorView
                objectName: "editorView"

                SplitView.minimumWidth: AppMetrics.editorMinimumWidth
                SplitView.maximumWidth: AppMetrics.editorMaximumWidth

                SplitView.fillWidth: true

                filePath: root.selectedFilePath
            }
        }
    }

    /**
     * Initialize the tag editor with the first library item.
     *
     * LibraryView emits fileSelected() from Component.onCompleted.
     */
}
