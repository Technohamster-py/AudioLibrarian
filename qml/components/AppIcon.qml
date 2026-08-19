import QtQuick

/**
 * @brief Displays an SVG icon from the Qt resource system.
 *
 * The component is intentionally small. It provides a single place where
 * application icons are rendered, so changing the rendering strategy later
 * does not require modifying every button using an icon.
 */
Text {
    id: root

    /**
     * @brief Resource URL of the icon.
     *
     * Expected format:
     * qrc:/qt/qml/AudioLibrarian/assets/files.svg
     */
    property string source: ""

    /**
     * @brief Controls whether the image preserves its aspect ratio.
     */
    property alias fillMode: iconImage.fillMode

    Image {
        id: iconImage

        anchors.fill: parent

        source: root.source

        sourceSize.width: width
        sourceSize.height: height

        fillMode: Image.PreserveAspectFit

        asynchronous: true
        smooth: true

        mipmap: true
    }
}