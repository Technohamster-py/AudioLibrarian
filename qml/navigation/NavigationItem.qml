import QtQuick
import QtQuick.Controls.Basic

/**
 * @brief Single item of the contextual navigation list.
 */
Item {
    id: root

    property alias text: label.text
    property bool selected: false

    signal clicked()

    Rectangle {
        anchors.fill: parent

        anchors.leftMargin: 6
        anchors.rightMargin: 6

        radius: AppMetrics.radiusSmall

        color: root.selected
            ? AppColors.selection
            : (mouseArea.containsMouse ? AppColors.hover : "transparent")
    }

    Label {
        id: label

        anchors.fill: parent

        anchors.leftMargin: 12
        anchors.rightMargin: 12

        color: root.selected
            ? AppColors.textPrimary
            : AppColors.textSecondary

        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true

        onClicked: root.clicked()
    }
}