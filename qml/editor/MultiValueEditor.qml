import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Editor for metadata properties containing multiple values.
 *
 * Displays values as removable chips and provides one input field for both
 * adding new values and editing existing chips.
 */
Item {
    id: root

    property var values: []
    property string placeholderText: qsTr("Add value...")
    property bool editable: true

    /**
     * @brief Emitted when the complete value list has been changed.
     *
     * @param newValues Updated list of values.
     */
    signal valuesEdited(var newValues)

    implicitHeight: editorColumn.implicitHeight

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

        const newValues = root.values.slice()

        if (editingIndex >= 0 && editingIndex < newValues.length) {
            newValues.splice(editingIndex, 1, enteredValues[0])

            for (let i = enteredValues.length - 1; i >= 1; --i)
                newValues.splice(editingIndex + 1, 0, enteredValues[i])
        } else {
            for (const enteredValue of enteredValues)
                newValues.push(enteredValue)
        }

        editingIndex = -1
        inputField.clear()

        root.valuesEdited(newValues)
    }

    function startEditing(index) {
        if (index < 0 || index >= root.values.length)
            return

        editingIndex = index
        inputField.text = root.values[index]
        inputField.selectAll()
        inputField.forceActiveFocus()
    }

    function removeValue(index) {
        if (index < 0 || index >= root.values.length)
            return

        const newValues = root.values.slice()

        newValues.splice(index, 1)

        if (editingIndex === index)
            editingIndex = -1
        else if (editingIndex > index)
            --editingIndex

        root.valuesEdited(newValues)
    }

    function cancelEditing() {
        editingIndex = -1
        inputField.clear()
    }

    property int editingIndex: -1

    ColumnLayout {
        id: editorColumn

        anchors.left: parent.left
        anchors.right: parent.right

        spacing: AppMetrics.spacingSmall

        Flow {
            id: chipsFlow

            objectName: "chipsFlow"

            Layout.fillWidth: true

            spacing: AppMetrics.spacingSmall

            Repeater {
                model: root.values

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

                        enabled: root.editable

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

                        onClicked: {
                            root.removeValue(index)
                        }
                    }

                    MouseArea {
                        anchors.left: parent.left
                        anchors.right: removeButton.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        enabled: root.editable
                        acceptedButtons: Qt.LeftButton

                        onDoubleClicked: {
                            root.startEditing(index)
                        }
                    }
                }
            }
        }

        TextField {
            id: inputField

            objectName: "multiValueInput"

            Layout.fillWidth: true

            enabled: root.editable

            placeholderText: root.editingIndex >= 0 ? qsTr("Edit value...") : root.placeholderText

            color: AppColors.editorTextPrimary

            horizontalAlignment: TextInput.AlignLeft
            verticalAlignment: TextInput.AlignVCenter

            background: Rectangle {
                color: inputField.enabled ? AppColors.inputBackground : AppColors.editorPanelDisabled
                radius: AppMetrics.editFieldRadius
                border.width: inputField.activeFocus ? AppMetrics.editFieldBorderBold : AppMetrics.editFieldBorder
                border.color: inputField.activeFocus ? AppColors.inputBorderActive : AppColors.inputBorder
            }

            onTextChanged: {
                if (text.indexOf(";") >= 0)
                    root.commitInput()
            }

            onActiveFocusChanged: {
                if (!activeFocus && text.trim().length > 0)
                    root.commitInput()
            }

            Keys.onReturnPressed: {
                root.commitInput()
            }

            Keys.onEscapePressed: {
                if (root.editingIndex >= 0)
                    root.cancelEditing()
                else
                    clear()
            }
        }
    }
}