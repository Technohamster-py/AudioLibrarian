import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs

/**
 * @brief Common workspace for batch processing operations.
 */
Item {
    id: root

    /** @brief Currently selected batch operation. */
    property int operationIndex: 0

    property string baseFilePath: SettingsManager.baseDir

    FolderDialog {
        id: folderDialog

        title: qsTr("Select base directory")

        onAccepted: {
            root.baseFilePath = selectedFolder.toLocalFile()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppMetrics.spacingLarge

        spacing: AppMetrics.spacingMedium

        RowLayout {
            Layout.fillWidth: true

            TextField {
                id: baseFilePathField
                objectName: "baseFilePathField"

                Layout.fillWidth: true

                text: root.baseFilePath

                readOnly: true
            }

            Button {
                id: browseButton
                objectName: "baseFilePathBrowseButton"

                text: qsTr("Browse...")

                onClicked: {
                    folderDialog.open()
                }
            }
        }

        ComboBox {
            id: operationComboBox
            objectName: "batchOperationComboBox"

            Layout.fillWidth: true

            model: [
                qsTr("Find duplicates"),
                qsTr("Edit metadata"),
                qsTr("Rename files")
            ]

            currentIndex: root.operationIndex

            onActivated: {
                root.operationIndex = currentIndex
            }
        }

        StackLayout {
            id: operationStack
            objectName: "batchOperationStack"

            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: root.operationIndex

            DuplicateFinderView {
                id: duplicateFinderView
                objectName: "duplicateFinderView"

                searching: duplicateFinderController.running

                duplicateGroupCount: duplicateFinderController.duplicateGroupCount
                duplicateFileCount: duplicateFinderController.duplicateFileCount
                removableFileCount: duplicateFinderController.removableFileCount
                phase: duplicateFinderController.phase
                currentFile: duplicateFinderController.currentFile
                errorMessage: duplicateFinderController.errorMessage
                progressCurrent: duplicateFinderController.progressCurrent
                progressTotal: duplicateFinderController.progressTotal

                onSearchRequested: function(searchByHash, searchByMetadata, searchByFileName, durationTolerance) {
                    duplicateFinderController.start(
                        root.baseFilePath,
                        searchByHash,
                        searchByMetadata,
                        searchByFileName,
                        durationTolerance
                    )
                }

                onCancelRequested: duplicateFinderController.cancel()
            }

            Item {
                objectName: "metadataEditViewPlaceholder"

                Label {
                    anchors.centerIn: parent

                    text: qsTr("Metadata editor")
                    color: AppColors.settingsTextSecondary
                }
            }

            Item {
                objectName: "renameViewPlaceholder"

                Label {
                    anchors.centerIn: parent

                    text: qsTr("Rename files")
                    color: AppColors.settingsTextSecondary
                }
            }
        }
    }
}