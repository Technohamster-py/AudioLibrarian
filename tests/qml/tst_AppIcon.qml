import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for SVG icon rendering component.
 */
TestCase {
    id: testCase

    name: "AppIcon"

    Component {
        id: component

        AppIcon {
            width: 32
            height: 32
        }
    }

    function test_default_source_is_empty() {
        const icon = createTemporaryObject(component, testCase)

        compare(icon.source.toString(), "")
    }

    function test_source_can_be_set() {
        const icon = createTemporaryObject(component, testCase)

        icon.source = "qrc:/qt/qml/AudioLibrarian/assets/files.svg"

        compare(
            icon.source.toString(),
            "qrc:/qt/qml/AudioLibrarian/assets/files.svg"
        )
    }
}