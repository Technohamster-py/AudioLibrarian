import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for PlayerBar mock playback state.
 */
TestCase {
    id: testCase

    name: "PlayerBar"
    when: windowShown

    Component {
        id: component

        PlayerBar {
            width: 500
            height: 82
        }
    }

    function test_initial_state() {
        const player = createTemporaryObject(component, testCase)

        verify(player !== null)

        compare(player.playing, false)
        compare(player.progress, 0.35)
    }

    function test_play_pause_button_changes_state() {
        const player = createTemporaryObject(component, testCase)
        const button = findChild(player, "playPauseButton")

        verify(button !== null)
        compare(player.playing, false)

        button.click()

        compare(player.playing, true)

        button.click()

        compare(player.playing, false)
    }

    function test_progress_can_be_changed() {
        const player = createTemporaryObject(component, testCase)

        player.progress = 0.75

        compare(player.progress, 0.75)
    }
}
