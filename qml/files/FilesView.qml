import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Hierarchical filesystem navigation.
 *
 * Displays the configured music directory and allows selecting
 * individual audio files.
 */
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

        /*
         * SettingsManager is the authoritative source for the library
         * directory. This also makes changing the directory in Settings
         * immediately update the tree.
         */
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
            switch (column) {
                case 0: return 260   // Название
                case 1: return 180   // Исполнитель
                case 2: return 220   // Альбом
                case 3: return 80    // Год
                case 4: return 100   // Продолжительность
                case 5: return 140   // Жанр
                case 6: return 70    // Слова
                default: return 0
            }
        }

        rowHeightProvider: function(row) {
            return 32
        }

        delegate: TreeViewDelegate {
            id: delegate

            background: Rectangle {
                color: delegate.current ? AppColors.playerBackground : (delegate.row % 2 === 0 ? AppColors.surface : AppColors.surfaceElevated)
            }

            implicitHeight: 32

            onClicked: {
                const modelIndex = treeView.index(row, column)

                if (!modelIndex.valid)
                    return

                /*
                 * Directories are navigation elements and must not be
                 * interpreted as audio files.
                 */
                if (fileModel.isDirectory(modelIndex))
                    return

                const path = fileModel.filePath(modelIndex)

                if (path.length === 0)
                    return

                root.fileSelected(path)
            }
        }
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
            fileModel.rootPath =
                SettingsManager.baseDir
        }
    }
}
