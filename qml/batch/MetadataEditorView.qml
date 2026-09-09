import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief User interface for batch metadata editing.
 *
 * Each metadata field can be enabled independently. Enabled fields are
 * converted into MetadataChange objects by the controller.
 */
Item {
    id: root

    /** @brief Indicates that metadata editing is currently running. */
    property bool editing: false

    /** @brief Number of files selected for processing. */
    property int selectedFileCount: 0

    /** @brief Requests applying the configured metadata changes. */
    signal changesRequested(var changes)

    property bool titleEnabled: false
    property string titleValue: ""

    property bool artistEnabled: false
    property string artistValue: ""

    property bool albumEnabled: false
    property string albumValue: ""

    property bool albumArtistEnabled: false
    property string albumArtistValue: ""

    property bool genreEnabled: false
    property string genreValue: ""

    property bool commentEnabled: false
    property string commentValue: ""

    property bool dateEnabled: false
    property string dateValue: ""

    property bool trackNumberEnabled: false
    property string trackNumberValue: ""

    property bool discNumberEnabled: false
    property string discNumberValue: ""

    property bool lyricsEnabled: false
    property string lyricsValue: ""

    function createChanges() {
        const changes = []

        if (titleEnabled)
            changes.push({key: "TITLE", values: [titleValue], remove: titleValue.length === 0})

        if (artistEnabled)
            changes.push({key: "ARTIST", values: [artistValue], remove: artistValue.length === 0})

        if (albumEnabled)
            changes.push({key: "ALBUM", values: [albumValue], remove: albumValue.length === 0})

        if (albumArtistEnabled)
            changes.push({key: "ALBUMARTIST", values: [albumArtistValue], remove: albumArtistValue.length === 0})

        if (genreEnabled)
            changes.push({key: "GENRE", values: [genreValue], remove: genreValue.length === 0})

        if (commentEnabled)
            changes.push({key: "COMMENT", values: [commentValue], remove: commentValue.length === 0})

        if (dateEnabled)
            changes.push({key: "DATE", values: [dateValue], remove: dateValue.length === 0})

        if (trackNumberEnabled)
            changes.push({key: "TRACKNUMBER", values: [trackNumberValue], remove: trackNumberValue.length === 0})

        if (discNumberEnabled)
            changes.push({key: "DISCNUMBER", values: [discNumberValue], remove: discNumberValue.length === 0})

        if (lyricsEnabled)
            changes.push({key: "LYRICS", values: [lyricsValue], remove: lyricsValue.length === 0})

        return changes
    }

    function hasChanges() {
        return titleEnabled
            || artistEnabled
            || albumEnabled
            || albumArtistEnabled
            || genreEnabled
            || commentEnabled
            || dateEnabled
            || trackNumberEnabled
            || discNumberEnabled
            || lyricsEnabled
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppMetrics.spacingLarge

        spacing: AppMetrics.spacingMedium

        Label {
            Layout.fillWidth: true

            text: qsTr("Edit metadata")

            color: AppColors.settingsTextPrimary

            font.pixelSize: 24
            font.bold: true
        }

        Label {
            Layout.fillWidth: true

            text: qsTr("Selected files: %1").arg(root.selectedFileCount)

            color: AppColors.settingsTextSecondary
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: AppColors.settingsSeparator
        }

        ScrollView {
            id: metadataScrollView
            objectName: "metadataEditorScrollView"

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true

            ColumnLayout {
                width: metadataScrollView.availableWidth

                spacing: AppMetrics.spacingSmall

                MetadataEditRow {
                    objectName: "titleEditRow"

                    label: qsTr("Title")
                    tagName: "TITLE"

                    checked: root.titleEnabled
                    value: root.titleValue

                    onCheckedChanged: root.titleEnabled = checked
                    onValueEdited: root.titleValue = value
                }

                MetadataEditRow {
                    objectName: "artistEditRow"

                    label: qsTr("Artist")
                    tagName: "ARTIST"

                    checked: root.artistEnabled
                    value: root.artistValue

                    onCheckedChanged: root.artistEnabled = checked
                    onValueEdited: root.artistValue = value
                }

                MetadataEditRow {
                    objectName: "albumEditRow"

                    label: qsTr("Album")
                    tagName: "ALBUM"

                    checked: root.albumEnabled
                    value: root.albumValue

                    onCheckedChanged: root.albumEnabled = checked
                    onValueEdited: root.albumValue = value
                }

                MetadataEditRow {
                    objectName: "albumArtistEditRow"

                    label: qsTr("Album artist")
                    tagName: "ALBUMARTIST"

                    checked: root.albumArtistEnabled
                    value: root.albumArtistValue

                    onCheckedChanged: root.albumArtistEnabled = checked
                    onValueEdited: root.albumArtistValue = value
                }

                MetadataEditRow {
                    objectName: "genreEditRow"

                    label: qsTr("Genre")
                    tagName: "GENRE"

                    checked: root.genreEnabled
                    value: root.genreValue

                    onCheckedChanged: root.genreEnabled = checked
                    onValueEdited: root.genreValue = value
                }

                MetadataEditRow {
                    objectName: "commentEditRow"

                    label: qsTr("Comment")
                    tagName: "COMMENT"

                    checked: root.commentEnabled
                    value: root.commentValue

                    onCheckedChanged: root.commentEnabled = checked
                    onValueEdited: root.commentValue = value
                }

                MetadataEditRow {
                    objectName: "dateEditRow"

                    label: qsTr("Date")
                    tagName: "DATE"

                    checked: root.dateEnabled
                    value: root.dateValue

                    onCheckedChanged: root.dateEnabled = checked
                    onValueEdited: root.dateValue = value
                }

                MetadataEditRow {
                    objectName: "trackNumberEditRow"

                    label: qsTr("Track number")
                    tagName: "TRACKNUMBER"

                    checked: root.trackNumberEnabled
                    value: root.trackNumberValue

                    onCheckedChanged: root.trackNumberEnabled = checked
                    onValueEdited: root.trackNumberValue = value
                }

                MetadataEditRow {
                    objectName: "discNumberEditRow"

                    label: qsTr("Disc number")
                    tagName: "DISCNUMBER"

                    checked: root.discNumberEnabled
                    value: root.discNumberValue

                    onCheckedChanged: root.discNumberEnabled = checked
                    onValueEdited: root.discNumberValue = value
                }

                MetadataEditRow {
                    objectName: "lyricsEditRow"

                    label: qsTr("Lyrics")
                    tagName: "LYRICS"

                    multiline: true

                    checked: root.lyricsEnabled
                    value: root.lyricsValue

                    onCheckedChanged: root.lyricsEnabled = checked
                    onValueEdited: root.lyricsValue = value
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: AppColors.settingsSeparator
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: AppMetrics.spacingMedium

            Label {
                Layout.fillWidth: true

                text: root.hasChanges()
                    ? qsTr("%1 field(s) will be changed").arg(root.createChanges().length)
                    : qsTr("No changes selected")

                color: AppColors.settingsTextSecondary
            }

            Button {
                id: applyButton
                objectName: "applyMetadataChangesButton"

                text: qsTr("Apply changes")

                enabled: !root.editing
                    && root.selectedFileCount > 0
                    && root.hasChanges()

                onClicked: {
                    root.changesRequested(root.createChanges())
                }
            }
        }
    }
}