import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQml.Models

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

    ItemSelectionModel {
        id: treeSelectionModel

        model: fileModel
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

            Row {
                id: headerRow

                x: -fileTable.contentX

                height: parent.height

                Repeater {
                    model: fileModel.columnCount()

                    delegate: Rectangle {
                        required property int index

                        readonly property bool sorted: root.sortColumn === index

                        width: root.columnWidth(index)
                        height: tableHeader.height

                        color: sorted ? AppColors.surfaceSelected : sortArea.containsMouse ? AppColors.hover : AppColors.surfaceElevated

                        /**
                         * @brief Sorts the table when the header is clicked.
                         */
                        MouseArea {
                            id: sortArea

                            anchors.fill: parent

                            anchors.rightMargin: resizeArea.width

                            hoverEnabled: true

                            cursorShape: Qt.ArrowCursor

                            onClicked: {
                                if (root.sortColumn === index) {
                                    root.sortOrder = root.sortOrder === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder
                                } else {
                                    root.sortColumn = index
                                    root.sortOrder = Qt.AscendingOrder
                                }
                                libraryModel.sort(index, root.sortOrder)
                            }
                        }

                        /**
                         * @brief Header text.
                         */
                        Label {
                            anchors.fill: parent

                            anchors.leftMargin: AppMetrics.spacingMedium
                            anchors.rightMargin: AppMetrics.spacingMedium + resizeArea.width + sortIndicator.width

                            verticalAlignment: Text.AlignVCenter

                            text: fileModel.headerData(index, Qt.Horizontal, Qt.DisplayRole)

                            color: AppColors.textSecondary

                            elide: Text.ElideRight
                        }

                        /**
                         * @brief Indicates the current sorting direction.
                         *
                         * The indicator is displayed only for the column currently used for
                         * sorting.
                         */
                        Image {
                            id: sortIndicator

                            anchors.right: resizeArea.left
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter

                            width: AppMetrics.sortIconSize
                            height: AppMetrics.sortIconSize

                            visible: sorted

                            fillMode: Image.PreserveAspectFit

                            source: root.sortOrder === Qt.AscendingOrder ? AppAssets.sortAscending : AppAssets.sortDescending
                        }

                        /**
                         * @brief Interactive column resize area.
                         */
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
                                    if (active)
                                        initialWidth = root.columnWidth(index)
                                }

                                onTranslationChanged: {
                                    if (!active)
                                        return

                                    root.setColumnWidth(index, initialWidth + translation.x)
                                }
                            }
                        }

                        /**
                         * @brief Visual resize indicator.
                         */
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

        TreeView {
            id: treeView

            objectName: "fileTreeView"

            anchors.fill: parent
            anchors.margins: AppMetrics.spacingLarge

            clip: true

            model: fileModel
            selectionModel: treeSelectionModel

            columnWidthProvider: function(column) {
                switch (column) {
                    case 0: return 260   // Название
                    case 1: return 180   // Исполнитель
                    case 2: return 220   // Альбом
                    case 3: return 80    // Год
                    case 4: return 100   // Продолжительность
                    case 5: return 140   // Жанр
                    case 6: return 70    // Слова
                    default: return 100
                }
            }

            rowHeightProvider: function(row) {
                return 32
            }

            delegate: TreeViewDelegate {
                id: delegate

                background: Rectangle {
                    color: delegate.current
                        ? AppColors.playerBackground
                        : (delegate.row % 2 === 0
                            ? AppColors.surface
                            : AppColors.surfaceElevated)
                }

                implicitHeight: 32

                onClicked: {
                    const modelIndex = treeView.index(row, column)

                    if (!modelIndex.valid)
                        return

                    if (fileModel.isDirectory(modelIndex))
                        return

                    treeSelectionModel.setCurrentIndex(
                        modelIndex,
                        ItemSelectionModel.ClearAndSelect
                    )

                    const path = fileModel.filePath(modelIndex)

                    if (path.length === 0)
                        return

                    root.fileSelected(path)
                }
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
