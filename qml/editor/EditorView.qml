import QtQuick

/**
 * @brief Host for the currently selected editor.
 *
 * EditorView provides the common interface between MainWindow and the
 * concrete editor implementation.
 */
Item {
    id: root

    property string fileName: ""
    property string artist: ""
    property string album: ""
    property string genre: ""
    property int year: 0
    property string duration: ""

    TagEditorView {
        anchors.fill: parent

        fileName: root.fileName
        artist: root.artist
        album: root.album
        genre: root.genre
        year: root.year
        duration: root.duration
    }
}