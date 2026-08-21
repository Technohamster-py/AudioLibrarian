import QtQuick

/**
 * @brief Host for the currently selected editor.
 *
 * EditorView provides the common interface between MainWindow and the
 * concrete editor implementation.
 */
Item {
    id: root

    property string filePath: ""

    TagEditorView {
        anchors.fill: parent

       filePath: root.filePath
    }
}