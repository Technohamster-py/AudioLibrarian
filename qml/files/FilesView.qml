import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts


Item {
    id: root

    property string currentFilePath: ""

    readonly property int nameColumnWidth: 260
    readonly property int sizeColumnWidth: 100
    readonly property int artistColumnWidth: 180
    readonly property int albumColumnWidth: 220
    readonly property int yearColumnWidth: 80
    readonly property int durationColumnWidth: 100
    readonly property int genreColumnWidth: 140
    readonly property int lyricsColumnWidth: 70

    readonly property int contentWidth:
        nameColumnWidth
        + sizeColumnWidth
        + artistColumnWidth
        + albumColumnWidth
        + yearColumnWidth
        + durationColumnWidth
        + genreColumnWidth
        + lyricsColumnWidth

    function formatFileSize(bytes) {
        if (bytes < 1024)
            return bytes + " B"

        if (bytes < 1024 * 1024)
            return (bytes / 1024).toFixed(1) + " KB"

        if (bytes < 1024 * 1024 * 1024)
            return (bytes / (1024 * 1024)).toFixed(1) + " MB"

        return (bytes / (1024 * 1024 * 1024)).toFixed(1) + " GB"
    }

    function revealFile(filePath) {
        if (filePath.length === 0)
            return

        const fileIndex = fileModel.indexForPath(filePath)

        if (!fileIndex.valid)
            return

        const rootIndex = fileModel.rootIndex

        if (rootIndex.valid) {
            let parentIndex = fileIndex.parent()
            let belongsToRoot = fileIndex === rootIndex

            while (parentIndex.valid) {
                if (parentIndex === rootIndex) {
                    belongsToRoot = true
                    break
                }

                parentIndex = parentIndex.parent()
            }

            if (!belongsToRoot)
                return
        }

        const parents = []

        let parentIndex = fileIndex.parent()

        while (parentIndex.valid) {
            parents.push(parentIndex)

            if (rootIndex.valid && parentIndex === rootIndex)
                break

            parentIndex = parentIndex.parent()
        }

        for (let i = parents.length - 1; i >= 0; --i) {
            if (!rootIndex.valid || parents[i] !== rootIndex)
                treeView.expand(parents[i])
        }

        treeView.currentColumn = 0
        treeView.currentRow = treeView.rowAtIndex(fileIndex)
    }

    function processCurrentIndex(index) {
        if (!index.valid) return

        if (fileModel.isDirectory(index)) return

        const path = fileModel.filePath(index)

        if (path.length === 0) return

        root.fileSelected(path)
    }

    signal fileSelected(string filePath)


    FileTreeModel {
        id: fileModel

        objectName: "fileTreeModel"

        rootPath: SettingsManager.baseDir
    }


    Connections {
        target: fileModel

        function onLoadingChanged() {
            if (!fileModel.loading && root.currentFilePath.length > 0)
                root.revealFile(root.currentFilePath)
        }

        function onRootPathChanged() {
            treeView.rootIndex = fileModel.rootIndex
        }
    }

    TreeView {
        id: treeView

        objectName: "fileTreeView"

        anchors.fill: parent
        anchors.margins: AppMetrics.spacingLarge

        clip: true

        model: fileModel

        rootIndex: fileModel.rootIndex

        columnWidthProvider: function(column) {
            return column === 0 ? root.contentWidth : 0
        }

        rowHeightProvider: function(row) {
            return 32
        }

        onCurrentRowChanged: {
            if (currentRow < 0)
                return

            root.processCurrentIndex(treeView.index(currentRow, 0))
        }

        delegate: TreeViewDelegate {
            id: delegate

            implicitHeight: 32
            implicitWidth: root.contentWidth

            background: Rectangle {
                color: delegate.current
                       ? AppColors.playerBackground
                       : (delegate.row % 2 === 0
                          ? AppColors.surface
                          : AppColors.surfaceElevated)
            }

            contentItem: Row {
                id: metadataRow

                spacing: 0

                Label {
                    width: root.nameColumnWidth

                    anchors.verticalCenter: parent.verticalCenter

                    text: model.fileName

                    color: AppColors.textPrimary

                    elide: Text.ElideRight

                    verticalAlignment: Text.AlignVCenter
                }

                /*
                 * File size.
                 *
                 * QFileSystemModel provides the standard fileSize role.
                 * Directories do not have a meaningful audio-file size here.
                 */
                Label {
                    width: root.sizeColumnWidth

                    anchors.verticalCenter: parent.verticalCenter

                    text: fileModel.isDirectory(treeView.index(row, 0))
                          ? ""
                          : root.formatFileSize(model.fileSize)

                    color: AppColors.textSecondary

                    elide: Text.ElideRight

                    verticalAlignment: Text.AlignVCenter
                }

                /*
                 * Artist.
                 */
                Label {
                    width: root.artistColumnWidth

                    anchors.verticalCenter: parent.verticalCenter

                    text: model.artist

                    color: AppColors.textPrimary

                    elide: Text.ElideRight

                    verticalAlignment: Text.AlignVCenter
                }

                /*
                 * Album.
                 */
                Label {
                    width: root.albumColumnWidth

                    anchors.verticalCenter: parent.verticalCenter

                    text: model.album

                    color: AppColors.textPrimary

                    elide: Text.ElideRight

                    verticalAlignment: Text.AlignVCenter
                }

                /*
                 * Year.
                 */
                Label {
                    width: root.yearColumnWidth

                    anchors.verticalCenter: parent.verticalCenter

                    text: model.year

                    color: AppColors.textSecondary

                    elide: Text.ElideRight

                    verticalAlignment: Text.AlignVCenter
                }

                /*
                 * Duration.
                 */
                Label {
                    width: root.durationColumnWidth

                    anchors.verticalCenter: parent.verticalCenter

                    text: model.duration

                    color: AppColors.textSecondary

                    elide: Text.ElideRight

                    verticalAlignment: Text.AlignVCenter
                }

                /*
                 * Genre.
                 */
                Label {
                    width: root.genreColumnWidth

                    anchors.verticalCenter: parent.verticalCenter

                    text: model.genre

                    color: AppColors.textPrimary

                    elide: Text.ElideRight

                    verticalAlignment: Text.AlignVCenter
                }

                /*
                 * Lyrics indicator.
                 *
                 * A small indicator is used instead of a Unicode character.
                 * This avoids relying on font-specific glyphs.
                 */
                Item {
                    width: root.lyricsColumnWidth
                    height: parent.height

                    Rectangle {
                        width: 8
                        height: 8

                        anchors.centerIn: parent

                        radius: width / 2

                        visible: model.hasLyrics

                        color: AppColors.textPrimary
                    }
                }
            }
        }
    }

    /**
     * @brief Loading overlay displayed while QFileSystemModel loads the root.
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

    /**
     * @brief Updates the model root when the configured library directory
     * changes.
     */
    Connections {
        target: SettingsManager

        function onBaseDirChanged() {
            fileModel.rootPath = SettingsManager.baseDir
        }
    }
}
