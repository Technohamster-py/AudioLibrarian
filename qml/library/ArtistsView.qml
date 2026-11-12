import QtQuick
import QtQuick.Controls.FluentWinUI3
import QtQuick.Layouts
import AudioLibrarian

Item {
    id: root
    signal filesUpdated(var filePaths)
    required property var libraryModel
    signal fileSelected(string filePath)
    property string currentFilePath: ""
    property var selectedAlbum: null
    property bool albumsOnly: false
    property var allAlbums: []
    property var artists: []
    property var selectedArtist: null
    readonly property bool showingAlbums: albumsOnly || selectedArtist !== null
    readonly property var cards: albumsOnly ? allAlbums : selectedArtist ? selectedArtist.albums : artists

    readonly property string alphabet: "#ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
    readonly property var availableLetters: {
        const result = new Set()
        for (const card of cards)
            result.add(sectionLetter(card.name))
        return result
    }

    function sectionLetter(name) {
        const first = Array.from(name.trim())[0] || ""
        const letter = first.toUpperCase()
        return letter.length === 1 && alphabet.indexOf(letter) > 0 ? letter : "#"
    }

    function jumpToLetter(letter) {
        const rows = grid.model
        for (let i = 0; i < rows.length; ++i) {
            if (rows[i].letter === letter) {
                grid.positionViewAtIndex(i, ListView.Beginning)
                break
            }
        }
        letterNavigator.close()
    }

    Popup {
        id: letterNavigator
        anchors.centerIn: parent
        width: Math.min(root.width, 420)
        height: Math.min(root.height, letterFlow.implicitHeight + padding * 2)
        padding: 12
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            color: AppColors.panel
            radius: AppMetrics.radiusSmall
            border.color: AppColors.separator
        }
        contentItem: Flickable {
            clip: true
            contentHeight: letterFlow.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {}
            Column {
                id: letterFlow
                width: parent.width
                spacing: 8
                Repeater {
                    model: ["#", "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"]
                    delegate: Flow {
                        id: alphabetFlow
                        required property string modelData
                        width: letterFlow.width
                        Repeater {
                            model: alphabetFlow.modelData.split("")
                            delegate: ItemDelegate {
                                required property string modelData
                                readonly property bool available: root.availableLetters.has(modelData)
                                width: alphabetFlow.width / Math.max(1, Math.floor(alphabetFlow.width / 44))
                                height: 44
                                enabled: available
                                text: modelData
                                contentItem: Label {
                                    text: parent.text
                                    color: available ? AppColors.textSecondary : AppColors.textDisabled
                                    font.pixelSize: 20
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: root.jumpToLetter(modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    // Each section starts a fresh row, even if the preceding row is not full.
    function cardRows(items, columns) {
        const groups = new Map()
        for (const item of items) {
            const letter = sectionLetter(item.name)
            if (!groups.has(letter))
                groups.set(letter, [])
            groups.get(letter).push(item)
        }
        const rows = []
        const letters = Array.from(groups.keys()).sort((a, b) => a.localeCompare(b))
        for (const letter of letters) {
            rows.push({letter: letter, cards: []})
            const entries = groups.get(letter)
            for (let i = 0; i < entries.length; i += columns)
                rows.push({letter: "", cards: entries.slice(i, i + columns)})
        }
        return rows
    }

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
                const item = {name: album, artist: artist, cover: cover, tracks: 0, files: []}
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
        const albums = []
        for (const artist of sorted)
            albums.push(...artist.albums)
        albums.sort((a, b) => compare(a, b) || a.artist.localeCompare(b.artist))
        allAlbums = albums
        if (previous)
            selectedArtist = sorted.find(a => a.name === previous.name) || null
        if (previousAlbum) {
            const candidates = albumsOnly ? allAlbums : selectedArtist ? selectedArtist.albums : []
            selectedAlbum = candidates.find(a => a.name === previousAlbum.name && a.artist === previousAlbum.artist) || null
        }
    }

    Component.onCompleted: rebuild()
    Connections {
        target: root.libraryModel
        function onModelReset() { root.rebuild() }
        function onDataChanged() { root.rebuild() }
        function onRowsInserted() { root.rebuild() }
        function onRowsRemoved() { root.rebuild() }
    }

    MetadataEditorController {
        onFilesUpdated: function(filePaths) { root.filesUpdated(filePaths) }
        id: albumEditor
        onAlbumRenameFinished: root.libraryModel.reload()
        onArtistRenameFinished: root.libraryModel.reload()
    }

    Dialog {
        id: albumNameDialog
        anchors.centerIn: parent
        width: Math.min(root.width, 360)
        title: editingArtist ? qsTr("Change artist name") : qsTr("Change album name")
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        property var filePaths: []
        property bool editingArtist: false
        property string originalName: ""
        property string artistName: ""
        property string pendingName: ""

        function applyRename() {
            if (editingArtist)
                albumEditor.renameArtist(filePaths, pendingName)
            else
                albumEditor.renameAlbum(filePaths, pendingName)
        }

        onAccepted: {
            pendingName = albumNameField.text
            if (!pendingName.trim().length || pendingName === originalName)
                return
            const exists = editingArtist
                ? root.artists.some(artist => artist.name === pendingName)
                : root.allAlbums.some(album => album.artist === artistName && album.name === pendingName)
            if (exists)
                mergeConfirmation.open()
            else
                applyRename()
        }
        contentItem: TextField {
            id: albumNameField
            selectByMouse: true
            onAccepted: albumNameDialog.accept()
        }
        onOpened: {
            const okButton = standardButton(Dialog.Ok)
            okButton.highlighted = true
            okButton.palette.accent = AppColors.accentPrimary
            okButton.palette.highlight = AppColors.accentPrimary
            albumNameField.forceActiveFocus()
            albumNameField.selectAll()
        }
    }

    Dialog {
        id: mergeConfirmation
        anchors.centerIn: parent
        width: Math.min(root.width, 420)
        title: qsTr("Confirm merge")
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        contentItem: Label {
            text: albumNameDialog.editingArtist
                ? qsTr('Исполнитель "%1" Уже существует. Объединить с этим исполнителем? Альбомы с одинаковыми названиями так же будут объединены.').arg(albumNameDialog.pendingName)
                : qsTr('Альбом "%1" Уже существует у этого исполнителя. Объединить альбомы?').arg(albumNameDialog.pendingName)
            wrapMode: Text.WordWrap
        }
        onAccepted: albumNameDialog.applyRename()
        onOpened: standardButton(Dialog.No).forceActiveFocus()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppMetrics.pagePadding
        RowLayout {
            Button {
                id: backButton
                visible: root.selectedArtist !== null || root.selectedAlbum !== null
                text: qsTr("Back")
                highlighted: true
                palette.accent: AppColors.accentPrimary
                palette.highlight: AppColors.accentPrimary

                Shortcut {
                    sequence: "Escape"
                    context: Qt.WindowShortcut
                    enabled: root.visible && backButton.visible && !letterNavigator.visible
                    onActivated: backButton.clicked()
                }
                onClicked: {
                    if (root.selectedAlbum) root.selectedAlbum = null
                    else root.selectedArtist = null
                }
            }
            Label {
                Layout.fillWidth: true
                text: root.selectedAlbum ? (root.selectedAlbum.name || qsTr("Unknown album")) : root.selectedArtist ? (root.selectedArtist.name || qsTr("Unknown artist")) : root.albumsOnly ? qsTr("Albums") : qsTr("Artists")
                elide: Text.ElideRight
                font.bold: true
            }
        }
        ListView {
            id: grid
            visible: root.selectedAlbum === null
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            readonly property int cardWidth: 210
            readonly property int columns: Math.max(1, Math.floor(width / cardWidth))
            model: root.cardRows(root.cards, columns)
            onModelChanged: positionViewAtBeginning()
            ScrollBar.vertical: ScrollBar {}
            delegate: Item {
                required property var modelData
                width: grid.width
                height: modelData.letter ? 44 : grid.cardWidth
                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.letter
                    visible: modelData.letter !== ""
                    font.bold: true
                    font.pixelSize: 22
                    color: AppColors.textDisabled
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: modelData.letter !== ""
                    visible: enabled
                    cursorShape: Qt.PointingHandCursor
                    onClicked: letterNavigator.open()
                }
                Row {
                    Repeater {
                        model: modelData.cards
                        delegate: LibraryCard {
                            required property var modelData
                            width: grid.cardWidth
                            height: width
                            coverSource: modelData.cover
                            title: modelData.name || (root.showingAlbums ? qsTr("Unknown album") : qsTr("Unknown artist"))
                            subtitle: root.showingAlbums
                                      ? qsTr("Tracks: %1").arg(modelData.tracks)
                                      : qsTr("Albums: %1 · Tracks: %2").arg(modelData.albums.length).arg(modelData.tracks)
                            onActivated: {
                                if (root.showingAlbums)
                                    root.selectedAlbum = modelData
                                else
                                    root.selectedArtist = modelData
                            }
                            onContextMenuRequested: {
                                menu.popup()
                            }
                            Menu {
                                id: menu
                                MenuItem {
                                    text: root.showingAlbums ? qsTr("Change album name") : qsTr("Change artist name")
                                    enabled: !albumEditor.running
                                    onTriggered: {
                                        albumNameDialog.editingArtist = !root.showingAlbums
                                        albumNameDialog.originalName = modelData.name
                                        albumNameDialog.artistName = root.showingAlbums ? modelData.artist : modelData.name
                                        const files = root.showingAlbums ? modelData.files
                                            : modelData.albums.reduce((tracks, album) => tracks.concat(album.files), [])
                                        albumNameDialog.filePaths = files.map(file => file.path)
                                        albumNameField.text = modelData.name
                                        albumNameDialog.open()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Label {
                anchors.centerIn: parent
                visible: grid.count === 0
                text: root.libraryModel.loading ? qsTr("Loading…") : root.albumsOnly ? qsTr("No albums in the library") : qsTr("No artists in the library")
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
