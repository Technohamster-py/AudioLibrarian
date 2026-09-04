pragma Singleton

import QtQuick

/**
 * @brief Global color palette used by the AudioLibrarian UI.
 *
 * Keeping colors in one singleton prevents individual components from
 * accumulating unrelated hard-coded color values.
 */
QtObject {
    // Global palette

    readonly property color primary: "#1e1e1e"
    readonly property color background: primary
    readonly property color panel: "#292929"
    readonly property color panelElevated: "#303030"
    readonly property color separator: "#454545"

    readonly property color textPrimary: "#f2f2f2"
    readonly property color textSecondary: "#a8a8a8"
    readonly property color textDisabled: "#686868"

    readonly property color accentPrimary: "#ff6766"
    readonly property color accentSecondary: "#18c5c8"
    readonly property color selection: "#333f40"
    readonly property color hover: "#353535"


    // Module palettes

    // Player palette
    readonly property color playerBackground: accentPrimary
    readonly property color playerForeground: "#161616"


    // Editor palette
    readonly property color editorBackground: background

    readonly property color editorTextPrimary: textPrimary
    readonly property color editorTextSecondary: textSecondary

    readonly property color editorPanel: panel


    // Navigation palette
    readonly property color navigationBackground: background
    readonly property color navigationPanel: panel
    readonly property color navigationElevated: panelElevated

    readonly property color navigationSelection: selection
    readonly property color navigationHover: hover
    readonly property color navigationAccent: accentPrimary

    readonly property color navigationTextPrimary: textPrimary
    readonly property color navigationTextSecondary: textSecondary

    readonly property color navigationSeparator: separator


    // Toolbar palette
    readonly property color toolbarBackground: "#171717"


    // Settings palette
    readonly property color settingsBackground: background

    readonly property color settingsTextPrimary: textPrimary
    readonly property color settingsTextSecondary: textSecondary

    readonly property color settingsSeparator: separator
}
