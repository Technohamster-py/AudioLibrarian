import QtQuick
import QtQuick.Layouts

/**
 * @brief Composite left navigation pane.
 *
 * The pane owns the contextual navigation and the player. Keeping these
 * areas together allows the whole pane to be resized through SplitView.
 */
Item {
    id: root

    implicitWidth: AppMetrics.navigationViewWidth

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        NavigationView {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        PlayerBar {
            Layout.fillWidth: true
            Layout.preferredHeight: AppMetrics.playerHeight
        }
    }
}