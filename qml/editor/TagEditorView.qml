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

    /**
     * @brief Returns whether a metadata property supports multiple values.
     *
     * Lyrics and scalar properties are intentionally excluded.
     */
    function isMultiValueTag(key, lyrics) {
        if (lyrics)
            return false

        const normalized = key.toUpperCase()

        return normalized !== "TITLE" &&
            normalized !== "ALBUM" &&
            normalized !== "DISCNUMBER" &&
            normalized !== "TRACKNUMBER" &&
            normalized !== "DATE" &&
            normalized !== "LENGTH"
    }

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
                    required property bool isEditable
                    required property int modelIndex

                    readonly property bool multiValue: root.isMultiValueTag(key, isLyrics)

                    width: tagList.width

                    height: isLyrics ? 220 : multiValue ? Math.max(72, valuesEditor.implicitHeight + 20) : 48

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
                        ColumnLayout {
                            id: valuesEditor

                            objectName: "valuesEditor"

                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            visible: multiValue
                            enabled: isEditable

                            spacing: AppMetrics.spacingSmall

                            property int editingIndex: -1

                            function commitInput() {
                                const text = inputField.text.trim()

                                if (text.length === 0) {
                                    editingIndex = -1
                                    inputField.clear()
                                    return
                                }

                                const enteredValues = text
                                    .split(";")
                                    .map(function(item) {
                                    return item.trim()
                                })
                                    .filter(function(item) {
                                    return item.length > 0
                                })

                                if (enteredValues.length === 0) {
                                    editingIndex = -1
                                    inputField.clear()
                                    return
                                }

                                const newValues = values.slice()

                                if (editingIndex >= 0 && editingIndex < newValues.length) {
                                    newValues.splice(editingIndex, 1, enteredValues[0])

                                    for (let i = enteredValues.length - 1; i >= 1; --i)
                                        newValues.splice(editingIndex + 1, 0, enteredValues[i])
                                } else {
                                    for (const enteredValue of enteredValues)
                                        newValues.push(enteredValue)
                                }

                                tagModel.setValues(tagDelegate.modelIndex, newValues)

                                editingIndex = -1
                                inputField.clear()
                            }

                            function startEditing(index) {
                                if (index < 0 || index >= values.length)
                                    return

                                editingIndex = index
                                inputField.text = values[index]
                                inputField.selectAll()
                                inputField.forceActiveFocus()
                            }

                            function removeValue(index) {
                                if (index < 0 || index >= values.length)
                                    return

                                const newValues = values.slice()
                                newValues.splice(index, 1)

                                if (editingIndex === index)
                                    editingIndex = -1
                                else if (editingIndex > index)
                                    --editingIndex

                                tagModel.setValues(tagDelegate.modelIndex, newValues)
                            }

                            function cancelEditing() {
                                editingIndex = -1
                                inputField.clear()
                            }

                            Flow {
                                id: chipsFlow

                                objectName: "chipsFlow"

                                Layout.fillWidth: true
                                Layout.preferredHeight: implicitHeight

                                spacing: AppMetrics.spacingSmall

                                Repeater {
                                    model: values

                                    delegate: Rectangle {
                                        id: chip

                                        required property string modelData
                                        required property int index

                                        height: 32
                                        width: chipLabel.implicitWidth + removeButton.width + 24

                                        radius: height / 2

                                        color: AppColors.editorBackground

                                        border.color: AppColors.editorTextSecondary

                                        Label {
                                            id: chipLabel

                                            anchors.left: parent.left
                                            anchors.leftMargin: 12
                                            anchors.verticalCenter: parent.verticalCenter

                                            text: modelData

                                            color: AppColors.editorTextPrimary

                                            elide: Text.ElideRight
                                        }

                                        ToolButton {
                                            id: removeButton

                                            anchors.right: parent.right
                                            anchors.verticalCenter: parent.verticalCenter

                                            width: 28
                                            height: 28

                                            // text: "×"

                                            contentItem: Image {
                                                anchors.fill: parent
                                                anchors.margins: 5
                                                source: AppAssets.cancel

                                                sourceSize.width: width
                                                sourceSize.height: height

                                                fillMode: Image.PreserveAspectFit

                                                asynchronous: true
                                                smooth: true
                                                mipmap: true
                                            }

                                            font.pixelSize: 18

                                            onClicked: {
                                                valuesEditor.removeValue(index)
                                            }
                                        }

                                        MouseArea {
                                            anchors.left: parent.left
                                            anchors.right: removeButton.left
                                            anchors.top: parent.top
                                            anchors.bottom: parent.bottom

                                            acceptedButtons: Qt.LeftButton

                                            onDoubleClicked: {
                                                valuesEditor.startEditing(index)
                                            }
                                        }
                                    }
                                }
                            }

                            TextField {
                                id: inputField

                                objectName: "multiValueInput"

                                Layout.fillWidth: true

                                placeholderText: valuesEditor.editingIndex >= 0 ? qsTr("Edit value...") : qsTr("Add value...")

                                color: AppColors.editorTextPrimary

                                horizontalAlignment: TextInput.AlignLeft
                                verticalAlignment: TextInput.AlignVCenter

                                background: Rectangle {
                                    color: AppColors.inputBackground
                                    radius: AppMetrics.editFieldRadius

                                    border.width: inputField.activeFocus ? AppMetrics.editFieldBorderBold : AppMetrics.editFieldBorder
                                    border.color: inputField.activeFocus ? AppColors.inputBorderActive : AppColors.inputBorder
                                }

                                onTextChanged: {
                                    if (text.indexOf(";") < 0)
                                        return

                                    valuesEditor.commitInput()
                                }

                                onActiveFocusChanged: {
                                    if (!activeFocus && text.trim().length > 0)
                                        valuesEditor.commitInput()
                                }

                                Keys.onReturnPressed: {
                                    valuesEditor.commitInput()
                                }

                                Keys.onEscapePressed: {
                                    if (valuesEditor.editingIndex >= 0)
                                        valuesEditor.cancelEditing()
                                    else
                                        clear()
                                }
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

                            visible: !isLyrics && !multiValue

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