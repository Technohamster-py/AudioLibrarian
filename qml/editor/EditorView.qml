import QtQuick

/**
 * @brief Host for the currently selected editor.
 *
 * EditorView provides the common interface between MainWindow and the
 * concrete editor implementation.
 */
Item {
    id: root
    signal metadataSaved(string filePath)

    function reload() { tagEditor.reload() }

    property string filePath: ""

    TagEditorView {
        id: tagEditor
        onMetadataSaved: function(filePath) { root.metadataSaved(filePath) }
        anchors.fill: parent

       filePath: root.filePath
    }
}