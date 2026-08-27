import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for AudioFileDelegate.
 */
TestCase {
    id: testCase

    name: "AudioFileDelegate"

    Component {
        id: component

        AudioFileDelegate {
            width: 600
            height: 56
        }
    }

    Component {
        id: signalSpyComponent

        SignalSpy {
        }
    }

    function test_default_state() {
        const delegate = createTemporaryObject(component, testCase)

        verify(delegate !== null)

        compare(delegate.selected, false)

        compare(delegate.fileName, "")

        compare(delegate.artist, "")

        compare(delegate.album, "")

        compare(delegate.year, 0)

        compare(delegate.duration, "")
    }

    function test_metadata_properties() {
        const delegate = createTemporaryObject(component, testCase)

        delegate.fileName = "Song.flac"
        delegate.artist = "Artist"
        delegate.album = "Album"
        delegate.year = 2026
        delegate.duration = "03:21"

        compare(delegate.fileName, "Song.flac")

        compare(delegate.artist, "Artist")

        compare(delegate.album, "Album")

        compare(delegate.year, 2026)

        compare(delegate.duration, "03:21")
    }

    function test_selection() {
        const delegate = createTemporaryObject(component, testCase)

        compare(delegate.selected, false)

        delegate.selected = true

        compare(delegate.selected, true)

        delegate.selected = false

        compare(delegate.selected, false)
    }

    function test_activation_signal() {
        const delegate = createTemporaryObject(component, testCase)

        const spy = createTemporaryObject(signalSpyComponent, testCase)

        spy.target = delegate
        spy.signalName = "activated"

        const mouseArea = findChild(delegate, "mouseArea")

        verify(mouseArea !== null)

        mouseArea.clicked(null)

        compare(spy.count, 1)
    }

    function test_multiple_activations() {
        const delegate = createTemporaryObject(component, testCase)

        const spy = createTemporaryObject(signalSpyComponent, testCase)

        spy.target = delegate
        spy.signalName = "activated"

        const mouseArea = findChild(delegate, "mouseArea")

        verify(mouseArea !== null)

        mouseArea.clicked(null)
        mouseArea.clicked(null)
        mouseArea.clicked(null)

        compare(spy.count, 3)
    }
}