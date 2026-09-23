import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Common workspace for batch processing operations.
 */
Item {
    id: root

    /** @brief Currently selected batch operation. */
    property int operationIndex: 0

    property string baseFilePath: SettingsManager.baseDir

    DuplicateFinderController {
        id: duplicateFinderController
        objectName: "duplicateFinderController"
    }

    MetadataEditorController {
        id: metadataEditorController
        objectName: "metadataEditorController"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppMetrics.spacingMedium

        spacing: AppMetrics.spacingMedium

        palette.window: AppColors.navigationPanel
        palette.base: AppColors.navigationPanel
        palette.alternateBase: AppColors.navigationElevated
        palette.text: AppColors.textPrimary
        palette.windowText: AppColors.textPrimary
        palette.button: AppColors.navigationElevated
        palette.buttonText: AppColors.textPrimary
        palette.highlight: AppColors.navigationAccent
        palette.highlightedText: AppColors.textPrimary

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
                    const directory = FileDialogController.getExistingDirectory(qsTr("Select base directory"), root.baseFilePath)

                    if (directory.length > 0)
                        root.baseFilePath = directory
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

                analyzedFileCount: duplicateFinderController.analyzedFileCount
                duplicateGroupCount: duplicateFinderController.duplicateGroupCount
                duplicateFileCount: duplicateFinderController.duplicateFileCount
                removableFileCount: duplicateFinderController.removableFileCount

                resultModel: duplicateFinderController.resultModel

                onSearchRequested: function(searchByHash, searchByMetadata, searchByFileName, durationTolerance) {
                    duplicateFinderController.start(
                        root.baseFilePath,
                        searchByHash,
                        searchByMetadata,
                        searchByFileName,
                        durationTolerance
                    )
                }
            }

            MetadataEditorView {
                id: metadataEditorView
                objectName: "metadataEditorView"

                editing: metadataEditorController.running
                selectedFileCount: metadataEditorController.selectedFileCount

                onChangesRequested: function(changes) {
                    metadataEditorController.start(
                        root.baseFilePath,
                        changes
                    )
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