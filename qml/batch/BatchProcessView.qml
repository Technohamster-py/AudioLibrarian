import QtQuick
import QtQuick.Controls.FluentWinUI3
import QtQuick.Layouts

/**
 * @brief Common workspace for batch processing operations.
 */
Item {
    id: root
    signal filesUpdated(var filePaths)

    /** @brief Currently selected batch operation. */
    property int operationIndex: 0

    property string baseFilePath: SettingsManager.baseDir

    property var playerController

    DuplicateFinderController {
        id: duplicateFinderController
        objectName: "duplicateFinderController"
    }

    MetadataEditorController {
        onFilesUpdated: function(filePaths) { root.filesUpdated(filePaths) }
        id: metadataEditorController
        objectName: "metadataEditorController"
    }

    FileRenamerController {
        id: fileRenamerController
        objectName: "fileRenamerController"
    }

    Connections {
        target: duplicateFinderController

        function onOperationAboutToStart() {
            if (root.playerController)
                root.playerController.releaseSource();
        }
    }

    Connections {
        target: metadataEditorController

        function onOperationAboutToStart() {
            if (root.playerController)
                root.playerController.releaseSource();
        }
    }

    Connections {
        target: fileRenamerController

        function onOperationAboutToStart() {
            if (root.playerController)
                root.playerController.releaseSource();
        }
    }

    Rectangle {
        x: pageLayout.x + operationStack.x
        y: pageLayout.y + operationStack.y
        width: operationStack.width
        height: operationStack.height
        color: AppColors.panel
        radius: AppMetrics.radiusMedium
        border.color: AppColors.separator
    }

    ColumnLayout {
        id: pageLayout
        anchors.fill: parent
        anchors.margins: AppMetrics.pagePadding

        spacing: AppMetrics.spacingLarge

        Label {
            Layout.fillWidth: true
            text: qsTr("Batch processing")
            color: AppColors.textPrimary
            font.pixelSize: AppMetrics.fontSizeTitle
            font.weight: Font.DemiBold
        }

        Label {
            Layout.fillWidth: true
            text: qsTr("Base directory")
            color: AppColors.textSecondary
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: AppMetrics.spacingMedium

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
                    const directory = FileDialogController.getExistingDirectory(qsTr("Select base directory"), root.baseFilePath);

                    if (directory.length > 0)
                        root.baseFilePath = directory;
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: AppMetrics.spacingMedium

            ComboBox {
                id: operationComboBox
                objectName: "batchOperationComboBox"

                Layout.fillWidth: true

                model: [qsTr("Find duplicates"), qsTr("Edit metadata"), qsTr("Rename files")]

                currentIndex: root.operationIndex

                onActivated: {
                    root.operationIndex = currentIndex;
                }
            }

            Button {
                id: searchButton
                objectName: "findDuplicatesButton"
                highlighted: true

                text: qsTr("Find duplicates")

                Layout.preferredHeight: operationComboBox.height
                Layout.minimumHeight: operationComboBox.height
                Layout.maximumHeight: operationComboBox.height

                visible: root.operationIndex === 0
                enabled: !duplicateFinderView.searching && (duplicateFinderView.searchByHash || duplicateFinderView.searchByMetadata || duplicateFinderView.searchByFileName)

                onClicked: duplicateFinderView.searchRequested(duplicateFinderView.searchByHash, duplicateFinderView.searchByMetadata, duplicateFinderView.searchByFileName, duplicateFinderView.durationTolerance)
            }

            Button {
                id: applyButton
                objectName: "applyMetadataChangesButton"
                highlighted: true

                text: qsTr("Apply changes")

                Layout.preferredHeight: operationComboBox.height
                Layout.minimumHeight: operationComboBox.height
                Layout.maximumHeight: operationComboBox.height

                visible: root.operationIndex === 1
                enabled: metadataEditorView.editing && metadataEditorView.selectedFileCount > 0 && metadataEditorView.hasChanges()

                onClicked: metadataEditorView.changesRequested(metadataEditorView.createChanges())
            }

            Button {
                id: renameButton
                objectName: "renameFilesButton"
                highlighted: true

                text: qsTr("Preview rename")

                Layout.preferredHeight: operationComboBox.height
                Layout.minimumHeight: operationComboBox.height
                Layout.maximumHeight: operationComboBox.height

                visible: root.operationIndex === 2
                enabled: renameView.canPreview

                onClicked: renameView.requestPreview()
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

                onSearchRequested: function (searchByHash, searchByMetadata, searchByFileName, durationTolerance) {
                    duplicateFinderController.start(root.baseFilePath, searchByHash, searchByMetadata, searchByFileName, durationTolerance);
                }
            }

            MetadataEditorView {
                id: metadataEditorView
                objectName: "metadataEditorView"

                editing: metadataEditorController.running
                selectedFileCount: metadataEditorController.selectedFileCount

                onChangesRequested: function (changes) {
                    metadataEditorController.start(root.baseFilePath, changes);
                }
            }

            BatchRenamerView {
                id: renameView
                objectName: "renameView"

                renaming: fileRenamerController.running
                baseDirectory: root.baseFilePath

                onPreviewRequested: function (templatePattern) {
                    const result = fileRenamerController.preparePreview(root.baseFilePath, templatePattern);

                    if (!result || result.error) {
                        renameView.errorMessage = result ? result.error : qsTr("Preview failed");
                        renameView.previewEntries = [];
                        return;
                    }

                    const entries = result.entries || [];

                    if (entries.length === 0) {
                        renameView.errorMessage = qsTr("No files to rename");
                        renameView.previewEntries = [];
                        return;
                    }

                    renameView.errorMessage = "";
                    renameView.previewEntries = entries;
                    renameView.previewVisible = true;
                }

                onConfirmRenameRequested: {
                    if (fileRenamerController.confirmRename())
                        renameView.previewVisible = false;
                    else
                        renameView.errorMessage = fileRenamerController.errorMessage;
                }

                onCancelPreviewRequested: {
                    fileRenamerController.discardPreview();
                    renameView.previewEntries = [];
                    renameView.previewVisible = false;
                }

                Connections {
                    target: fileRenamerController

                    function onProgressChanged() {
                        renameView.progressCurrent = fileRenamerController.progressCurrent;
                        renameView.progressTotal = fileRenamerController.progressTotal;
                        renameView.currentFile = fileRenamerController.currentFile;
                    }

                    function onErrorMessageChanged() {
                        renameView.errorMessage = fileRenamerController.errorMessage;
                    }
                }
            }
        }
    }
}
