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

    property bool previewVisible: false
    property var previewEntries: []

    signal previewRequested(string templatePattern)
    signal confirmRenameRequested()
    signal cancelPreviewRequested()

    signal renameRequested(string templatePattern)

    /** @brief Indicates whether rename preview can be requested. */
    readonly property bool canPreview: !root.renaming
        && !root.previewVisible
        && templateField.text.trim().length > 0

    /** @brief Starts preview generation using the current template. */
    function requestPreview() {
        if (canPreview)
            root.previewRequested(templateField.text)
    }

    Popup {
        id: renamePreviewPopup
        objectName: "renamePreviewPopup"

        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(root.width * 0.9, 900)
        height: Math.min(root.height * 0.85, 600)

        modal: true
        closePolicy: Popup.NoAutoClose
        visible: root.previewVisible

        background: Rectangle {
            color: AppColors.navigationPanel
            border.color: AppColors.settingsSeparator
            radius: 8
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: AppMetrics.spacingMedium
            spacing: AppMetrics.spacingMedium

            Label {
                Layout.fillWidth: true
                text: qsTr("Rename preview (%1 files)").arg(root.previewEntries.length)
                color: AppColors.settingsTextPrimary
                font.bold: true
                font.pixelSize: 20
            }

            RowLayout {
                Layout.fillWidth: true

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Current path")
                    color: AppColors.settingsTextSecondary
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("New path")
                    color: AppColors.settingsTextSecondary
                }
            }

            ListView {
                id: previewList
                objectName: "renamePreviewList"

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.previewEntries
                boundsBehavior: Flickable.StopAtBounds

                delegate: RowLayout {
                    required property var modelData

                    width: previewList.width
                    spacing: AppMetrics.spacingMedium

                    Label {
                        Layout.fillWidth: true
                        text: modelData.sourcePath
                        color: AppColors.settingsTextPrimary
                        elide: Text.ElideMiddle
                        ToolTip.visible: hovered
                        ToolTip.text: text
                    }

                    Label {
                        Layout.fillWidth: true
                        text: modelData.targetPath
                        color: AppColors.settingsTextPrimary
                        elide: Text.ElideMiddle
                        ToolTip.visible: hovered
                        ToolTip.text: text
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("Cancel")
                    onClicked: root.cancelPreviewRequested()
                }

                Button {
                    objectName: "confirmRenameButton"
                    text: qsTr("Rename")
                    enabled: root.previewEntries.length > 0
                    onClicked: root.confirmRenameRequested()
                }
            }
        }

        onOpened: previewList.positionViewAtBeginning()
    }

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
    }
}