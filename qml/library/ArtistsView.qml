import QtQuick
import QtQuick.Controls.FluentWinUI3
import QtQuick.Layouts
import AudioLibrarian

Item {
    id: root
    required property var libraryModel
    signal fileSelected(string filePath)
    property string currentFilePath: ""
    property var selectedAlbum: null
    property var artists: []
    property var selectedArtist: null
    readonly property var cards: selectedArtist ? selectedArtist.albums : artists

    function rebuild() {
        const groups = new Map()
        for (let row = 0; row < libraryModel.rowCount(); ++row) {
            const index = libraryModel.index(row, 0)
            const artist = libraryModel.data(index, AudioFileTableModel.ArtistRole) || ""
            const album = libraryModel.data(index, AudioFileTableModel.AlbumRole) || ""
            const cover = libraryModel.data(index, AudioFileTableModel.CoverRole)
            if (!groups.has(artist))
                groups.set(artist, {name: artist, cover: cover, tracks: 0, albums: [], byAlbum: new Map()})
            const entry = groups.get(artist)
            ++entry.tracks
            if (!entry.byAlbum.has(album)) {
                const item = {name: album, cover: cover, tracks: 0, files: []}
                entry.byAlbum.set(album, item)
                entry.albums.push(item)
            }
            const item = entry.byAlbum.get(album)
            ++item.tracks
            item.files.push({
                path: libraryModel.data(index, AudioFileTableModel.FilePathRole),
                title: libraryModel.data(index, AudioFileTableModel.TitleRole) || libraryModel.data(index, AudioFileTableModel.FileNameRole),
                artist: artist, album: album,
                year: libraryModel.data(index, AudioFileTableModel.YearRole),
                duration: libraryModel.data(index, AudioFileTableModel.DurationRole)
            })
            if (!item.cover.toString())
                item.cover = cover
        }
        const sorted = Array.from(groups.values())
        const compare = (a, b) => a.name.localeCompare(b.name)
        sorted.sort(compare)
        for (const artist of sorted) {
            artist.cover = artist.albums.length ? artist.albums[0].cover : ""
            artist.albums.sort(compare)
        }
        const previousAlbum = selectedAlbum
        const previous = selectedArtist
        artists = sorted
        if (previous)
            selectedArtist = sorted.find(a => a.name === previous.name) || null
        if (previousAlbum)
            selectedAlbum = selectedArtist ? selectedArtist.albums.find(a => a.name === previousAlbum.name) || null : null
    }

    Component.onCompleted: rebuild()
    Connections {
        target: root.libraryModel
        function onModelReset() { root.rebuild() }
        function onDataChanged() { root.rebuild() }
        function onRowsInserted() { root.rebuild() }
        function onRowsRemoved() { root.rebuild() }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppMetrics.pagePadding
        RowLayout {
            Button {
                visible: root.selectedArtist !== null
                text: qsTr("Back")
                onClicked: {
                    if (root.selectedAlbum) root.selectedAlbum = null
                    else root.selectedArtist = null
                }
            }
            Label {
                Layout.fillWidth: true
                text: root.selectedAlbum ? (root.selectedAlbum.name || qsTr("Unknown album")) : root.selectedArtist ? (root.selectedArtist.name || qsTr("Unknown artist")) : qsTr("Artists")
                elide: Text.ElideRight
                font.bold: true
            }
        }
        GridView {
            id: grid
            visible: root.selectedAlbum === null
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            cellWidth: width / Math.max(1, Math.floor(width / 200))
            cellHeight: 160
            model: root.cards
            ScrollBar.vertical: ScrollBar {}
            delegate: Item {
                required property var modelData
                width: grid.cellWidth
                height: grid.cellHeight
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
                        anchors.fill: parent
                        source: modelData.cover
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                    Rectangle { anchors.fill: parent; color: "#80000000" }
                    Label {
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                        text: modelData.name || (root.selectedArtist ? qsTr("Unknown album") : qsTr("Unknown artist"))
                        color: "white"
                        font.bold: true
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                    Label {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 12 }
                        text: root.selectedArtist
                              ? qsTr("Tracks: %1").arg(modelData.tracks)
                              : qsTr("Albums: %1 · Tracks: %2").arg(modelData.albums.length).arg(modelData.tracks)
                        color: "white"
                        wrapMode: Text.Wrap
                    }
                    MouseArea {
                        id: cardMouse
                        hoverEnabled: true
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: function(mouse) {
                            if (root.selectedArtist) {
                                if (mouse.button === Qt.LeftButton) root.selectedAlbum = modelData
                                return
                            }
                            if (mouse.button === Qt.RightButton)
                                menu.popup()
                            else
                                root.selectedArtist = modelData
                        }
                    }
                    Menu {
                        id: menu
                        MenuItem {
                            text: qsTr("Change artist name")
                            enabled: false
                        }
                    }
                }
            }
            Label {
                anchors.centerIn: parent
                visible: grid.count === 0
                text: root.libraryModel.loading ? qsTr("Loading…") : qsTr("No artists in the library")
            }
        }
        ListView {
            id: tracks
            visible: root.selectedAlbum !== null
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.selectedAlbum ? root.selectedAlbum.files : []
            ScrollBar.vertical: ScrollBar {}
            delegate: AudioFileDelegate {
                required property var modelData
                width: tracks.width
                height: 64
                fileName: modelData.title
                artist: modelData.artist
                album: modelData.album
                year: Number(modelData.year) || 0
                duration: modelData.duration
                selected: root.currentFilePath === modelData.path
                onActivated: root.fileSelected(modelData.path)
            }
        }

    }
}
