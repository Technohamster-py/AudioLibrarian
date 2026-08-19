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
        verify(AppMetrics.libraryMinimumWidth > 0)

        verify(
            AppMetrics.libraryMinimumWidth
            < AppMetrics.libraryMaximumWidth
        )
    }

    function test_player_height_is_positive() {
        verify(AppMetrics.playerHeight > 0)
    }

    function test_library_width_is_valid() {
        verify(AppMetrics.libraryWidth >= AppMetrics.libraryMinimumWidth)
        verify(AppMetrics.libraryWidth <= AppMetrics.libraryMaximumWidth)
    }
}