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

    readonly property color primary: "#202020"
    readonly property color background: primary
    readonly property color panel: "#2b2b2b"
    readonly property color panelElevated: "#323232"
    readonly property color separator: "#3d3d3d"

    readonly property color textPrimary: "#ffffff"
    readonly property color textSecondary: "#c5c5c5"
    readonly property color textDisabled: "#808080"

    readonly property color accentPrimary: "#ff6766"
    readonly property color accentSecondary: "#18c5c8"
    readonly property color selection: "#333f40"
    readonly property color hover: "#353535"

    readonly property color inputBackground: "#1f1f1f"
    readonly property color inputBorder: separator
    readonly property color inputBorderActive: accentPrimary

    readonly property color error: "#ff99a4"
    readonly property color warning: "#fce100"

    // Module palettes

    // Player palette
    readonly property color playerBackground: panel
    readonly property color playerForeground: textPrimary

    // Editor palette
    readonly property color editorBackground: background

    readonly property color editorTextPrimary: textPrimary
    readonly property color editorTextSecondary: textSecondary

    readonly property color editorPanel: panel
    readonly property color editorPanelDisabled: separator

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
    readonly property color toolbarBackground: "#202020"

    // Settings palette
    readonly property color settingsBackground: background

    readonly property color settingsTextPrimary: textPrimary
    readonly property color settingsTextSecondary: textSecondary

    readonly property color settingsSeparator: separator

    // Batch palette
    readonly property color duplicatesMethodColor: panelElevated
}
