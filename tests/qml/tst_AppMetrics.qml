import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for the global UI metrics singleton.
 */
TestCase {
    name: "AppMetrics"

    function test_navigation_widths_are_valid() {
        verify(AppMetrics.navigationBarWidth > 0)
        verify(AppMetrics.navigationViewMinimumWidth > 0)

        verify(
            AppMetrics.navigationViewMinimumWidth
            < AppMetrics.navigationViewMaximumWidth
        )
    }

    function test_player_height_is_positive() {
        verify(AppMetrics.playerHeight > 0)
    }
}