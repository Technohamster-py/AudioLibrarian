import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQml.Models

Item {
    id: root

    property string currentFilePath: ""

    property var columnWidths: [
        260, // File Name
        180, // Artist
        220, // Album
        80,  // Year
        100, // Duration
        140, // Genre
        70   // Lyrics
    ]

    readonly property real minimumColumnWidth: 50

    function columnWidth(column) {
        if (column < 0 || column >= root.columnWidths.length)
            return 100

        return root.columnWidths[column]
    }

    function setColumnWidth(column, width) {
        if (column < 0 || column >= root.columnWidths.length)
            return

        const widths = root.columnWidths.slice()

        widths[column] = Math.max(root.minimumColumnWidth, width)

        root.columnWidths = widths

        treeView.forceLayout()
    }

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

        treeSelectionModel.setCurrentIndex(fileIndex.siblingAtColumn(0), ItemSelectionModel.ClearAndSelect)
        treeView.currentIndex = fileIndex.siblingAtColumn(0)
    }

    function selectRow(row) {
        const modelIndex = treeView.index(row, 0)

        if (!modelIndex.valid)
            return

        if (fileModel.isDirectory(modelIndex))
            return

        treeSelectionModel.setCurrentIndex(modelIndex, ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Rows)

        const path = fileModel.filePath(modelIndex)

        if (path.length === 0)
            return

        root.currentFilePath = path
        root.fileSelected(path)
    }

    signal fileSelected(string filePath)

    FileTreeModel {
        id: fileModel

        objectName: "fileTreeModel"
        rootPath: SettingsManager.baseDir
    }

    ItemSelectionModel {
        id: treeSelectionModel

        model: fileModel
    }

    Connections {
        target: fileModel

        function onLoadingChanged() {
            if (!fileModel.loading && root.currentFilePath.length > 0) {
                root.revealFile(root.currentFilePath)
            }
        }
    }

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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppMetrics.spacingLarge

        spacing: AppMetrics.spacingMedium

        Rectangle {
            id: tableHeader

            Layout.fillWidth: true
            Layout.preferredHeight: 36

            color: AppColors.surfaceElevated

            clip: true

            Item {
                id: headerViewport

                anchors.fill: parent

                clip: true

                Row {
                    id: headerRow

                    x: -treeView.contentX

                    height: tableHeader.height

                    width: {
                        let result = 0

                        for (let i = 0; i < root.columnWidths.length; ++i) {
                            result += root.columnWidth(i)
                        }
                        return result
                    }

                    Repeater {
                        model: fileModel.columnCount()

                        delegate: Rectangle {
                            required property int index

                            width: root.columnWidth(index)
                            height: tableHeader.height

                            color: AppColors.surfaceElevated

                            /*
                             * Header text.
                             */
                            Label {
                                anchors.fill: parent

                                anchors.leftMargin: AppMetrics.spacingMedium

                                anchors.rightMargin: AppMetrics.spacingMedium + resizeArea.width

                                verticalAlignment: Text.AlignVCenter

                                text: fileModel.headerData(index, Qt.Horizontal, Qt.DisplayRole)

                                color: AppColors.textSecondary

                                elide: Text.ElideRight
                            }

                            MouseArea {
                                id: resizeArea

                                width: 8
                                height: parent.height

                                anchors.right: parent.right

                                anchors.top: parent.top

                                hoverEnabled: true

                                cursorShape: Qt.SizeHorCursor

                                DragHandler {
                                    id: resizeHandler

                                    target: null

                                    xAxis.enabled: true
                                    yAxis.enabled: false

                                    property real initialWidth: 0

                                    onActiveChanged: {
                                        if (active) {
                                            initialWidth = root.columnWidth(index)
                                        }
                                    }

                                    onTranslationChanged: {
                                        if (!active)
                                            return
                                        root.setColumnWidth(index, initialWidth + translation.x)
                                    }
                                }
                            }

                            Rectangle {
                                anchors.centerIn: resizeArea

                                width: 1

                                height: parent.height * 0.45

                                color: resizeArea.containsMouse ? AppColors.textPrimary : "transparent"
                            }
                        }
                    }
                }
            }
        }

        TreeView {
            id: treeView

            objectName: "fileTreeView"

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true

            model: fileModel
            selectionModel: treeSelectionModel

            selectionBehavior: TableView.SelectRows
            selectionMode: TableView.SingleSelection

            columnWidthProvider: function(column) {
                return root.columnWidth(column)
            }

            rowHeightProvider: function(row) {
                return 32
            }

            delegate: TreeViewDelegate {
                id: delegate

                implicitHeight: 32

                background: Rectangle {
                    color: delegate.row === treeView.currentRow ? AppColors.playerBackground : (delegate.row % 2 === 0 ? AppColors.surface : AppColors.surfaceElevated)
                }

                contentItem: Item {
                    implicitWidth: 100
                    implicitHeight: 32

                    Label {
                        anchors.fill: parent

                        anchors.leftMargin: AppMetrics.spacingMedium
                        anchors.rightMargin: AppMetrics.spacingMedium

                        verticalAlignment: Text.AlignVCenter

                        visible: column !== FileTreeModel.HasLyrics

                        text: model.display ?? ""

                        color: AppColors.textPrimary

                        elide: Text.ElideRight
                    }

                    Label {
                        anchors.centerIn: parent

                        visible: column === FileTreeModel.HasLyrics

                        text: model.hasLyrics ? "✓" : ""

                        color: AppColors.textPrimary

                        font.pixelSize: 18
                    }
                }

                onClicked: {
                    root.selectRow(row)
                }
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
