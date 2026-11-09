import QtQuick
import QtQuick.Controls.FluentWinUI3
import QtQuick.Layouts

/**
 * @brief Editable metadata field used by the batch metadata editor.
 *
 * Supports scalar values, multiple values and multiline text.
 */
Rectangle {
    id: root

    property string label: ""
    property string tagName: ""
    property bool checked: false
    property string value: ""
    property var values: []
    property bool multiline: false
    property bool multiValue: false

    signal valueEdited(string value)
    signal valuesEdited(var values)

    Layout.fillWidth: true
    Layout.preferredHeight: root.multiline ? 160 : root.multiValue ? Math.max(112, multiValueEditor.implicitHeight + 24) : 64

    color: AppColors.panel
    radius: AppMetrics.radiusSmall

    border.width: 1
    border.color: AppColors.settingsSeparator

    RowLayout {
        anchors.fill: parent

        anchors.margins: 12

        spacing: AppMetrics.spacingMedium

        CheckBox {
            id: enableCheckBox
            objectName: "enableCheckBox"

            checked: root.checked

            onToggled: root.checked = checked
        }

        ColumnLayout {
            Layout.minimumWidth: 150
            Layout.preferredWidth: 180
            Layout.maximumWidth: 220

            spacing: 1

            Label {
                Layout.fillWidth: true

                text: root.label

                color: enabled ? AppColors.textPrimary : AppColors.textDisabled

                elide: Text.ElideRight
            }

            Label {
                Layout.fillWidth: true

                text: root.tagName

                color: AppColors.settingsTextSecondary

                font.pixelSize: AppMetrics.fontSizeSmall

                elide: Text.ElideRight
            }
        }

        MultiValueEditor {
            id: multiValueEditor
            objectName: "multiValueEditor"

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            visible: root.multiValue
            enabled: root.checked

            values: root.values

            onValuesEdited: function (newValues) {
                root.valuesEdited(newValues);
            }
        }

        TextField {
            id: valueField
            objectName: "valueField"

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            visible: !root.multiline && !root.multiValue

            enabled: root.checked

            text: root.value

            color: enabled ? AppColors.textPrimary : AppColors.textDisabled

            horizontalAlignment: TextInput.AlignLeft

            onTextEdited: root.valueEdited(text)
        }

        ScrollView {
            id: multilineScrollView
            objectName: "multilineScrollView"

            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: root.multiline

            enabled: root.checked

            clip: true

            TextArea {
                id: multilineValueField
                objectName: "multilineValueField"

                width: multilineScrollView.availableWidth

                text: root.value

                color: enabled ? AppColors.textPrimary : AppColors.textDisabled

                wrapMode: TextEdit.Wrap

                horizontalAlignment: TextEdit.AlignLeft
                verticalAlignment: TextEdit.AlignTop

                selectByMouse: true

                onTextEdited: root.valueEdited(text)
            }
        }

        Button {
            id: clearButton
            objectName: "clearButton"

            text: qsTr("Clear")

            enabled: root.checked

            onClicked: {
                if (root.multiValue)
                    root.valuesEdited([]);
                else
                    root.valueEdited("");
            }
        }
    }
}
