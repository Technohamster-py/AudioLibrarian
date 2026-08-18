import QtQuick
import QtQuick.Controls.Basic

/**
 * @brief Compact application-specific tool button.
 *
 * Provides a consistent visual wrapper around ToolButton. Business logic
 * remains in the caller, while this component owns only presentation.
 */
ToolButton {
    id: root

    property string icon: ""
    property string tooltipText: ""

    implicitWidth: AppMetrics.iconButtonSize
    implicitHeight: AppMetrics.iconButtonSize

    hoverEnabled: true
    display: AbstractButton.IconOnly

    contentItem: AppIcon{
        anchors.fill: parent
        anchors.margins: 4
        icon: root.icon
    }

    background: Rectangle{
        radius: AppMetrics.radiusMedium

        color: root.checked ? AppColors.selection : (root.hovered ? AppColors.hover : "transparent")
    }

    ToolTip.visible: root.hovered && root.tooltipText.length > 0
    ToolTip.text: root.tooltipText
    ToolTip.delay: 500
}