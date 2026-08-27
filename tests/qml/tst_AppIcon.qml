import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for AppIcon.
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
        const icon =
            createTemporaryObject(component, testCase)

        verify(icon !== null)

        compare(icon.source.toString(), "")
    }

    function test_source_can_be_set() {
        const icon =
            createTemporaryObject(component, testCase)

        const source = "qrc:/qt/qml/AudioLibrarian/assets/files.svg"

        icon.source = source

        compare(icon.source.toString(), source)
    }
}