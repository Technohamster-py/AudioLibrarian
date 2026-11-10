import QtQuick
import QtQuick.Controls.FluentWinUI3
import QtQuick.Layouts
import QtQuick.Window
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

    // maximumWidth: AppMetrics.appMaximumWidth
    // maximumHeight: AppMetrics.appMaximumHeight

    visible: true

    title: qsTr("AudioLibrarian")

    color: AppColors.background
    font.family: AppMetrics.fontFamily
    font.pixelSize: AppMetrics.fontSizeMedium
    palette.accent: AppColors.accentPrimary
    palette.highlight: AppColors.accentPrimary

    /**
     * @brief Currently active top-level application section.
     */
    property string activeSection: SettingsManager.activeSection

    /**
     * @brief Currently selected audio file metadata.
     */
    property string selectedFilePath: ""

    onClosing: {
        SettingsManager.saveApplicationState(width, height, x, y, navigationLayout.width, activeSection, playerController.volume, playerBar.expanded);
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
            return 0;
        case "albums":
            return 1;
        case "artists":
            return 2;
        case "library":
            return 3;
        case "duplicates":
            return 4;
        case "settings":
            return 5;
        default:
            return 0;
        }
    }

    PlayerController {
        id: playerController
        objectName: "playerController"

        volume: SettingsManager.volume
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

            onSectionSelected: function (section) {
                root.activeSection = section;
            }
        }

        StackLayout {
            id: mainWorkspaceStack
            objectName: "mainWorkspaceStack"

            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: root.activeSection === "duplicates" ? 1 : 0

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                SplitView {
                    id: filesWorkspace
                    objectName: "mainSplitView"

                    anchors.fill: parent

                    orientation: Qt.Horizontal

                    handle: Rectangle {
                        implicitWidth: 8
                        color: "transparent"

                        Rectangle {
                            anchors.centerIn: parent
                            width: 1
                            height: parent.height - AppMetrics.pagePadding * 2
                            color: SplitHandle.pressed || SplitHandle.hovered ? AppColors.accentPrimary : AppColors.separator
                        }
                    }

                    ColumnLayout {
                        id: navigationLayout
                        objectName: "navigationLayout"

                        SplitView.preferredWidth: SettingsManager.navigationWidth
                        SplitView.minimumWidth: AppMetrics.libraryMinimumWidth
                        SplitView.maximumWidth: AppMetrics.libraryMaximumWidth

                        spacing: AppMetrics.spacingSmall

                        StackLayout {
                            id: contentStack
                            objectName: "workspaceStack"

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            currentIndex: root.sectionIndex(root.activeSection)

                            FilesView {
                                id: filesView

                                objectName: "filesView"

                                currentFilePath: root.selectedFilePath

                                onFileSelected: function (filePath) {
                                    root.selectedFilePath = filePath;
                                    playerController.setFilePath(filePath);
                                }
                            }

                            NavigationPlaceholderView {
                                objectName: "albumsView"
                                title: qsTr("Albums")
                                iconSource: AppAssets.albums
                            }

                            ArtistsView {
                                objectName: "artistsView"
                                libraryModel: libraryPane.model
                                currentFilePath: root.selectedFilePath
                                onFileSelected: function(filePath) {
                                    root.selectedFilePath = filePath;
                                    playerController.setFilePath(filePath);
                                }
                            }

                            LibraryPane {
                                id: libraryPane

                                objectName: "libraryPane"

                                onFileSelected: function (filePath) {
                                    root.selectedFilePath = filePath;
                                    playerController.setFilePath(filePath);
                                }

                                onBaseDirectoryChanged: function (directory) {
                                    batchProcessView.baseFilePath = directory;
                                }
                            }

                            NavigationPlaceholderView {
                                objectName: "duplicatesView"
                                title: qsTr("Duplicates")
                                iconSource: AppAssets.duplicate
                            }

                            // SettingsView {
                            //     objectName: "settingsView"
                            // }
                        }

                        PlayerBar {
                            id: playerBar
                            objectName: "playerBar"

                            Layout.fillWidth: true

                            Layout.preferredHeight: expanded ? AppMetrics.playerHeight : AppMetrics.iconButtonSize

                            player: playerController

                            Behavior on Layout.preferredHeight {
                                NumberAnimation {
                                    duration: 180
                                    easing.type: Easing.OutCubic
                                }
                            }
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

            BatchProcessView {
                id: batchProcessView
                objectName: "batchProcessView"

                playerController: playerController

                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    /**
     * Initialize the tag editor with the first library item.
     *
     * LibraryView emits fileSelected() from Component.onCompleted.
     */
}
