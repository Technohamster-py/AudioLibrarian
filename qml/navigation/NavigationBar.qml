import QtQuick
import QtQuick.Layouts

/**
 * @brief Global application navigation bar.
 *
 * The navigation bar is responsible only for selecting a top-level
 * application section. The actual content switching is performed by
 * MainWindow.
 */
Item {
    id: root

    /**
     * @brief Currently selected application section.
     *
     * The value is controlled by MainWindow. Keeping the state outside
     * the navigation bar prevents the navigation control from becoming
     * coupled to particular content views.
     */
    property string currentSection: "files"

    /**
     * @brief Emitted when the user selects another section.
     */
    signal sectionSelected(string section)

    Rectangle {
        anchors.fill: parent

        color: AppColors.navigationBar

        ColumnLayout {
            anchors.fill: parent

            anchors.topMargin: 6
            anchors.bottomMargin: 6

            spacing: 2

            NavigationItem {
                section: "files"

                iconSource: AppAssets.files
                tooltipText: qsTr("Files")
                checked: root.currentSection === section
                onSelected: root.sectionSelected(section)
            }

            NavigationItem {
                section: "albums"

                iconSource: AppAssets.albums
                tooltipText: qsTr("Albums")
                checked: root.currentSection === section
                onSelected: root.sectionSelected(section)
            }

            NavigationItem {
                section: "artists"

                iconSource: AppAssets.artists
                tooltipText: qsTr("Artists")
                checked: root.currentSection === section
                onSelected: root.sectionSelected(section)
            }

            NavigationItem {
                section: "library"

                iconSource: AppAssets.library
                tooltipText: qsTr("Library")
                checked: root.currentSection === section
                onSelected: root.sectionSelected(section)
            }

            NavigationItem {
                section: "duplicates"

                iconSource: AppAssets.duplicate
                tooltipText: qsTr("Duplicates")
                checked: root.currentSection === section
                onSelected: root.sectionSelected(section)
            }

            Item {
                Layout.fillHeight: true
            }

            NavigationItem {
                section: "settings"

                iconSource: AppAssets.settings
                tooltipText: qsTr("Settings")
                checked: root.currentSection === section
                onSelected: root.sectionSelected(section)
            }
        }
    }
}