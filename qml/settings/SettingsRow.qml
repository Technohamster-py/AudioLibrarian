import QtQuick
import QtQuick.Controls.FluentWinUI3
import QtQuick.Layouts

/**
 * @brief A single row in the application settings page.
 *
 * Each row consists of two columns:
 * - a flexible column containing the setting title and description;
 * - a fixed-width control column aligned to the right edge.
 */
Rectangle {
    id: root

    /**
     * @brief Width of the column containing the setting control.
     *
     * Keeping this value identical for every row makes all controls
     * line up vertically regardless of their individual content.
     */
    property int controlWidth: 320

    /**
     * @brief Text displayed as the setting name.
     */
    property string title: ""

    /**
     * @brief Optional explanatory text displayed below the title.
     */
    property string description: ""

    /**
     * @brief Control displayed in the right column.
     */
    default property alias control: controlContainer.data

    implicitHeight: Math.max(72, contentLayout.implicitHeight + 32)
    color: AppColors.panel
    radius: AppMetrics.radiusSmall
    border.color: AppColors.separator

    RowLayout {
        id: contentLayout

        anchors.fill: parent
        anchors.margins: AppMetrics.spacingLarge

        spacing: AppMetrics.spacingLarge

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 2

            Label {
                text: root.title

                color: AppColors.settingsTextPrimary

                font.pixelSize: AppMetrics.fontSizeMedium
            }

            Label {
                visible: root.description.length > 0

                text: root.description

                color: AppColors.settingsTextSecondary

                font.pixelSize: 12

                wrapMode: Text.WordWrap

                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            id: controlContainer

            Layout.preferredWidth: root.controlWidth
            Layout.minimumWidth: root.controlWidth
            Layout.maximumWidth: root.controlWidth

            implicitHeight: childrenRect.height
        }
    }
}
