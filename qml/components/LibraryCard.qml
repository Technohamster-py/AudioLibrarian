import QtQuick
import QtQuick.Effects
import QtQuick.Controls.FluentWinUI3

// Reusable cover card. Navigation and context-menu contents belong to the caller.
Item {
    id: root

    property url coverSource: ""
    property string title: ""
    property string subtitle: ""

    signal activated()
    signal contextMenuRequested()

    implicitWidth: 200
    implicitHeight: 160

    Rectangle {
        anchors.fill: parent
        anchors.margins: 5
        scale: cardMouse.containsMouse ? 1.03 : 1
        Behavior on scale {
            NumberAnimation {
                duration: 167
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.1, 0.9, 0.2, 1, 1, 1]
            }
        }
        color: AppColors.panel
        clip: true

        Image {
            id: coverImage
            anchors.fill: parent
            source: root.coverSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
        Rectangle {
            anchors.fill: parent
            color: "#80000000"
        }
        Item {
            id: footerBackground
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: Math.min(parent.height, subtitleLabel.implicitHeight + 24)
            clip: true
            visible: root.subtitle.length > 0

            // Keep the blurred copy aligned with the original cover, clipping
            // only its footer so the rest of the artwork stays sharp.
            MultiEffect {
                source: coverImage
                width: coverImage.width
                height: coverImage.height
                y: -footerBackground.y
                autoPaddingEnabled: false
                blurEnabled: true
                blurMax: 32
                blur: 1.0
            }
            Rectangle {
                anchors.fill: parent
                color: "#99000000"
            }
        }
        Label {
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
            text: root.title
            color: "white"
            font.bold: true
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
        }
        Label {
            id: subtitleLabel
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 12 }
            text: root.subtitle
            color: "white"
            wrapMode: Text.Wrap
        }
        MouseArea {
            id: cardMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton)
                    root.contextMenuRequested()
                else
                    root.activated()
            }
        }
    }
}
