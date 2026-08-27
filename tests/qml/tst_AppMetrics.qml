import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for application UI metrics.
 */
TestCase {
    name: "AppMetrics"

    function test_navigation_widths_are_valid() {
        verify(AppMetrics.navigationBarWidth > 0)

        verify(AppMetrics.libraryMinimumWidth > 0)

        verify(AppMetrics.libraryMaximumWidth > AppMetrics.libraryMinimumWidth)
    }

    function test_editor_widths_are_valid() {
        verify(AppMetrics.editorMinimumWidth > 0)

        verify(AppMetrics.editorMaximumWidth > AppMetrics.editorMinimumWidth)
    }

    function test_player_height_is_positive() {
        verify(AppMetrics.playerHeight > 0)
    }

    function test_library_width_is_valid() {
        verify(AppMetrics.libraryWidth >= AppMetrics.libraryMinimumWidth)

        verify(AppMetrics.libraryWidth <= AppMetrics.libraryMaximumWidth)
    }

    function test_application_minimum_size_is_valid() {
        verify(AppMetrics.appMinimumWidth > 0)

        verify(AppMetrics.appMinimumHeight > 0)
    }

    function test_application_maximum_size_is_valid() {
        verify(AppMetrics.appMaximumWidth > AppMetrics.appMinimumWidth)

        verify(AppMetrics.appMaximumHeight > AppMetrics.appMinimumHeight)
    }
}