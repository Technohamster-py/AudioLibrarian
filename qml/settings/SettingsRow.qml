import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief A single row in the application settings page.
 *
 * Each row consists of two columns:
 * - a flexible column containing the setting title and description;
 * - a fixed-width control column aligned to the right edge.
 */
Item {
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

    implicitHeight: contentLayout.implicitHeight

    RowLayout {
        id: contentLayout

        anchors.fill: parent

        spacing: AppMetrics.spacingLarge

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 2

            Label {
                text: root.title

                color: AppColors.textPrimary

                font.pixelSize: 15
            }

            Label {
                visible: root.description.length > 0

                text: root.description

                color: AppColors.textSecondary

                font.pixelSize: 12

                wrapMode: Text.WordWrap

                Layout.fillWidth: true
            }
        }

        Item {
            id: controlContainer

            Layout.preferredWidth: root.controlWidth
            Layout.minimumWidth: root.controlWidth
            Layout.maximumWidth: root.controlWidth

            implicitHeight: childrenRect.height
        }
    }
}