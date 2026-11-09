pragma Singleton

import QtQuick

/**
 * @brief Global dimensions used by the AudioLibrarian UI.
 *
 * Shared Fluent spacing, typography and dimensions for application views.
 */
QtObject {
    // App
    readonly property int appMinimumWidth: 960
    readonly property int appMinimumHeight: 600

    readonly property int appMaximumWidth: 2560
    readonly property int appMaximumHeight: 1440

    readonly property int navigationBarWidth: 64

    readonly property int iconButtonSize: 40

    readonly property int spacingSmall: 4
    readonly property int spacingMedium: 8
    readonly property int spacingLarge: 16

    readonly property int radiusSmall: 4
    readonly property int radiusMedium: 8

    // Library
    readonly property int libraryWidth: 900
    readonly property int libraryMinimumWidth: 420
    readonly property int libraryMaximumWidth: 2000

    readonly property int navigationItemHeight: 40
    readonly property real minimumLibraryColumnWidth: 60
    readonly property real minimumCoverColumnWidth: 48

    readonly property int sortIconSize: 24

    // Editor
    readonly property int editorMinimumWidth: 360
    readonly property int editorWidth: 620
    readonly property int editorMaximumWidth: 1880

    readonly property int editorKeyWidth: 140

    readonly property int editFieldRadius: 4
    readonly property int editFieldBorder: 1
    readonly property int editFieldBorderBold: 2

    // Player
    readonly property int playerHeight: 104
    readonly property int playerButtonsSize: 40

    // Text
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeMedium: 14
    readonly property int fontSizeLarge: 24

    readonly property string fontFamily: "Segoe UI"
    readonly property int fontSizeTitle: 28
    readonly property int fontSizeSubtitle: 20
    readonly property int pagePadding: 24
    readonly property int sectionSpacing: 24
    readonly property int controlHeight: 32
    readonly property int tableRowHeight: 40

    // Batch
    readonly property int duplicatesFontLarge: fontSizeSubtitle
    readonly property int duplicatesFontMedium: fontSizeMedium
    readonly property int duplicatesFontSmall: fontSizeMedium
    readonly property int duplicatesRowHeightLarge: 48
    readonly property int duplicatesRowHeightSmall: tableRowHeight
}
