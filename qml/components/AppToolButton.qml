import QtQuick
import QtQuick.Controls.Basic

/**
 * @brief Compact application-specific tool button.
 *
 * Provides consistent presentation for navigation and player buttons.
 * The component does not contain application logic.
 */
ToolButton {
    id: root

    /**
     * @brief SVG resource displayed by the button.
     */
    property url iconSource: ""

    /**
     * @brief Tooltip displayed when the pointer hovers over the button.
     */
    property string tooltipText: ""

    implicitWidth: AppMetrics.iconButtonSize
    implicitHeight: AppMetrics.iconButtonSize

    hoverEnabled: true

    checkable: true

    display: AbstractButton.IconOnly

    contentItem: AppIcon {
        anchors.fill: parent
        anchors.margins: 6
        source: root.iconSource
    }

    background: Rectangle {
        radius: AppMetrics.radiusMedium
        color: root.checked ? AppColors.selection : (root.hovered ? AppColors.hover : "transparent")
    }

    ToolTip.visible: root.hovered && root.tooltipText.length > 0
    ToolTip.text: root.tooltipText
    ToolTip.delay: 500
}