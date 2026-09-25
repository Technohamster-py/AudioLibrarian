import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Batch file renaming configuration view.
 *
 * Allows the user to configure a metadata-based rename template and
 * start the rename operation.
 */
Item {
    id: root

    property bool renaming: false
    property int progressCurrent: 0
    property int progressTotal: 0
    property string currentFile: ""
    property string errorMessage: ""

    signal renameRequested(string templatePattern)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppMetrics.spacingLarge
        spacing: AppMetrics.spacingMedium

        Label {
            Layout.fillWidth: true

            text: qsTr("Rename files")
            color: AppColors.settingsTextPrimary

            font.pixelSize: 24
            font.bold: true
        }

        Label {
            Layout.fillWidth: true

            text: qsTr("Build file and folder names from audio metadata.")
            color: AppColors.settingsTextSecondary
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: AppColors.settingsSeparator
        }

        Label {
            Layout.fillWidth: true

            text: qsTr("Rename template")
            color: AppColors.settingsTextPrimary
        }

        TextField {
            id: templateField
            objectName: "renameTemplateField"

            Layout.fillWidth: true

            placeholderText: "{ARTIST}/{ALBUM}/{TRACKNUMBER}_{TITLE}"
            text: "{ARTIST}/{ALBUM}/{TRACKNUMBER}_{TITLE}"

            enabled: !root.renaming

            selectByMouse: true
        }

        Label {
            Layout.fillWidth: true

            text: qsTr(
                "Example: {ARTIST}/{ALBUM}/{TRACKNUMBER}_{TITLE}"
            )

            color: AppColors.settingsTextSecondary
            wrapMode: Text.WordWrap
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: AppColors.settingsSeparator
        }

        Label {
            Layout.fillWidth: true

            text: qsTr("Available fields")
            color: AppColors.settingsTextPrimary
            font.bold: true
        }

        Flow {
            Layout.fillWidth: true

            spacing: AppMetrics.spacingSmall

            Repeater {
                model: [
                    "{TITLE}",
                    "{ARTIST}",
                    "{ALBUM}",
                    "{ALBUMARTIST}",
                    "{GENRE}",
                    "{DATE}",
                    "{TRACKNUMBER}",
                    "{DISCNUMBER}",
                    "{FILENAME}"
                ]

                delegate: Button {
                    text: modelData
                    enabled: !root.renaming

                    onClicked: {
                        templateField.insert(templateField.cursorPosition, modelData)
                        templateField.forceActiveFocus()
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true

            text: qsTr(
                "The file extension is preserved automatically. "
                + "Metadata values are cleaned from characters that are "
                + "not valid in file names."
            )

            color: AppColors.settingsTextSecondary
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.fillHeight: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: AppColors.settingsSeparator
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: AppMetrics.spacingSmall

            visible: root.renaming

            ProgressBar {
                id: progressBar
                objectName: "renameProgressBar"

                Layout.fillWidth: true

                from: 0
                to: Math.max(root.progressTotal, 1)
                value: root.progressCurrent
            }

            Label {
                Layout.fillWidth: true

                text: root.currentFile.length > 0
                    ? qsTr("Renaming: %1").arg(root.currentFile)
                    : qsTr("Preparing...")

                color: AppColors.settingsTextSecondary
                elide: Text.ElideMiddle
            }
        }

        Label {
            Layout.fillWidth: true

            visible: root.errorMessage.length > 0

            text: root.errorMessage
            color: AppColors.accent
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
            }

            Button {
                id: renameButton
                objectName: "renameFilesButton"

                text: qsTr("Rename files")

                enabled: !root.renaming
                    && templateField.text.trim().length > 0

                onClicked: root.renameRequested(templateField.text)
            }
        }
    }
}