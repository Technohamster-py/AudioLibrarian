pragma Singleton

import QtQuick

/**
 * @brief Global color palette used by the AudioLibrarian UI.
 *
 * Keeping colors in one singleton prevents individual components from
 * accumulating unrelated hard-coded color values.
 */
QtObject {
    readonly property color primary: "#1e1e1e"
    readonly property color background: primary
    readonly property color navigationBar: "#171717"
    readonly property color panel: "#292929"
    readonly property color panelElevated: "#303030"
    readonly property color separator: "#454545"

    readonly property color textPrimary: "#f2f2f2"
    readonly property color textSecondary: "#a8a8a8"
    readonly property color textDisabled: "#686868"

    readonly property color accent: "#18c5c8"
    readonly property color selection: "#333f40"
    readonly property color hover: "#353535"

    readonly property color playerBackground: "#ff6766"
    readonly property color playerForeground: "#161616"
}
