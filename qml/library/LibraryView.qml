import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Audio library view.
 *
 * Displays all audio files provided by AudioFileTableModel.
 *
 * The model itself is implemented in C++ and performs recursive filesystem
 * scanning and metadata extraction. QML is responsible only for presenting
 * the data and controlling the visual column layout.
 */
Item {
    id: root

    /**
     * @brief Emitted when the user activates an audio file.
     *
     * The selected file can subsequently be opened by the tag editor or
     * passed to the player.
     *
     * @param filePath Absolute path of the selected audio file.
     */
    signal fileSelected(string filePath)

    /**
     * @brief C++ model containing the actual audio library.
     *
     * No temporary QML model is used here.
     */
    AudioFileTableModel {
        id: libraryModel

        objectName: "libraryModel"
    }

    /**
     * @brief Index of the currently selected row.
     */
    property int selectedIndex: -1

    /**
     * @brief Currently sorted column.
     *
     * A value of -1 means that no explicit sorting has been requested
     * by the user.
     */
    property int sortColumn: -1

    /**
     * @brief Current sorting direction.
     */
    property int sortOrder: Qt.AscendingOrder

    /**
     * @brief Minimum allowed width of a table column.
     */
    readonly property real minimumColumnWidth: AppMetrics.minimumLibraryColumnWidth
    readonly property real minimumCoverColumnWidth: AppMetrics.minimumCoverColumnWidth

    /**
     * @brief User-configurable visual widths of table columns.
     *
     * The keys correspond to AudioFileTableModel column identifiers.
     */
    property var columnWidths: ({
        [AudioFileTableModel.Cover]: 64,
        [AudioFileTableModel.FileName]: 260,
        [AudioFileTableModel.Title]: 220,
        [AudioFileTableModel.Artist]: 180,
        [AudioFileTableModel.Album]: 220,
        [AudioFileTableModel.Year]: 80,
        [AudioFileTableModel.Duration]: 90,
        [AudioFileTableModel.Genre]: 140,
        [AudioFileTableModel.HasLyrics]: 70
    })

    /**
     * @brief Returns the current visual width of a column.
     *
     * @param column Logical column index.
     * @return Column width in pixels.
     */
    function columnWidth(column) {
        const width = columnWidths[column] ?? minimumColumnWidth

        if (column === AudioFileTableModel.Cover)
            return Math.max(minimumCoverColumnWidth, width)
        return Math.max(minimumColumnWidth, width)
    }

    /**
     * @brief Changes the visual width of a column.
     *
     * @param column Logical column index.
     * @param width Requested new width.
     */
    function setColumnWidth(column, width) {
        const widths = Object.assign({}, columnWidths)

        const minimumWidth =
                column === AudioFileTableModel.Cover
            ? root.minimumCoverColumnWidth
            : root.minimumColumnWidth

        widths[column] = Math.max(
            minimumWidth,
            width
        )

        columnWidths = widths

        fileTable.forceLayout()
    }

    /**
     * @brief Selects an audio file.
     *
     * @param index Row index in the C++ model.
     */
    function selectFile(index) {
        if (index < 0 || index >= libraryModel.rowCount())
            return

        root.selectedIndex = index

        const modelIndex = libraryModel.index(
            index,
            AudioFileTableModel.FileName
        )

        const filePath = libraryModel.data(
            modelIndex,
            AudioFileTableModel.FilePathRole
        )

        root.fileSelected(filePath)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppMetrics.spacingLarge

        spacing: AppMetrics.spacingMedium

        Label {
            Layout.fillWidth: true

            text: qsTr("Library")

            color: AppColors.textPrimary
            font.pixelSize: 28
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: AppMetrics.spacingMedium

            Label {
                text: qsTr("%1 files").arg(libraryModel.rowCount())

                color: AppColors.textSecondary
            }

            Item {
                Layout.fillWidth: true
            }

            BusyIndicator {
                visible: libraryModel.loading

                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
            }
        }

        Rectangle {
            Layout.fillWidth: true

            height: 1

            color: AppColors.separator
        }

        /**
         * @brief Table header.
         *
         * The header is a separate item rather than a child of TableView.
         * This prevents it from overlapping the first row.
         */
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
                    model: libraryModel.columnCount()

                    delegate: Rectangle {
                        required property int index

                        width: root.columnWidth(index)
                        height: tableHeader.height

                        color: AppColors.surfaceElevated

                        Label {
                            anchors.fill: parent

                            anchors.leftMargin: 8
                            anchors.rightMargin: 8

                            verticalAlignment: Text.AlignVCenter

                            text: libraryModel.headerData(
                                index,
                                Qt.Horizontal,
                                Qt.DisplayRole
                            )

                            color: AppColors.textSecondary

                            elide: Text.ElideRight
                        }

                        /**
                         * @brief Sort area of the header.
                         *
                         * The resize area is placed on top of this area.
                         * Consequently a resize operation never reaches
                         * this MouseArea.
                         */
                        MouseArea {
                            id: sortArea

                            anchors.fill: parent

                            hoverEnabled: true

                            cursorShape: Qt.ArrowCursor

                            onClicked: function(mouse) {
                                /*
                                 * The resize area handles its own clicks.
                                 * This check is kept as an additional guard
                                 * against accidental sorting at the edge.
                                 */
                                if (mouse.x > width - resizeArea.width)
                                    return

                                if (root.sortColumn === index) {
                                    root.sortOrder =
                                            root.sortOrder ===
                                        Qt.AscendingOrder
                                        ? Qt.DescendingOrder
                                        : Qt.AscendingOrder
                                } else {
                                    root.sortColumn = index
                                    root.sortOrder =
                                        Qt.AscendingOrder
                                }

                                libraryModel.sort(
                                    index,
                                    root.sortOrder
                                )
                            }
                        }

                        /**
                         * @brief Interactive resize area.
                         *
                         * DragHandler captures the pointer when resizing
                         * starts. Therefore the column continues to resize
                         * even when the cursor leaves this narrow area.
                         */
                        Item {
                            id: resizeArea

                            width: 8
                            height: parent.height

                            anchors.right: parent.right
                            anchors.top: parent.top

                            DragHandler {
                                id: resizeHandler

                                target: null

                                xAxis.enabled: true
                                yAxis.enabled: false

                                property real initialWidth: 0

                                onActiveChanged: {
                                    if (active) {
                                        initialWidth =
                                            root.columnWidth(index)
                                    }
                                }

                                onTranslationChanged: {
                                    if (!active)
                                        return

                                    root.setColumnWidth(
                                        index,
                                        initialWidth + translation.x
                                    )
                                }
                            }

                            /**
                             * @brief Visual indicator of the resize handle.
                             */
                            Rectangle {
                                anchors.centerIn: parent

                                width: 1
                                height: parent.height * 0.45

                                color:
                                        resizeHandler.active ||
                                    resizeAreaMouse.containsMouse
                                    ? AppColors.textPrimary
                                    : "transparent"
                            }

                            /**
                             * @brief Provides hover state for the resize
                             *        handle.
                             *
                             * This MouseArea does not handle clicks or
                             * movement. DragHandler remains responsible
                             * for resizing.
                             */
                            MouseArea {
                                id: resizeAreaMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                acceptedButtons: Qt.NoButton

                                cursorShape: Qt.SizeHorCursor
                            }
                        }
                    }
                }
            }
        }

        TableView {
            id: fileTable

            objectName: "fileTable"

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true

            model: libraryModel

            columnSpacing: 0
            rowSpacing: 1

            columnWidthProvider: function(column) {
                return root.columnWidth(column)
            }

            rowHeightProvider: function(row) {
                return root.columnWidth(AudioFileTableModel.Cover)
            }

            delegate: Rectangle {
                required property int row
                required property int column

                readonly property bool selected: row === root.selectedIndex

                color: selected ? AppColors.surfaceSelected : AppColors.surface

                Loader {
                    anchors.centerIn: parent

                    active: column === AudioFileTableModel.Cover

                    sourceComponent: coverComponent
                }

                Component {
                    id: coverComponent

                    Rectangle {
                        width: Math.max(0, root.columnWidth(AudioFileTableModel.Cover) - AppMetrics.spacingSmall * 2)
                        height: width

                        radius: 2
                        color: AppColors.surfaceElevated

                        Image {
                            id: coverImage

                            anchors.fill: parent
                            anchors.margins: 2

                            fillMode: Image.PreserveAspectFit

                            source: {
                                if (!model.cover || model.cover.length === 0)
                                    return ""

                                return libraryModel.makeCoverUrl(model.cover)
                            }
                        }

                        Image {
                            anchors.centerIn: parent

                            width: parent.width * 0.5
                            height: parent.height * 0.5

                            visible: coverImage.status !== Image.Ready

                            fillMode: Image.PreserveAspectFit

                            source: "qrc:/qt/qml/AudioLibrarian/assets/music.svg"

                        }
                    }
                }

                Label {
                    anchors.fill: parent

                    anchors.leftMargin: 8
                    anchors.rightMargin: 8

                    verticalAlignment: Text.AlignVCenter

                    visible:
                        column !== AudioFileTableModel.Cover &&
                        column !== AudioFileTableModel.HasLyrics

                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary

                    elide: Text.ElideRight

                    text: {
                        switch (column) {
                            case AudioFileTableModel.FileName:
                                return model.fileName

                            case AudioFileTableModel.Title:
                                return model.title

                            case AudioFileTableModel.Artist:
                                return model.artist

                            case AudioFileTableModel.Album:
                                return model.album

                            case AudioFileTableModel.Year:
                                return model.year

                            case AudioFileTableModel.Duration:
                                return model.duration

                            case AudioFileTableModel.Genre:
                                return model.genre

                            default:
                                return ""
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent

                    visible:
                        column === AudioFileTableModel.HasLyrics

                    text: model.hasLyrics ? "✓" : ""

                    color: AppColors.textPrimary

                    font.pixelSize: 18
                }

                TapHandler {
                    onTapped: root.selectFile(row)
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            ScrollBar.horizontal: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }
    }
    /**
     * @brief Select the first file after the initial scan.
     *
     * This keeps the editor populated when the library is non-empty.
     */
    Connections {
        target: libraryModel

        function onLoadingChanged() {
            if (!libraryModel.loading &&
                root.selectedIndex < 0 &&
                libraryModel.rowCount() > 0) {
                root.selectFile(0)
            }
        }
    }
}
