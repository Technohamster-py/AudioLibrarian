import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Editable metadata field used by the batch metadata editor.
 */
Rectangle {
    id: root

    property string label: ""
    property string tagName: ""
    property bool checked: false
    property string value: ""
    property bool multiline: false

    signal valueEdited(string value)

    Layout.fillWidth: true
    Layout.preferredHeight: multiline ? 140 : 52

    color: AppColors.settingsBackground

    border.width: 1
    border.color: AppColors.settingsSeparator

    RowLayout {
        anchors.fill: parent

        anchors.leftMargin: AppMetrics.spacingMedium
        anchors.rightMargin: AppMetrics.spacingMedium

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

                color: AppColors.settingsTextPrimary

                elide: Text.ElideRight
            }

            Label {
                Layout.fillWidth: true

                text: root.tagName

                color: AppColors.settingsTextSecondary

                font.pixelSize: 11

                elide: Text.ElideRight
            }
        }

        TextField {
            id: valueField
            objectName: "valueField"

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            visible: !root.multiline

            enabled: root.checked

            text: root.value

            color: AppColors.settingsTextPrimary

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

                color: AppColors.settingsTextPrimary

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
                root.valueEdited("")
            }
        }
    }
}