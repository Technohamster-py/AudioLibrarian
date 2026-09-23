import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Batch metadata editor view.
 *
 * Allows selecting metadata fields and specifying values that should be
 * applied to all selected files.
 */
Item {
    id: root

    property bool editing: false
    property int selectedFileCount: 0

    signal changesRequested(var changes)

    // Scalar fields.
    property bool titleEnabled: false
    property string titleValue: ""

    property bool albumEnabled: false
    property string albumValue: ""

    property bool dateEnabled: false
    property string dateValue: ""

    property bool trackNumberEnabled: false
    property string trackNumberValue: ""

    property bool discNumberEnabled: false
    property string discNumberValue: ""

    property bool lyricsEnabled: false
    property string lyricsValue: ""

    // Multi-value fields.
    property bool artistEnabled: false
    property var artistValues: []

    property bool albumArtistEnabled: false
    property var albumArtistValues: []

    property bool genreEnabled: false
    property var genreValues: []

    property bool commentEnabled: false
    property var commentValues: []

    function createChanges() {
        var changes = []

        if (titleEnabled) {
            changes.push({
                key: "TITLE",
                values: [titleValue],
                remove: titleValue.length === 0
            })
        }

        if (artistEnabled) {
            changes.push({
                key: "ARTIST",
                values: artistValues,
                remove: artistValues.length === 0
            })
        }

        if (albumEnabled) {
            changes.push({
                key: "ALBUM",
                values: [albumValue],
                remove: albumValue.length === 0
            })
        }

        if (albumArtistEnabled) {
            changes.push({
                key: "ALBUMARTIST",
                values: albumArtistValues,
                remove: albumArtistValues.length === 0
            })
        }

        if (genreEnabled) {
            changes.push({
                key: "GENRE",
                values: genreValues,
                remove: genreValues.length === 0
            })
        }

        if (commentEnabled) {
            changes.push({
                key: "COMMENT",
                values: commentValues,
                remove: commentValues.length === 0
            })
        }

        if (dateEnabled) {
            changes.push({
                key: "DATE",
                values: [dateValue],
                remove: dateValue.length === 0
            })
        }

        if (trackNumberEnabled) {
            changes.push({
                key: "TRACKNUMBER",
                values: [trackNumberValue],
                remove: trackNumberValue.length === 0
            })
        }

        if (discNumberEnabled) {
            changes.push({
                key: "DISCNUMBER",
                values: [discNumberValue],
                remove: discNumberValue.length === 0
            })
        }

        if (lyricsEnabled) {
            changes.push({
                key: "LYRICS",
                values: [lyricsValue],
                remove: lyricsValue.length === 0
            })
        }

        return changes
    }

    function hasChanges() {
        return titleEnabled ||
            artistEnabled ||
            albumEnabled ||
            albumArtistEnabled ||
            genreEnabled ||
            commentEnabled ||
            dateEnabled ||
            trackNumberEnabled ||
            discNumberEnabled ||
            lyricsEnabled
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppMetrics.spacingMedium
        spacing: AppMetrics.spacingMedium

        Label {
            Layout.fillWidth: true

            text: qsTr("Metadata editor")
            color: AppColors.settingsTextPrimary
            font.pixelSize: 20
            font.bold: true
        }

        Label {
            Layout.fillWidth: true

            text: root.selectedFileCount > 0
                ? qsTr("Selected files: %1").arg(root.selectedFileCount)
                : qsTr("No files selected")

            color: AppColors.settingsTextSecondary
        }

        ScrollView {
            id: fieldsScrollView
            objectName: "fieldsScrollView"

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true

            ColumnLayout {
                width: fieldsScrollView.availableWidth
                spacing: AppMetrics.spacingSmall

                MetadataEditRow {
                    id: titleRow
                    objectName: "titleRow"

                    Layout.fillWidth: true

                    label: qsTr("Title")
                    tagName: "TITLE"

                    checked: root.titleEnabled
                    value: root.titleValue

                    onValueEdited: function(newValue) {
                        root.titleValue = newValue
                    }

                    onCheckedChanged: root.titleEnabled = checked
                }

                MetadataEditRow {
                    id: artistRow
                    objectName: "artistRow"

                    Layout.fillWidth: true

                    label: qsTr("Artist")
                    tagName: "ARTIST"

                    checked: root.artistEnabled
                    multiValue: true
                    values: root.artistValues

                    onValuesEdited: function(newValues) {
                        root.artistValues = newValues
                    }

                    onCheckedChanged: root.artistEnabled = checked
                }

                MetadataEditRow {
                    id: albumRow
                    objectName: "albumRow"

                    Layout.fillWidth: true

                    label: qsTr("Album")
                    tagName: "ALBUM"

                    checked: root.albumEnabled
                    value: root.albumValue

                    onValueEdited: function(newValue) {
                        root.albumValue = newValue
                    }

                    onCheckedChanged: root.albumEnabled = checked
                }

                MetadataEditRow {
                    id: albumArtistRow
                    objectName: "albumArtistRow"

                    Layout.fillWidth: true

                    label: qsTr("Album artist")
                    tagName: "ALBUMARTIST"

                    checked: root.albumArtistEnabled
                    multiValue: true
                    values: root.albumArtistValues

                    onValuesEdited: function(newValues) {
                        root.albumArtistValues = newValues
                    }

                    onCheckedChanged: root.albumArtistEnabled = checked
                }

                MetadataEditRow {
                    id: genreRow
                    objectName: "genreRow"

                    Layout.fillWidth: true

                    label: qsTr("Genre")
                    tagName: "GENRE"

                    checked: root.genreEnabled
                    multiValue: true
                    values: root.genreValues

                    onValuesEdited: function(newValues) {
                        root.genreValues = newValues
                    }

                    onCheckedChanged: root.genreEnabled = checked
                }

                MetadataEditRow {
                    id: commentRow
                    objectName: "commentRow"

                    Layout.fillWidth: true

                    label: qsTr("Comment")
                    tagName: "COMMENT"

                    checked: root.commentEnabled
                    multiValue: true
                    values: root.commentValues

                    onValuesEdited: function(newValues) {
                        root.commentValues = newValues
                    }

                    onCheckedChanged: root.commentEnabled = checked
                }

                MetadataEditRow {
                    id: dateRow
                    objectName: "dateRow"

                    Layout.fillWidth: true

                    label: qsTr("Date")
                    tagName: "DATE"

                    checked: root.dateEnabled
                    value: root.dateValue

                    onValueEdited: function(newValue) {
                        root.dateValue = newValue
                    }

                    onCheckedChanged: root.dateEnabled = checked
                }

                MetadataEditRow {
                    id: trackNumberRow
                    objectName: "trackNumberRow"

                    Layout.fillWidth: true

                    label: qsTr("Track number")
                    tagName: "TRACKNUMBER"

                    checked: root.trackNumberEnabled
                    value: root.trackNumberValue

                    onValueEdited: function(newValue) {
                        root.trackNumberValue = newValue
                    }

                    onCheckedChanged: root.trackNumberEnabled = checked
                }

                MetadataEditRow {
                    id: discNumberRow
                    objectName: "discNumberRow"

                    Layout.fillWidth: true

                    label: qsTr("Disc number")
                    tagName: "DISCNUMBER"

                    checked: root.discNumberEnabled
                    value: root.discNumberValue

                    onValueEdited: function(newValue) {
                        root.discNumberValue = newValue
                    }

                    onCheckedChanged: root.discNumberEnabled = checked
                }

                MetadataEditRow {
                    id: lyricsRow
                    objectName: "lyricsRow"

                    Layout.fillWidth: true

                    label: qsTr("Lyrics")
                    tagName: "LYRICS"

                    checked: root.lyricsEnabled
                    value: root.lyricsValue
                    multiline: true

                    onValueEdited: function(newValue) {
                        root.lyricsValue = newValue
                    }

                    onCheckedChanged: root.lyricsEnabled = checked
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

                enabled: root.editing && root.selectedFileCount > 0 && root.hasChanges()

                onClicked: root.changesRequested(root.createChanges())
            }
        }
    }
}