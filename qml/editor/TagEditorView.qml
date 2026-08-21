import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Audio metadata editor.
 *
 * Displays metadata prepared by TagEditorModel.
 *
 * The current implementation is read-only. Metadata writing will be
 * implemented separately.
 */
Item {
    id: root

    property string filePath: ""
    property string fileName: filePath.length > 0 ? filePath.substring(filePath.lastIndexOf("/") + 1) : ""

    TagEditorModel {
        id: tagModel
        objectName: "tagModel"

        filePath: root.filePath

        onErrorOccurred: function(message) {
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
                    required property string key
                    required property string value
                    required property string displayName
                    required property bool isLyrics

                    width: tagList.width

                    height: isLyrics ? 220 : 48

                    color: AppColors.surface

                    RowLayout {
                        anchors.fill: parent

                        anchors.leftMargin: AppMetrics.spacingMedium
                        anchors.rightMargin: AppMetrics.spacingMedium

                        spacing: AppMetrics.spacingLarge

                        /**
                         * Key column
                         */
                        ColumnLayout {
                            Layout.minimumWidth: AppMetrics.editorKeyWidth
                            Layout.preferredWidth: AppMetrics.editorKeyWidth
                            Layout.maximumWidth: AppMetrics.editorKeyWidth
                            Layout.alignment: Qt.AlignVCenter

                            spacing: 2

                            Label {
                                Layout.fillWidth: true

                                Layout.topMargin: isLyrics ? 10 : 0

                                text: displayName

                                color: AppColors.textPrimary

                                elide: Text.ElideRight
                            }

                            /*
                             * The original TagLib key remains visible for
                             * users who need to know the actual property name.
                             */
                            Label {
                                Layout.fillWidth: true

                                text: key

                                color: AppColors.textSecondary

                                font.pixelSize: 11

                                elide: Text.ElideRight
                            }
                        }

                        /**
                         * Value Column
                         */
                        Label {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                            visible: !isLyrics

                            text: value

                            color: AppColors.textPrimary

                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }


                        /**
                         * Lyrics Delegate in Value column
                         */
                        ScrollView {
                            id: lyricsScrollView

                            objectName: "lyricsScrollView"

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignTop

                            visible: isLyrics

                            clip: true

                            Text {
                                id: lyricsText

                                objectName: "lyricsText"

                                width: lyricsScrollView.availableWidth

                                text: value

                                color: AppColors.textPrimary

                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignTop

                                wrapMode: Text.Wrap

                                height: implicitHeight
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

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                            }*/
                    }
                }
            }
        }
    }
}