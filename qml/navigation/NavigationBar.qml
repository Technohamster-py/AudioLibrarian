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

                iconSource: "qrc:/qt/qml/AudioLibrarian/assets/files.svg"
                tooltipText: qsTr("Files")
                checked: root.currentSection === section
                onSelected: root.sectionSelected(section)
            }

            NavigationItem {
                section: "albums"

                iconSource: "qrc:/qt/qml/AudioLibrarian/assets/albums.svg"
                tooltipText: qsTr("Albums")
                checked: root.currentSection === section
                onSelected: root.sectionSelected(section)
            }

            NavigationItem {
                section: "artists"

                iconSource: "qrc:/qt/qml/AudioLibrarian/assets/artists.svg"
                tooltipText: qsTr("Artists")
                checked: root.currentSection === section
                onSelected: root.sectionSelected(section)
            }

            NavigationItem {
                section: "library"

                iconSource: "qrc:/qt/qml/AudioLibrarian/assets/music-library.svg"
                tooltipText: qsTr("Library")
                checked: root.currentSection === section
                onSelected: root.sectionSelected(section)
            }

            NavigationItem {
                section: "duplicates"

                iconSource: "qrc:/qt/qml/AudioLibrarian/assets/duplicate.svg"
                tooltipText: qsTr("Duplicates")
                checked: root.currentSection === section
                onSelected: root.sectionSelected(section)
            }

            Item {
                Layout.fillHeight: true
            }

            NavigationItem {
                section: "settings"

                iconSource: "qrc:/qt/qml/AudioLibrarian/assets/settings.svg"
                tooltipText: qsTr("Settings")
                checked: root.currentSection === section
                onSelected: root.sectionSelected(section)
            }
        }
    }
}