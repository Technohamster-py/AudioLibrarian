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

        color: AppColors.editorBackground

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: AppMetrics.spacingLarge

            spacing: AppMetrics.spacingLarge

            Label {
                Layout.fillWidth: true

                text: qsTr("Tag Editor")

                color: AppColors.editorTextPrimary
                font.pixelSize: 28
            }

            Label {
                Layout.fillWidth: true

                text: root.fileName.length > 0 ? root.fileName : qsTr("No file selected")

                color: AppColors.editorTextSecondary
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
                    id: tagDelegate
                    required property string key
                    required property string value
                    required property string displayName
                    required property bool isLyrics
                    required property bool isEditable
                    required property int modelIndex

                    width: tagList.width

                    height: isLyrics ? 220 : 48

                    color: AppColors.editorPanel

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

                                color: AppColors.editorTextPrimary

                                elide: Text.ElideRight
                            }

                            /*
                             * The original TagLib key remains visible for
                             * users who need to know the actual property name.
                             */
                            Label {
                                Layout.fillWidth: true

                                text: key

                                color: AppColors.editorTextSecondary

                                font.pixelSize: 11

                                elide: Text.ElideRight
                            }
                        }

                        /**
                         * Value Column
                         */
                        TextField {
                            id: valueField
                            enabled: isEditable

                            objectName: "valueField"

                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                            visible: !isLyrics

                            color: AppColors.editorTextPrimary

                            horizontalAlignment: TextInput.AlignLeft
                            verticalAlignment: TextInput.AlignVCenter

                            Component.onCompleted: {
                                text = value
                            }

                            onTextChanged: {
                                if (activeFocus)
                                    tagModel.setValue(tagDelegate.modelIndex, text)
                                else
                                    text = value
                            }
                        }


                        /**
                         * Lyrics Delegate in Value column
                         */
                        ScrollView {
                            id: lyricsScrollView

                            objectName: "lyricsScrollView"

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignTop

                            visible: isLyrics

                            clip: true

                            TextArea {
                                id: lyricsEditor

                                objectName: "lyricsEditor"

                                width: lyricsScrollView.availableWidth

                                color: AppColors.editorTextPrimary

                                wrapMode: TextEdit.Wrap

                                horizontalAlignment: TextEdit.AlignLeft
                                verticalAlignment: TextEdit.AlignTop

                                selectByMouse: true

                                background: null

                                Component.onCompleted: {
                                    text = value
                                }

                                onTextChanged: {
                                    if (activeFocus)
                                        tagModel.setValue(tagDelegate.modelIndex, text)
                                    else
                                        text = value
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                spacing: AppMetrics.spacingMedium

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    objectName: "discardButton"

                    text: qsTr("Discard")

                    enabled: tagModel.dirty

                    onClicked: {
                        tagModel.discardChanges()
                    }
                }

                Button {
                    objectName: "saveButton"

                    text: qsTr("Save")

                    enabled: tagModel.dirty

                    onClicked: {
                        tagModel.save()
                    }
                }
            }
        }
    }
}
