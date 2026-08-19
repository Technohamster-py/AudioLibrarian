import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Audio metadata editor.
 *
 * This component represents the first version of the tag editor UI.
 *
 * All fields currently operate on local QML values. They are deliberately
 * not connected to a file-writing backend yet. Later this component will
 * communicate with a C++ metadata model/service.
 */
Item {
    id: root

    property string fileName: ""
    property string artist: ""
    property string album: ""
    property string genre: ""
    property int year: 0
    property string duration: ""

    Rectangle {
        anchors.fill: parent

        color: AppColors.background

        ColumnLayout {
            anchors.fill: parent

            anchors.margins: AppMetrics.spacingLarge

            spacing: AppMetrics.spacingLarge

            Label {
                Layout.fillWidth: true

                text: qsTr("Tag Editor")

                color: AppColors.textPrimary

                font.pixelSize: 28
            }

            Label {
                Layout.fillWidth: true

                text: root.fileName.length > 0
                    ? root.fileName
                    : qsTr("No file selected")

                color: AppColors.textSecondary

                elide: Text.ElideMiddle
            }

            Rectangle {
                Layout.fillWidth: true

                height: 1

                color: AppColors.separator
            }

            GridLayout {
                Layout.fillWidth: true

                columns: 2

                columnSpacing: AppMetrics.spacingLarge
                rowSpacing: AppMetrics.spacingMedium

                Label {
                    text: qsTr("Title")
                    color: AppColors.textSecondary
                }

                TextField {
                    objectName: "titleField"

                    Layout.fillWidth: true

                    text: root.fileName

                    placeholderText: qsTr("Title")
                }

                Label {
                    text: qsTr("Artist")
                    color: AppColors.textSecondary
                }

                TextField {
                    objectName: "artistField"

                    Layout.fillWidth: true

                    text: root.artist

                    placeholderText: qsTr("Artist")
                }

                Label {
                    text: qsTr("Album")
                    color: AppColors.textSecondary
                }

                TextField {
                    objectName: "albumField"

                    Layout.fillWidth: true

                    text: root.album

                    placeholderText: qsTr("Album")
                }

                Label {
                    text: qsTr("Genre")
                    color: AppColors.textSecondary
                }

                TextField {
                    objectName: "genreField"

                    Layout.fillWidth: true

                    text: root.genre

                    placeholderText: qsTr("Genre")
                }

                Label {
                    text: qsTr("Year")
                    color: AppColors.textSecondary
                }

                SpinBox {
                    objectName: "yearField"

                    Layout.fillWidth: true

                    from: 0
                    to: 9999

                    value: root.year
                }

                Label {
                    text: qsTr("Duration")
                    color: AppColors.textSecondary
                }

                Label {
                    Layout.fillWidth: true

                    text: root.duration

                    color: AppColors.textPrimary
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.fillWidth: true

                spacing: AppMetrics.spacingMedium

                Button {
                    objectName: "saveButton"

                    text: qsTr("Save")

                    enabled: root.fileName.length > 0
                }

                Button {
                    objectName: "resetButton"

                    text: qsTr("Reset")

                    enabled: root.fileName.length > 0
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }
}