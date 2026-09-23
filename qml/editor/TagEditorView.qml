import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Audio metadata editor.
 *
 * Displays metadata prepared by TagEditorModel.
 *
 * Multi-value tags are represented as chips. A single TextField is used both
 * for adding new values and editing an existing chip.
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
                    required property var values
                    required property string value
                    required property string displayName
                    required property bool isLyrics
                    required property bool isMultiValue
                    required property bool isEditable
                    required property int modelIndex
                    
                    width: tagList.width

                    height: isLyrics ? 220 : isMultiValue ? Math.max(72, multiValueEditor.implicitHeight + 20) : 48

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

                            Label {
                                Layout.fillWidth: true

                                text: key

                                color: AppColors.editorTextSecondary

                                font.pixelSize: 11

                                elide: Text.ElideRight
                            }
                        }

                        /**
                         * Multi-value editor.
                         *
                         * Chips are always placed above the input field.
                         */
                        MultiValueEditor {
                            id: multiValueEditor

                            objectName: "multiValueEditor"

                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            visible: isMultiValue
                            editable: isEditable

                            values: tagDelegate.values

                            onValuesEdited: function(newValues) {
                                tagModel.setValues(tagDelegate.modelIndex, newValues)
                            }
                        }

                        /**
                         * Single-value editor.
                         */
                        TextField {
                            id: valueField

                            objectName: "valueField"

                            enabled: isEditable

                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                            visible: !isLyrics && !isMultiValue

                            color: AppColors.editorTextPrimary

                            horizontalAlignment: TextInput.AlignLeft
                            verticalAlignment: TextInput.AlignVCenter

                            Component.onCompleted: {
                                text = value
                            }

                            background: Rectangle {
                                color: valueField.enabled ? AppColors.inputBackground : AppColors.editorPanel
                                radius: AppMetrics.editFieldRadius

                                border.width: valueField.activeFocus ? AppMetrics.editFieldBorderBold : AppMetrics.editFieldBorder
                                border.color: valueField.activeFocus ? AppColors.inputBorderActive : AppColors.inputBorder
                            }

                            onTextChanged: {
                                if (activeFocus)
                                    tagModel.setValue(tagDelegate.modelIndex, text)
                                else
                                    text = value
                            }
                        }

                        /**
                         * Lyrics editor.
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

                                background: Rectangle {
                                    color: AppColors.inputBackground
                                    radius: AppMetrics.editFieldRadius

                                    border.width: lyricsEditor.activeFocus ? AppMetrics.editFieldBorderBold : AppMetrics.editFieldBorder
                                    border.color: lyricsEditor.activeFocus ? AppColors.inputBorderActive : AppColors.inputBorder
                                }

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