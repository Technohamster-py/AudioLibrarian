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

        /*
         * Header and TableView are separate items.
         *
         * This guarantees that the header occupies its own layout space and
         * cannot overlap the first table row.
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

                        width: fileTable.columnWidthProvider(index)
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

                        TapHandler {
                            onTapped: {
                                libraryModel.sort(
                                    index,
                                    Qt.AscendingOrder
                                )
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
                switch (column) {
                    case AudioFileTableModel.Cover:
                        return 56

                    case AudioFileTableModel.FileName:
                        return 260

                    case AudioFileTableModel.Title:
                        return 220

                    case AudioFileTableModel.Artist:
                        return 180

                    case AudioFileTableModel.Album:
                        return 220

                    case AudioFileTableModel.Year:
                        return 80

                    case AudioFileTableModel.Duration:
                        return 90

                    case AudioFileTableModel.Genre:
                        return 140

                    case AudioFileTableModel.HasLyrics:
                        return 70

                    default:
                        return 120
                }
            }

            rowHeightProvider: function(row) {
                return 56
            }

            delegate: Rectangle {
                required property int row
                required property int column

                readonly property bool selected:
                    row === root.selectedIndex

                color: selected
                    ? AppColors.surfaceSelected
                    : AppColors.surface

                Loader {
                    anchors.centerIn: parent

                    active: column === AudioFileTableModel.Cover

                    sourceComponent: coverComponent
                }

                Component {
                    id: coverComponent

                    Rectangle {
                        width: 40
                        height: 40

                        radius: 2

                        color: AppColors.surfaceElevated

                        Image {
                            anchors.fill: parent
                            anchors.margins: 2

                            fillMode: Image.PreserveAspectFit

                            source: model.coverArtUrl && model.coverArtUrl.length > 0 ? model.coverArtUrl : "qrc:/qt/qml/AudioLibrarian/assets/music.svg"

                            visible: source.length > 0
                        }

                        Label {
                            anchors.centerIn: parent

                            visible: !model.cover ||
                                model.cover.length === 0

                            text: "♪"

                            color: AppColors.textSecondary
                            font.pixelSize: 20
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