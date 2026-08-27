import QtQuick
import QtTest
import AudioLibrarian

/**
 * @brief Tests for NavigationBar.
 */
TestCase {
    id: testCase

    name: "NavigationBar"

    Component {
        id: component

        NavigationBar {
            width: 56
            height: 600
        }
    }

    Component {
        id: signalSpyComponent

        SignalSpy {}
    }

    function test_default_section() {
        const navigation = createTemporaryObject(component, testCase)

        verify(navigation !== null)

        compare(navigation.currentSection, "files")
    }

    function test_section_property() {
        const navigation = createTemporaryObject(component, testCase)

        navigation.currentSection = "albums"

        compare(navigation.currentSection, "albums")

        navigation.currentSection = "artists"

        compare(navigation.currentSection, "artists")

        navigation.currentSection = "library"

        compare(navigation.currentSection, "library")

        navigation.currentSection = "duplicates"

        compare(navigation.currentSection, "duplicates")

        navigation.currentSection = "settings"

        compare(navigation.currentSection, "settings")
    }

    function test_section_selected_signal() {
        const navigation = createTemporaryObject(component, testCase)

        const spy = createTemporaryObject(signalSpyComponent, testCase)

        spy.target = navigation
        spy.signalName = "sectionSelected"

        navigation.sectionSelected("albums")

        compare(spy.count, 1)

        compare(spy.signalArguments[0][0], "albums")
    }

    function test_section_selected_arguments() {
        const navigation = createTemporaryObject(component, testCase)

        const spy = createTemporaryObject(signalSpyComponent, testCase)

        spy.target = navigation
        spy.signalName = "sectionSelected"

        const sections = [
            "files",
            "albums",
            "artists",
            "library",
            "duplicates",
            "settings"
        ]

        for (let i = 0; i < sections.length; ++i) {
            navigation.sectionSelected(sections[i])
            compare(spy.signalArguments[i][0], sections[i])
        }

        compare(spy.count, sections.length)
    }
}