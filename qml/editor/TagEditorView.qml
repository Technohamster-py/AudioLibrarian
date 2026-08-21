import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Audio metadata editor.
 *
 * This component represents the first version of the tag editor UI.
 *
 * All fields currently operate on local QML values. They are deliberately
 * not connected to a file-writing backend yet. Later this component will
 * communicate with a C++ metadata model/service.
 */
Item {
    id: root

    property string filePath: ""
    // Keep the display label derived from the path supplied by MainWindow.
    property string fileName: filePath.length > 0 ? filePath.substring(filePath.lastIndexOf("/") + 1) : ""

    TagEditorModel {
        id: tagModel
        objectName: "tagModel"

        filePath: root.filePath

        onErrorOccurred: function (message) {
            console.warn("Unable to read metadata:", message)
        }
    }

    Rectangle {
        anchors.fill: parent

        color: AppColors.background

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: AppMetrics.spacingLarge

            spacing: AppMetrics.spacingLarge

            Label {
                Layout.fillWidth: true

                text: qsTr("Tag Editor")

                color: AppColors.textPrimary
                font.pixelSize: 28
            }

            Label {
                Layout.fillWidth: true

                text: root.fileName.length > 0 ? root.fileName : qsTr("No file selected")

                color: AppColors.textSecondary
                elide: Text.ElideMiddle
            }

            ListView {
                id: tagList

                objectName: "tagList"

                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true

                spacing: 1

                model: tagModel

                delegate: Rectangle {
                    /**
                     * @brief Metadata property name.
                     *
                     * The property is provided by TagEditorModel::KeyRole.
                     */
                    required property string key

                    /**
                     * @brief Metadata property value.
                     *
                     * The property is provided by TagEditorModel::ValueRole.
                     */
                    required property string value

                    /**
                     * @brief Indicates whether this property contains lyrics.
                     *
                     * Lyrics are potentially much longer than ordinary metadata values,
                     * therefore they use a dedicated scrollable presentation.
                     */
                    readonly property bool isLyrics:
                        key.toUpperCase().startsWith("LYRICS")

                    width: tagList.width

                    /*
                     * Ordinary metadata remains compact.
                     *
                     * Lyrics receive a fixed larger area. The actual text can be
                     * arbitrarily long and is therefore displayed inside a ScrollView.
                     */
                    height: isLyrics ? 220 : 48

                    color: AppColors.surface

                    RowLayout {
                        anchors.fill: parent

                        anchors.leftMargin: AppMetrics.spacingMedium
                        anchors.rightMargin: AppMetrics.spacingMedium

                        spacing: AppMetrics.spacingLarge

                        Label {
                            Layout.preferredWidth: 180
                            Layout.alignment: Qt.AlignTop

                            /*
                             * Keep the tag name vertically aligned with the beginning
                             * of the value. This is especially important for lyrics,
                             * where the value occupies multiple lines.
                             */
                            topPadding: isLyrics ? 12 : 0

                            text: key

                            color: AppColors.textSecondary

                            elide: Text.ElideRight
                        }

                        /*
                         * Ordinary metadata values.
                         *
                         * These values are short enough to be displayed directly.
                         */
                        Label {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            visible: !isLyrics

                            text: value

                            color: AppColors.textPrimary

                            elide: Text.ElideRight
                        }

                        /*
                         * Lyrics value.
                         *
                         * ScrollView prevents a long lyrics field from increasing the
                         * delegate height or painting over subsequent metadata rows.
                         */
                        ScrollView {
                            id: lyricsScrollView

                            objectName: "lyricsScrollView"

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Layout.alignment: Qt.AlignTop

                            visible: isLyrics

                            clip: true

                            /*
                             * The vertical scrollbar is displayed only when the lyrics
                             * do not fit into the available height.
                             */
                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded

                            }

                            Text {
                                id: lyricsText

                                objectName: "lyricsText"

                                width: lyricsScrollView.availableWidth

                                text: value

                                color: AppColors.textPrimary

                                /*
                                 * Explicitly place the text at the top-left corner.
                                 */
                                verticalAlignment: Text.AlignTop
                                horizontalAlignment: Text.AlignLeft

                                wrapMode: Text.Wrap

                                /*
                                 * Let the text determine its actual content height.
                                 * ScrollView will then provide vertical scrolling.
                                 */
                                height: implicitHeight
                            }
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
            }

            /*
            Rectangle {
                Layout.fillWidth: true

                height: 1
                color: AppColors.separator
            }

            GridLayout {
                Layout.fillWidth: true

                columns: 2

                columnSpacing: AppMetrics.spacingLarge
                rowSpacing: AppMetrics.spacingMedium

                Label {
                    text: qsTr("Title")
                    color: AppColors.textSecondary
                }

                TextField {
                    objectName: "titleField"

                    Layout.fillWidth: true

                    text: root.fileName

                    placeholderText: qsTr("Title")
                }

                Label {
                    text: qsTr("Artist")
                    color: AppColors.textSecondary
                }

                TextField {
                    objectName: "artistField"

                    Layout.fillWidth: true

                    text: root.artist

                    placeholderText: qsTr("Artist")
                }

                Label {
                    text: qsTr("Album")
                    color: AppColors.textSecondary
                }

                TextField {
                    objectName: "albumField"

                    Layout.fillWidth: true

                    text: root.album

                    placeholderText: qsTr("Album")
                }

                Label {
                    text: qsTr("Genre")
                    color: AppColors.textSecondary
                }

                TextField {
                    objectName: "genreField"

                    Layout.fillWidth: true

                    text: root.genre

                    placeholderText: qsTr("Genre")
                }

                Label {
                    text: qsTr("Year")
                    color: AppColors.textSecondary
                }

                SpinBox {
                    objectName: "yearField"

                    Layout.fillWidth: true

                    from: 0
                    to: 9999

                    value: root.year
                }

                Label {
                    text: qsTr("Duration")
                    color: AppColors.textSecondary
                }

                Label {
                    Layout.fillWidth: true

                    text: root.duration

                    color: AppColors.textPrimary
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.fillWidth: true

                spacing: AppMetrics.spacingMedium

                Button {
                    objectName: "saveButton"

                    text: qsTr("Save")

                    enabled: root.fileName.length > 0
                }

                Button {
                    objectName: "resetButton"

                    text: qsTr("Reset")

                    enabled: root.fileName.length > 0
                }

                Item {
                    Layout.fillWidth: true
                }
            }

             */
        }
    }
}
