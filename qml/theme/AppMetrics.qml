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
    readonly property int navigationBarWidth: 80

    readonly property int navigationViewWidth: 900
    readonly property int navigationViewMinWidth: 300
    readonly property int navigationViewMaxWidth: 1500

    readonly property int playerHeight: 80

    readonly property int navigationItemHeight: 50
    readonly property int iconButtonSize: 45

    readonly property int spacingSmall: 4
    readonly property int spacingMedium: 8
    readonly property int spacingLarge: 16

    readonly property int radiusSmall: 4
    readonly property int radiusMedium: 8
}