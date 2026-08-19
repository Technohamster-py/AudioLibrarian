import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for AudioFileDelegate.
 */
TestCase {
    id: testCase

    name: "AudioFileDelegate"
    when: windowShown

    Component {
        id: component

        AudioFileDelegate {
            width: 600
            height: 56
        }
    }

    Component {
        id: signalSpyComponent
        SignalSpy { }
    }

    function test_default_state() {
        const delegate = createTemporaryObject(component, testCase)

        verify(delegate !== null)

        compare(delegate.selected, false)
        compare(delegate.fileName, "")
        compare(delegate.artist, "")
        compare(delegate.album, "")
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

    function test_activation_signal() {
        const delegate = createTemporaryObject(component, testCase)
        const spy = createTemporaryObject(signalSpyComponent, testCase)
        spy.target = delegate
        spy.signalName = "activated"

        findChild(delegate, "mouseArea").clicked(null)

        compare(spy.count, 1)
    }
}
