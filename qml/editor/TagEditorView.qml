import QtQuick
import QtQuick.Controls.FluentWinUI3
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
    signal metadataSaved(string filePath)
    function reload() { tagModel.discardChanges() }

    property string filePath: ""
    property string fileName: filePath.length > 0 ? filePath.substring(filePath.lastIndexOf("/") + 1) : ""

    TagEditorModel {
        onMetadataSaved: function(filePath) { root.metadataSaved(filePath) }
        id: tagModel
        objectName: "tagModel"

        filePath: root.filePath

        onErrorOccurred: function (message) {
            console.warn("Unable to read metadata:", message);
        }
    }

    Rectangle {
        anchors.fill: parent

        color: AppColors.editorBackground

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: AppMetrics.pagePadding

            spacing: AppMetrics.spacingLarge

            Label {
                Layout.fillWidth: true

                text: qsTr("Tag Editor")

                color: enabled ? AppColors.textPrimary : AppColors.textDisabled
                font.pixelSize: AppMetrics.fontSizeTitle
                font.weight: Font.DemiBold
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

                spacing: AppMetrics.spacingSmall
                ScrollBar.vertical: ScrollBar {}

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

                    height: isLyrics ? 240 : isMultiValue ? Math.max(88, multiValueEditor.implicitHeight + 24) : 64

                    color: AppColors.editorPanel
                    radius: AppMetrics.radiusSmall
                    border.color: AppColors.separator

                    RowLayout {
                        anchors.fill: parent

                        anchors.margins: 12

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

                                color: enabled ? AppColors.textPrimary : AppColors.textDisabled

                                elide: Text.ElideRight
                            }

                            Label {
                                Layout.fillWidth: true

                                text: key

                                color: AppColors.editorTextSecondary

                                font.pixelSize: AppMetrics.fontSizeSmall

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

                            onValuesEdited: function (newValues) {
                                tagModel.setValues(tagDelegate.modelIndex, newValues);
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

                            color: enabled ? AppColors.textPrimary : AppColors.textDisabled

                            horizontalAlignment: TextInput.AlignLeft
                            verticalAlignment: TextInput.AlignVCenter

                            Component.onCompleted: {
                                text = value;
                            }

                            onTextChanged: {
                                if (activeFocus)
                                    tagModel.setValue(tagDelegate.modelIndex, text);
                                else
                                    text = value;
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

                                color: enabled ? AppColors.textPrimary : AppColors.textDisabled

                                wrapMode: TextEdit.Wrap

                                horizontalAlignment: TextEdit.AlignLeft
                                verticalAlignment: TextEdit.AlignTop

                                selectByMouse: true

                                Component.onCompleted: {
                                    text = value;
                                }

                                onTextChanged: {
                                    if (activeFocus)
                                        tagModel.setValue(tagDelegate.modelIndex, text);
                                    else
                                        text = value;
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
                        tagModel.discardChanges();
                    }
                }

                Button {
                    objectName: "saveButton"
                    highlighted: true

                    text: qsTr("Save")

                    enabled: tagModel.dirty

                    onClicked: {
                        tagModel.save();
                    }
                }
            }
        }
    }
}
