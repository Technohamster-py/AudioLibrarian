import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts


Item {
    id: root

    property string currentFilePath: ""

    function revealFile(filePath) {
        if (filePath.length === 0)
            return

        const fileIndex = fileModel.indexForPath(filePath)

        if (!fileIndex.valid)
            return

        const parents = []

        let parentIndex = fileIndex.parent()

        while (parentIndex.valid) {
            parents.push(parentIndex)
            parentIndex = parentIndex.parent()
        }

        for (let i = parents.length - 1; i >= 0; --i)
            treeView.expand(parents[i])

        treeView.currentIndex = fileIndex
    }


    Connections {
        target: fileModel

        function onLoadingChanged() {
            if (!fileModel.loading && root.currentFilePath.length > 0)
                root.revealFile(root.currentFilePath)
        }
    }

    signal fileSelected(string filePath)

    FileTreeModel {
        id: fileModel

        objectName: "fileTreeModel"

        rootPath: SettingsManager.baseDir
    }

    TreeView {
        id: treeView

        objectName: "fileTreeView"

        anchors.fill: parent
        anchors.margins: AppMetrics.spacingLarge

        clip: true

        model: fileModel

        columnWidthProvider: function(column) {
            return column === 0 ? 1 : 0
        }

        rowHeightProvider: function(row) {
            return 32
        }

        delegate: TreeViewDelegate {
            id: delegate

            implicitHeight: 32

            background: Rectangle {
                color: delegate.current ? AppColors.playerBackground : (delegate.row % 2 === 0 ? AppColors.surface : AppColors.surfaceElevated)
            }
            contentItem: RowLayout {
                spacing: 0

                Label {
                    Layout.preferredWidth: 260
                    Layout.fillHeight: true

                    verticalAlignment: Text.AlignVCenter

                    text: model.fileName

                    elide: Text.ElideRight

                    color: AppColors.textPrimary
                }

                Label {
                    Layout.preferredWidth: 100
                    Layout.fillHeight: true

                    verticalAlignment: Text.AlignVCenter

                    text: fileModel.isDirectory(treeView.index(delegate.row, 0)) ? "" : formatFileSize(model.fileSize)

                    elide: Text.ElideRight

                    color: AppColors.textSecondary
                }

                Label {
                    Layout.preferredWidth: 180
                    Layout.fillHeight: true

                    verticalAlignment: Text.AlignVCenter

                    text: model.artist

                    elide: Text.ElideRight

                    color: AppColors.textPrimary
                }

                Label {
                    Layout.preferredWidth: 220
                    Layout.fillHeight: true

                    verticalAlignment: Text.AlignVCenter

                    text: model.album

                    elide: Text.ElideRight

                    color: AppColors.textPrimary
                }

                Label {
                    Layout.preferredWidth: 80
                    Layout.fillHeight: true

                    verticalAlignment: Text.AlignVCenter

                    text: model.year

                    elide: Text.ElideRight

                    color: AppColors.textSecondary
                }

                Label {
                    Layout.preferredWidth: 100
                    Layout.fillHeight: true

                    verticalAlignment: Text.AlignVCenter

                    text: model.duration

                    elide: Text.ElideRight

                    color: AppColors.textSecondary
                }

                Label {
                    Layout.preferredWidth: 140
                    Layout.fillHeight: true

                    verticalAlignment: Text.AlignVCenter

                    text: model.genre

                    elide: Text.ElideRight

                    color: AppColors.textPrimary
                }

                Label {
                    Layout.preferredWidth: 70
                    Layout.fillHeight: true

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    text: model.hasLyrics ? "✓" : ""

                    color: AppColors.textSecondary
                }
            }

            onClicked: {
                const modelIndex = treeView.index(row, 0)

                if (!modelIndex.valid) return

                if (fileModel.isDirectory(modelIndex)) return

                const path = fileModel.filePath(modelIndex)

                if (path.length === 0) return

                root.currentFilePath = path
                root.fileSelected(path)
            }
        }
    }

    /**
     * @brief Converts a file size in bytes into a human-readable string.
     *
     * @param bytes File size in bytes.
     * @return Formatted file size.
     */
    function formatFileSize(bytes) {
        if (bytes <= 0)
            return ""

        if (bytes < 1024)
            return qsTr("%1 B").arg(bytes)

        if (bytes < 1024 * 1024)
            return qsTr("%1 KB").arg(
                        (bytes / 1024).toFixed(1)
                    )

        if (bytes < 1024 * 1024 * 1024)
            return qsTr("%1 MB").arg(
                        (bytes / (1024 * 1024)).toFixed(1)
                    )

        return qsTr("%1 GB").arg(
                    (bytes / (1024 * 1024 * 1024)).toFixed(1)
                )
    }

    /*
     * Loading overlay.
     *
     * The TreeView remains underneath the overlay so the user does not
     * perceive the navigation pane as broken or empty while the filesystem
     * model is being populated.
     */
    Rectangle {
        anchors.fill: parent

        color: AppColors.background

        visible: fileModel.loading

        z: 10

        ColumnLayout {
            anchors.centerIn: parent

            spacing: AppMetrics.spacingMedium

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter

                running: fileModel.loading
            }

            Label {
                Layout.alignment: Qt.AlignHCenter

                text: qsTr("Scanning files...")

                color: AppColors.textSecondary
            }
        }
    }

    Connections {
        target: SettingsManager

        function onBaseDirChanged() {
            fileModel.rootPath = SettingsManager.baseDir
        }
    }
}