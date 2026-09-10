import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Controls

/**
 * @brief Settings and result view for duplicate file search.
 */
Item {
    id: root

    /** @brief Enables byte-identical file search using SHA-256. */
    property bool searchByHash: true

    /** @brief Enables duplicate search using audio metadata. */
    property bool searchByMetadata: true

    /** @brief Enables duplicate search using file names. */
    property bool searchByFileName: false

    /** @brief Maximum allowed duration difference in seconds. */
    property int durationTolerance: 2

    /** @brief Indicates that duplicate search is currently running. */
    property bool searching: false

    /** @brief Number of files analyzed during the latest search. */
    property int analyzedFileCount: 0

    /** @brief Number of duplicate groups in the latest result. */
    property int duplicateGroupCount: 0

    /** @brief Number of files participating in duplicate groups. */
    property int duplicateFileCount: 0

    /** @brief Number of files that can be removed while keeping one copy. */
    property int removableFileCount: 0

    property var resultModel

    /** @brief Requests a duplicate search with the current settings. */
    signal searchRequested(
        bool searchByHash,
        bool searchByMetadata,
        bool searchByFileName,
        int durationTolerance
    )

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppMetrics.spacingLarge

        spacing: AppMetrics.spacingMedium

        Label {
            Layout.fillWidth: true

            text: qsTr("Search settings")

            color: AppColors.settingsTextPrimary

            font.pixelSize: 24
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: AppColors.settingsSeparator
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: AppMetrics.spacingSmall

            palette.window: AppColors.navigationPanel
            palette.base: AppColors.navigationPanel
            palette.alternateBase: AppColors.navigationElevated
            palette.text: AppColors.textPrimary
            palette.windowText: AppColors.textPrimary
            palette.button: AppColors.navigationElevated
            palette.buttonText: AppColors.textPrimary
            palette.highlight: AppColors.navigationAccent
            palette.highlightedText: AppColors.textPrimary

            CheckBox {
                id: hashCheckBox
                objectName: "searchByHashCheckBox"

                text: qsTr("Search by file content (hash)")
                palette.windowText: AppColors.textPrimary

                checked: root.searchByHash

                onToggled: {
                    root.searchByHash = checked
                }
            }

            Rectangle {
                Layout.preferredHeight: 20
                Layout.preferredWidth: 1

                color: AppColors.settingsSeparator
            }

            CheckBox {
                id: metadataCheckBox
                objectName: "searchByMetadataCheckBox"

                text: qsTr("Search by metadata")
                palette.windowText: AppColors.textPrimary


                checked: root.searchByMetadata

                onToggled: {
                    root.searchByMetadata = checked
                }
            }

            Rectangle {
                Layout.preferredHeight: 20
                Layout.preferredWidth: 1

                color: AppColors.settingsSeparator
            }

            CheckBox {
                id: fileNameCheckBox
                objectName: "searchByFileNameCheckBox"

                text: qsTr("Search by file name")
                palette.windowText: AppColors.textPrimary


                checked: root.searchByFileName

                onToggled: {
                    root.searchByFileName = checked
                }
            }

            Rectangle {
                Layout.preferredHeight: 20
                Layout.preferredWidth: 1

                color: AppColors.settingsSeparator
            }

            Label {
                text: qsTr("Duration tolerance")

                color: AppColors.settingsTextPrimary
            }

            SpinBox {
                id: durationToleranceSpinBox
                objectName: "durationToleranceSpinBox"

                Layout.preferredWidth: 140

                from: 0
                to: 3600
                stepSize: 1
                value: root.durationTolerance

                editable: true
                live: true

                property string suffix: qsTr(" sec")

                textFromValue: function(value, locale) {
                    return Number(value).toLocaleString(locale, 'f', 0) + suffix
                }

                valueFromText: function(text, locale) {
                    const number = text.replace(/[^\d]/g, "")

                    if (number.length === 0)
                        return value

                    return Number.fromLocaleString(locale, number)
                }

                enabled: root.searchByMetadata

                onValueModified: {
                    root.durationTolerance = value
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            Layout.topMargin: AppMetrics.spacingMedium

            color: AppColors.settingsSeparator
        }

        RowLayout {
            Layout.fillWidth: true

            Button {
                id: searchButton
                objectName: "findDuplicatesButton"

                Layout.alignment: Qt.AlignRight

                text: qsTr("Find duplicates")

                background: Rectangle {
                    color: AppColors.accentPrimary
                }

                enabled: !root.searching
                    && (root.searchByHash
                        || root.searchByMetadata
                        || root.searchByFileName)

                onClicked: {
                    root.searchRequested(root.searchByHash, root.searchByMetadata, root.searchByFileName, root.durationTolerance)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: AppMetrics.spasingMedium

            Label {
                text: qsTr("Result")

                color: AppColors.settingsTextPrimary

                font.pixelSize: AppMetrics.fontSizeLarge
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Groups: %1").arg(root.duplicateGroupCount)
                color: AppColors.settingsTextSecondary
            }

            Label {
                text: qsTr("Files analyzed: %1").arg(root.analyzedFileCount)
                color: AppColors.settingsTextSecondary
            }

            // Label {
            //     text: qsTr("Duplicate files: %1").arg(root.duplicateFileCount)
            //     color: AppColors.settingsTextSecondary
            // }
            //
            // Label {
            //     text: qsTr("Removable: %1").arg(root.removableFileCount)
            //     color: AppColors.settingsTextSecondary
            // }
        }

        Rectangle {
            id: resultPanel
            objectName: "duplicateResultPanel"

            Layout.fillWidth: true
            Layout.fillHeight: true

            color: AppColors.settingsBackground

            border.width: 1
            border.color: AppColors.settingsSeparator

            BusyIndicator {
                anchors.centerIn: parent
                running: root.searching
            }

            Menu {
                id: fileContextMenu

                palette.window: AppColors.navigationPanel
                palette.base: AppColors.navigationPanel
                palette.alternateBase: AppColors.navigationElevated
                palette.text: AppColors.textPrimary
                palette.windowText: AppColors.textPrimary
                palette.button: AppColors.navigationElevated
                palette.buttonText: AppColors.textPrimary
                palette.highlight: AppColors.navigationAccent
                palette.highlightedText: AppColors.textPrimary

                property string filePath
                property string relativeFilePath

                MenuItem {
                    text: qsTr("Expand all")

                    onTriggered: {
                        duplicateTreeView.expandRecursively()
                    }
                }

                MenuItem {
                    text: qsTr("Collapse all")

                    onTriggered: {
                        duplicateTreeView.collapseRecursively()
                    }
                }

                MenuSeparator {}

                MenuItem {
                    text: qsTr("Delete this file")

                    enabled: fileContextMenu.filePath !== ""
                    onTriggered: {
                        duplicateFinderController.deleteFile(fileContextMenu.filePath)
                    }
                }

                MenuItem {
                    text: qsTr("Keep this file")

                    enabled: fileContextMenu.filePath !== ""
                    onTriggered: {
                        root.keepFileRequested(fileContextMenu.filePath)
                    }
                }

                MenuSeparator {}

                MenuItem {
                    text: qsTr("Open in external app")

                    enabled: fileContextMenu.filePath !== ""
                    onTriggered: {
                        Qt.openUrlExternally(
                            Qt.resolvedUrl("file://" + fileContextMenu.filePath)
                        )
                    }
                }
            }

            TreeView {
                id: duplicateTreeView
                objectName: "duplicateResultTreeView"

                anchors.fill: parent
                anchors.margins: AppMetrics.spacingSmall

                visible: !root.searching && root.duplicateGroupCount > 0

                clip: true

                model: root.resultModel

                columnWidthProvider: function(column) {
                    return width;
                }

                delegate: TreeViewDelegate {
                    id: treeDelegate

                    implicitHeight: model.nodeType === 0 ? AppMetrics.duplicatesRowHeightLarge : AppMetrics.duplicatesRowHeightSmall
                    text: model.display
                    highlighted: selected
                    width: treeView.width

                    font.pixelSize: model.nodeType === 0 ? AppMetrics.duplicatesFontLarge : (model.nodeType === 1 ? AppMetrics.duplicatesFontMedium : AppMetrics.duplicatesFontSmall)

                    enabled: model.nodeType !== 2 || model.active
                    font.strikeout: model.nodeType === 2 && !model.active
                    opacity: model.nodeType === 2 && !model.active ? 0.45 : 1.0

                    background: Rectangle {
                        color: treeDelegate.row === duplicateTreeView.currentRow ? AppColors.navigationAccent : (model.nodeType === 0 ? AppColors.duplicatesMethodColor : (treeDelegate.row % 2 === 0 ? AppColors.navigationPanel : AppColors.navigationElevated))
                    }

                    ToolTip.visible: hovered && isTreeNode && model.nodeType === 2
                    ToolTip.text: model.relativeFilePath
                    ToolTip.delay: 500

                    TapHandler {
                        acceptedButtons: Qt.RightButton

                        onTapped: function (eventPoint, button) {
                            fileContextMenu.filePath = ""
                            fileContextMenu.relativeFilePath = ""

                            if (model.nodeType === 2) {
                                fileContextMenu.filePath = model.filePath
                                fileContextMenu.relativeFilePath = model.relativeFilePath
                            }
                            fileContextMenu.popup()
                        }
                    }
                }
            }

            Label {
                anchors.centerIn: parent

                visible: !root.searching && root.duplicateGroupCount === 0

                text: qsTr("No duplicate groups found")

                color: AppColors.settingsTextSecondary
            }
        }
    }
}
