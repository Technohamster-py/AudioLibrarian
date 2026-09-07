import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/**
 * @brief Settings and result view for duplicate file search.
 */
Item {
    id: root

    /** @brief Enables byte-identical file search using SHA-256. */
    property bool searchByHash: true

    /** @brief Enables duplicate search using audio metadata. */
    property bool searchByMetadata: true

    /** @brief Enables duplicate search using file names. */
    property bool searchByFileName: false

    /** @brief Maximum allowed duration difference in seconds. */
    property int durationTolerance: 2

    /** @brief Indicates that duplicate search is currently running. */
    property bool searching: false

    /** @brief Number of duplicate groups in the latest result. */
    property int duplicateGroupCount: 0

    /** @brief Number of files participating in duplicate groups. */
    property int duplicateFileCount: 0

    /** @brief Number of files that can be removed while keeping one copy. */
    property int removableFileCount: 0

    property string phase: ""
    property string currentFile: ""
    property string errorMessage: ""
    property int progressCurrent: 0
    property int progressTotal: 0

    DuplicateFinderController {
        id: duplicateFinderController
        objectName: "duplicateFinderController"
    }

    /** @brief Requests a duplicate search with the current settings. */
    signal searchRequested(
        bool searchByHash,
        bool searchByMetadata,
        bool searchByFileName,
        int durationTolerance
    )

    signal cancelRequested()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AppMetrics.spacingLarge

        spacing: AppMetrics.spacingMedium

        Label {
            Layout.fillWidth: true

            text: qsTr("Search settings")

            color: AppColors.settingsTextPrimary

            font.pixelSize: 24
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: AppColors.settingsSeparator
        }

        CheckBox {
            id: hashCheckBox
            objectName: "searchByHashCheckBox"

            text: qsTr("Search by file content (hash)")
            palette.windowText: AppColors.textPrimary

            checked: root.searchByHash

            onToggled: {
                root.searchByHash = checked
            }
        }

        CheckBox {
            id: metadataCheckBox
            objectName: "searchByMetadataCheckBox"

            text: qsTr("Search by metadata")
            palette.windowText: AppColors.textPrimary


            checked: root.searchByMetadata

            onToggled: {
                root.searchByMetadata = checked
            }
        }

        CheckBox {
            id: fileNameCheckBox
            objectName: "searchByFileNameCheckBox"

            text: qsTr("Search by file name")
            palette.windowText: AppColors.textPrimary


            checked: root.searchByFileName

            onToggled: {
                root.searchByFileName = checked
            }
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: AppMetrics.spacingMedium

            Label {
                Layout.fillWidth: true

                text: qsTr("Duration tolerance")

                color: AppColors.settingsTextPrimary
            }

            SpinBox {
                id: durationToleranceSpinBox
                objectName: "durationToleranceSpinBox"

                Layout.preferredWidth: 140

                from: 0
                to: 3600
                stepSize: 1
                value: root.durationTolerance

                editable: true
                live: true

                property string suffix: qsTr(" sec")

                textFromValue: function(value, locale) {
                    return Number(value).toLocaleString(locale, 'f', 0) + suffix
                }

                valueFromText: function(text, locale) {
                    const number = text.replace(/[^\d]/g, "")

                    if (number.length === 0)
                        return value

                    return Number.fromLocaleString(locale, number)
                }

                enabled: root.searchByMetadata

                onValueModified: {
                    root.durationTolerance = value
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            Layout.topMargin: AppMetrics.spacingMedium

            color: AppColors.settingsSeparator
        }

        Label {
            text: qsTr("Result")

            color: AppColors.settingsTextPrimary

            font.pixelSize: 20
            font.bold: true
        }

        Rectangle {
            id: resultPanel
            objectName: "duplicateResultPanel"

            Layout.fillWidth: true
            Layout.fillHeight: true

            color: AppColors.settingsBackground

            border.width: 1
            border.color: AppColors.settingsSeparator

            ColumnLayout {
                anchors.centerIn: parent

                spacing: AppMetrics.spacingMedium

                BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    running: root.searching
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter

                    visible: root.searching

                    text: root.phase
                    color: AppColors.settingsTextPrimary
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter

                    visible: root.searching && root.currentFile !== ""

                    text: root.currentFile
                    color: AppColors.settingsTextSecondary
                    elide: Text.ElideMiddle
                }

                ProgressBar {
                    Layout.preferredWidth: 400

                    visible: root.searching

                    from: 0
                    to: root.progressTotal
                    value: root.progressCurrent
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter

                    visible: !root.searching && root.errorMessage !== ""

                    text: root.errorMessage
                    color: AppColors.settingsTextPrimary
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter

                    visible: !root.searching
                        && root.errorMessage === ""
                        && root.duplicateGroupCount === 0

                    text: qsTr("No duplicate groups found")
                    color: AppColors.settingsTextSecondary
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter

                    visible: !root.searching
                        && root.errorMessage === ""
                        && root.duplicateGroupCount > 0

                    text: qsTr("%1 groups · %2 files · %3 removable")
                        .arg(root.duplicateGroupCount)
                        .arg(root.duplicateFileCount)
                        .arg(root.removableFileCount)

                    color: AppColors.settingsTextPrimary
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Button {
                id: searchButton
                objectName: "findDuplicatesButton"

                Layout.alignment: Qt.AlignRight

                text: root.searching ? qsTr("Cancel") : qsTr("Find duplicates")

                enabled: root.searching
                    || root.searchByHash
                    || root.searchByMetadata
                    || root.searchByFileName

                onClicked: {
                    if (root.searching) {
                        root.cancelRequested()
                        return
                    }

                    root.searchRequested(root.searchByHash, root.searchByMetadata, root.searchByFileName, root.durationTolerance
                    )
                }
            }
        }
    }
}
