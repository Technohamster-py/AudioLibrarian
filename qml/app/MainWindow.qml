import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * @brief Main application window.
 *
 * The window consists of three logical areas:
 *
 * - NavigationBar: global application navigation;
 * - NavigationView: contextual navigation;
 * - ContentView: currently selected workspace.
 *
 * NavigationView and ContentView are separated by a draggable
 * SplitView handle so the user can resize the navigation area.
 */
ApplicationWindow {
    id: root

    width: 1920
    height: 1080

    minimumWidth: 900
    minimumHeight: 600

    visible: true
    title: qsTr("Audio Librarian")

    color: AppColors.background

    /**
     * @brief Main horizontal application layout.
     *
     * The first item has a fixed width and represents the global
     * navigation bar. The remaining space is occupied by the
     * navigation and content areas.
     */
    RowLayout {
        anchors.fill: parent
        spacing: 0

        NavigationBar {
            Layout.fillHeight: true
            Layout.preferredWidth: AppMetrics.navigationBarWidth
        }

        SplitView {
            id: mainSplitView

            objectName: "mainSplitView"

            Layout.fillWidth: true
            Layout.fillHeight: true

            orientation: Qt.Horizontal

            handle: Rectangle {
                implicitWidth: 1

                color: SplitHandle.pressed ? AppColors.accent : AppColors.separator
            }

            NavigationPane {
                objectName: "navigationPane"

                SplitView.preferredWidth: AppMetrics.navigationViewWidth
                SplitView.minimumWidth: AppMetrics.navigationViewMinimumWidth
                SplitView.maximumWidth: AppMetrics.navigationViewMaximumWidth
            }

            ContentView {
                objectName: "contentView"

                SplitView.fillWidth: true

                SplitView.minimumWidth:
                    root.minimumWidth - AppMetrics.navigationBarWidth - AppMetrics.navigationViewMaximumWidth
            }
        }
    }
}