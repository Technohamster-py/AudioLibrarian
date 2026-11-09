import QtQuick
import QtQuick.Layouts

/**
 * @brief One item of the global navigation bar.
 *
 * NavigationItem contains only the visual and interaction contract of
 * one navigation button. Navigation state itself belongs to NavigationBar.
 */
AppToolButton {
    id: root

    /**
     * @brief Identifier of the navigation section.
     */
    property string section: ""

    /**
     * @brief Emitted when the user selects this section.
     */
    signal selected(string section)

    objectName: root.section + "NavigationItem"

    Layout.fillWidth: true
    Layout.preferredHeight: AppMetrics.navigationItemHeight

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: 16
        radius: 1.5
        color: AppColors.accentPrimary
        visible: root.checked
    }

    onClicked: root.selected(root.section)
}
