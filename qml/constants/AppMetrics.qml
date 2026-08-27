pragma Singleton

import QtQuick

/**
 * @brief Global dimensions used by the AudioLibrarian UI.
 *
 * These values describe the structural geometry of the prototype rather
 * than the final design system. They are centralized so that the layout
 * can be tuned without editing every component.
 */
QtObject {
    // App
    readonly property int appMinimumWidth: 960
    readonly property int appMinimumHeight: 600

    readonly property int appMaximumWidth: 2560
    readonly property int appMaximumHeight: 1440

    readonly property int navigationBarWidth: 80

    readonly property int iconButtonSize: 45

    readonly property int spacingSmall: 4
    readonly property int spacingMedium: 8
    readonly property int spacingLarge: 16

    readonly property int radiusSmall: 4
    readonly property int radiusMedium: 8

    // Library
    readonly property int libraryWidth: 900
    readonly property int libraryMinimumWidth: 600
    readonly property int libraryMaximumWidth: 2000

    readonly property int navigationItemHeight: 50
    readonly property real minimumLibraryColumnWidth: 60
    readonly property real minimumCoverColumnWidth: 48

    readonly property int sortIconSize: 24

    // Editor
    readonly property int editorMinimumWidth: 480
    readonly property int editorWidth: 620
    readonly property int editorMaximumWidth: 1880

    readonly property int editorKeyWidth: 180

    // Player
    readonly property int playerHeight: 140
    readonly property int playerButtonsSize: 60

    // Text
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeMedium: 16
    readonly property int fontSizeLarge: 24
}
