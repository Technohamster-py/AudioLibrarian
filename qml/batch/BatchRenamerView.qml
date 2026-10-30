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

    /** @brief Root directory used to shorten displayed file paths. */
    property string baseDirectory: ""

    /**
     * @brief Returns a path relative to the selected root directory.
     * @param path Absolute or relative file path.
     */
    function displayPath(path) {
        const normalizedPath = path.replace(/\\/g, "/")
        let normalizedBase = baseDirectory.replace(/\\/g, "/")

        if (normalizedBase.length > 1 && normalizedBase.endsWith("/"))
            normalizedBase = normalizedBase.slice(0, -1)

        if (normalizedBase.length > 0
            && normalizedPath.toLowerCase().startsWith((normalizedBase + "/").toLowerCase()))
            return normalizedPath.slice(normalizedBase.length + 1)

        return normalizedPath
    }

    /**
     * @brief Determines whether a rename entry failed.
     * @param entry Entry containing sourcePath and targetPath.
     */
    function isFailedEntry(entry) {
        if (root.errorMessage.length === 0)
            return false

        return root.errorMessage.includes(entry.sourcePath)
            || root.errorMessage.includes(entry.targetPath)
    }

    /**
     * @brief Returns the display color for a rename entry.
     * @param entry Entry containing sourcePath and targetPath.
     * @param index Entry index in the preview list.
     */
    function entryColor(entry, index) {
        if (isFailedEntry(entry))
            return "#ef5350"

        if (entry.sourcePath.toUpperCase().includes("UNTITLED")
            || entry.targetPath.toUpperCase().includes("UNTITLED"))
            return "#ffd54f"

        if (root.renaming && index >= root.progressCurrent)
            return AppColors.settingsTextSecondary

        return AppColors.settingsTextPrimary
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
            visible: !root.renaming && root.previewEntries.length === 0
        }

        ColumnLayout {
            id: renameResults
            objectName: "renameResults"

            Layout.fillWidth: true
            Layout.fillHeight: root.previewEntries.length > 0
            Layout.preferredHeight: root.previewEntries.length > 0 ? 180 : 0
            Layout.maximumHeight: 360

            visible: root.previewEntries.length > 0


            RowLayout {
                Layout.fillWidth: true

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Rename results")
                    color: AppColors.settingsTextPrimary
                    font.bold: true
                }

                Label {
                    objectName: "renameFileCountLabel"
                    text: qsTr("%1 / %2 processed")
                        .arg(Math.min(root.progressCurrent, root.previewEntries.length))
                        .arg(root.previewEntries.length)
                    color: AppColors.settingsTextSecondary
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: AppMetrics.spacingMedium

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Old name")
                    color: AppColors.settingsTextSecondary
                    font.bold: true
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("New name")
                    color: AppColors.settingsTextSecondary
                    font.bold: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 80

                color: AppColors.navigationPanel
                border.color: AppColors.settingsSeparator
                radius: 4
                clip: true

                ListView {
                    id: renameResultsList
                    objectName: "renameResultsList"

                    anchors.fill: parent
                    clip: true
                    model: root.previewEntries
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: renameResultsList.width
                        height: Math.max(oldPathLabel.implicitHeight, newPathLabel.implicitHeight) + 12

                        color: "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: AppMetrics.spacingSmall
                            anchors.rightMargin: AppMetrics.spacingSmall
                            spacing: AppMetrics.spacingMedium

                            Label {
                                id: oldPathLabel

                                Layout.fillWidth: true
                                text: root.displayPath(modelData.sourcePath)
                                color: root.entryColor(modelData, index)
                                elide: Text.ElideMiddle
                                verticalAlignment: Text.AlignVCenter

                                ToolTip.visible: oldPathMouse.containsMouse
                                ToolTip.text: modelData.sourcePath

                                MouseArea {
                                    id: oldPathMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.NoButton
                                }
                            }

                            Label {
                                id: newPathLabel

                                Layout.fillWidth: true
                                text: root.displayPath(modelData.targetPath)
                                color: root.entryColor(modelData, index)
                                elide: Text.ElideMiddle
                                verticalAlignment: Text.AlignVCenter

                                ToolTip.visible: newPathMouse.containsMouse
                                ToolTip.text: modelData.targetPath

                                MouseArea {
                                    id: newPathMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.NoButton
                                }
                            }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 1
                            color: AppColors.settingsSeparator
                        }
                    }
                }
            }
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