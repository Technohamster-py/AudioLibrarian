import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Audio metadata editor.
 *
 * Displays metadata prepared by TagEditorModel.
 *
 * Single-value tags are edited using a regular TextField.
 * Multi-value tags are displayed as editable chips with a trailing
 * TextField used to add new values.
 */
Item {
    id: root

    property string filePath: ""
    property string fileName: filePath.length > 0 ? filePath.substring(filePath.lastIndexOf("/") + 1) : ""

    /**
     * @brief Determines whether a metadata property supports multiple values.
     *
     * Lyrics are handled separately by the TextArea and are therefore
     * considered single-value here.
     *
     * @param key Original TagLib metadata key.
     * @return true if the property supports multiple values.
     */
    function isMultiValueTag(key) {
        const normalized = key.toUpperCase()

        if (normalized === "TITLE" ||
            normalized === "ALBUM" ||
            normalized === "DISCNUMBER" ||
            normalized === "TRACKNUMBER" ||
            normalized === "DATE" ||
            normalized === "LENGTH" ||
            normalized === "LYRICS" ||
            normalized.startsWith("LYRICS:") ||
            normalized === "UNSYNCEDLYRICS" ||
            normalized === "UNSYNCED_LYRICS" ||
            normalized === "USLT")
            return false

        return true
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
                         * @brief Metadata key column.
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
                         * @brief Single-value metadata editor.
                         *
                         * Duration and lyrics are excluded because they use
                         * their own presentation/editing logic.
                         */
                        TextField {
                            id: valueField

                            objectName: "valueField"

                            enabled: isEditable

                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                            visible: !isLyrics && !root.isMultiValueTag(key)

                            color: AppColors.editorTextPrimary

                            horizontalAlignment: TextInput.AlignLeft
                            verticalAlignment: TextInput.AlignVCenter

                            text: {
                                if (key.toUpperCase() === "LENGTH")
                                    return value

                                return values.length > 0 ? values[0] : ""
                            }

                            onTextChanged: {
                                if (activeFocus)
                                    tagModel.setValue(tagDelegate.modelIndex, text)
                            }
                        }

                        /**
                         * @brief Multi-value metadata editor.
                         *
                         * Existing values are displayed as chips.
                         * The trailing TextField is used to create new values.
                         *
                         * A semicolon commits one or more values.
                         * Losing focus commits the current input.
                         */
                        Flow {
                            id: valuesEditor

                            objectName: "valuesEditor"

                            visible: !isLyrics && root.isMultiValueTag(key)
                            enabled: isEditable

                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            spacing: AppMetrics.spacingSmall

                            property int editingIndex: -1
                            property bool cancelEditing: false

                            /**
                             * @brief Commits the current input as one or more values.
                             *
                             * Semicolons are treated as value separators.
                             */
                            function commitInput() {
                                const input = inputField.text

                                if (input.length === 0)
                                    return

                                const parts = input.split(";")
                                const newValues = []

                                for (const part of parts) {
                                    const value = part.trim()

                                    if (value.length > 0)
                                        newValues.push(value)
                                }

                                if (newValues.length === 0)
                                    return

                                const updatedValues = values.slice()

                                for (const newValue of newValues)
                                    updatedValues.push(newValue)

                                tagModel.setValues(
                                    tagDelegate.modelIndex,
                                    updatedValues
                                )

                                inputField.clear()
                            }

                            /**
                             * @brief Starts editing an existing chip.
                             *
                             * @param index Index of the value being edited.
                             */
                            function editValue(index) {
                                cancelEditing = false
                                editingIndex = index
                            }

                            /**
                             * @brief Commits an edited chip.
                             *
                             * @param index Index of the edited value.
                             * @param newValue New value.
                             */
                            function commitEditedValue(index, newValue) {
                                const updatedValues = values.slice()
                                const normalizedValue = newValue.trim()

                                if (normalizedValue.length === 0)
                                    updatedValues.splice(index, 1)
                                else
                                    updatedValues[index] = normalizedValue

                                tagModel.setValues(
                                    tagDelegate.modelIndex,
                                    updatedValues
                                )

                                editingIndex = -1
                            }

                            /**
                             * @brief Cancels editing without changing the model.
                             */
                            function cancelEdit() {
                                cancelEditing = true
                                editingIndex = -1
                            }

                            Repeater {
                                model: values

                                delegate: Rectangle {
                                    id: valueChip

                                    required property string modelData
                                    required property int index

                                    height: 32

                                    width: editingIndex === index ? editField.width : chipText.implicitWidth + 24

                                    radius: height / 2

                                    color: AppColors.panelElevated

                                    /**
                                     * @brief Displayed chip contents.
                                     */
                                    Text {
                                        id: chipText

                                        anchors.centerIn: parent

                                        visible: valuesEditor.editingIndex !== index

                                        text: modelData

                                        color: AppColors.editorTextPrimary

                                        elide: Text.ElideRight
                                    }

                                    /**
                                     * @brief Inline editor for an existing chip.
                                     */
                                    TextField {
                                        id: editField

                                        objectName: "chipEditField"

                                        visible: valuesEditor.editingIndex === index

                                        width: Math.max(100, implicitWidth + AppMetrics.spacingMedium)

                                        anchors.verticalCenter: parent.verticalCenter

                                        color: AppColors.editorTextPrimary

                                        text: modelData

                                        selectByMouse: true

                                        Component.onCompleted: {
                                            if (valuesEditor.editingIndex === index) {
                                                forceActiveFocus()
                                                selectAll()
                                            }
                                        }

                                        onActiveFocusChanged: {
                                            if (!activeFocus && valuesEditor.editingIndex === index) {
                                                if (valuesEditor.cancelEditing) {
                                                    valuesEditor.cancelEditing = false
                                                    return
                                                }

                                                valuesEditor.commitEditedValue(index, text)
                                            }
                                        }

                                        Keys.onReturnPressed: {
                                            valuesEditor.commitEditedValue(index, text)
                                        }

                                        Keys.onEscapePressed: {
                                            valuesEditor.cancelEdit()
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent

                                        visible: valuesEditor.editingIndex !== index

                                        acceptedButtons: Qt.LeftButton

                                        onDoubleClicked: {
                                            valuesEditor.editValue(index)
                                        }
                                    }
                                }
                            }

                            /**
                             * @brief Input field used to append new values.
                             */
                            TextField {
                                id: inputField

                                objectName: "multiValueInput"

                                width: Math.max(100, implicitWidth + AppMetrics.spacingMedium)

                                height: 32

                                placeholderText: qsTr("Add value...")

                                color: AppColors.editorTextPrimary

                                onActiveFocusChanged: {
                                    if (!activeFocus)
                                        valuesEditor.commitInput()
                                }

                                Keys.onReturnPressed: {
                                    valuesEditor.commitInput()
                                }

                                onTextChanged: {
                                    if (text.indexOf(";") === -1)
                                        return

                                    valuesEditor.commitInput()
                                }
                            }
                        }

                        /**
                         * @brief Lyrics editor.
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

                                text: values.length > 0 ? values[0] : ""

                                onTextChanged: {
                                    if (activeFocus)
                                        tagModel.setValue(tagDelegate.modelIndex, text)
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