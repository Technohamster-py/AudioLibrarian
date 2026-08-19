import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

/**
 * @brief Temporary content view for an unimplemented navigation section.
 *
 * The component allows navigation switching to be implemented before
 * the corresponding domain model and editor have been developed.
 */
Item {
    id: root

    /**
     * @brief Title of the navigation section.
     */
    property string title: ""

    /**
     * @brief Icon displayed above the section title.
     */
    property url iconSource: ""

    Rectangle {
        anchors.fill: parent

        color: AppColors.background

        ColumnLayout {
            anchors.centerIn: parent

            spacing: AppMetrics.spacingMedium

            AppIcon {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64

                Layout.alignment: Qt.AlignHCenter

                source: root.iconSource
            }

            Label {
                Layout.alignment: Qt.AlignHCenter

                text: root.title

                color: AppColors.textPrimary

                font.pixelSize: 28
            }

            Label {
                Layout.alignment: Qt.AlignHCenter

                text: qsTr("This section is not implemented yet.")

                color: AppColors.textSecondary
            }
        }
    }
}