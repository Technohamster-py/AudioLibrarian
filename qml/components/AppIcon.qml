import QtQuick

/**
 * @brief Small text-based placeholder icon.
 *
 * The first UI vertical slice intentionally avoids introducing an icon
 * library. The icon property contains a Unicode symbol used only until
 * the final SVG icon set is selected.
 */
Text {
    id: root

    property string icon: "?"

    text: root.icon
    color: AppColors.textPrimary
    font.pixelSize: 22
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
}