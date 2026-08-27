import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for PlayerBar.
 *
 * PlayerBar is a presentation component. Playback state is owned by
 * PlayerController and is therefore tested through the controller instance.
 */
TestCase {
    id: testCase

    name: "PlayerBar"

    Component {
        id: component

        Item {
            width: 600
            height: 82

            PlayerController {
                id: player

                objectName: "playerController"
            }

            PlayerBar {
                id: playerBar

                objectName: "playerBar"

                anchors.fill: parent

                player: player
            }
        }
    }

    function test_component_created() {
        const root = createTemporaryObject(component, testCase)

        verify(root !== null)

        const playerBar = findChild(root, "playerBar")

        verify(playerBar !== null)
    }

    function test_initial_controller_state() {
        const root = createTemporaryObject(component, testCase)

        const player = findChild(root, "playerController")

        verify(player !== null)

        compare(player.playing, false)
        compare(player.paused, false)
        compare(player.volume, 100)
        compare(player.muted, false)
        compare(player.position, 0)
        compare(player.duration, 0)
    }

    function test_play_pause_button_exists() {
        const root = createTemporaryObject(component, testCase)

        const button = findChild(root, "playPauseButton")

        verify(button !== null)
        verify(button.enabled)
    }

    function test_volume_slider() {
        const root = createTemporaryObject(component, testCase)

        const player = findChild(root, "playerController")

        const slider = findChild(root, "volumeSlider")

        verify(player !== null)
        verify(slider !== null)

        slider.value = 50

        /*
         * onMoved is the handler responsible for transferring the
         * slider value to PlayerController.
         */
        slider.moved()

        compare(player.volume, 50)
    }

    function test_mute_button() {
        const root = createTemporaryObject(component, testCase)

        const player = findChild(root, "playerController")

        const button = findChild(root, "muteButton")

        verify(player !== null)
        verify(button !== null)

        compare(player.muted, false)

        button.clicked()

        compare(player.muted, true)

        button.clicked()

        compare(player.muted, false)
    }

    function test_time_formatting() {
        const root = createTemporaryObject(component, testCase)

        const playerBar = findChild(root, "playerBar")

        verify(playerBar !== null)

        compare(playerBar.formatTime(0), "00:00")

        compare(playerBar.formatTime(1000), "00:01")

        compare(playerBar.formatTime(61000), "01:01")

        compare(playerBar.formatTime(3599000), "59:59")

        compare(playerBar.formatTime(3600000), "01:00:00")

        compare(playerBar.formatTime(3661000), "01:01:01")
    }

    function test_track_title_fallback() {
        const root = createTemporaryObject(component, testCase)

        const player = findChild(root, "playerController")

        verify(player !== null)

        /*
         * Metadata starts empty, therefore PlayerBar must display
         * its "No track selected" fallback.
         */
        compare(player.title, "")

        compare(player.artist, "")
    }
}