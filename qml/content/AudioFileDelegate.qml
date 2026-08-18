import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Delegate representing one audio file in the library.
 *
 * The delegate exposes file metadata through properties so that the
 * presentation is independent from the eventual C++ model role names.
 */
Item {
    id: root

    property string fileName: ""
    property string artist: ""
    property string album: ""
    property int year: 0
    property string duration: ""

    signal activated()

    Rectangle {
        anchors.fill: parent

        radius: AppMetrics.radiusSmall

        color: mouseArea.containsMouse
            ? AppColors.hover
            : "transparent"

        RowLayout {
            anchors.fill: parent

            anchors.leftMargin: 12
            anchors.rightMargin: 12

            spacing: 12

            AppIcon {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28

                icon: "♫"
                color: AppColors.textSecondary
            }

            ColumnLayout {
                Layout.fillWidth: true

                spacing: 1

                Label {
                    Layout.fillWidth: true

                    text: root.fileName

                    color: AppColors.textPrimary

                    elide: Text.ElideRight
                }

                Label {
                    Layout.fillWidth: true

                    text: qsTr("%1 — %2")
                        .arg(root.artist)
                        .arg(root.album)

                    color: AppColors.textSecondary

                    font.pixelSize: 12

                    elide: Text.ElideRight
                }
            }

            Label {
                Layout.preferredWidth: 48

                text: root.year

                color: AppColors.textSecondary

                horizontalAlignment: Text.AlignRight
            }

            Label {
                Layout.preferredWidth: 48

                text: root.duration

                color: AppColors.textSecondary

                horizontalAlignment: Text.AlignRight
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true

        onDoubleClicked: root.activated()
    }
}