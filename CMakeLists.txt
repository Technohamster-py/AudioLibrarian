cmake_minimum_required(VERSION 3.16)
project(AudioLibrarian VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)


find_package(Qt6 REQUIRED COMPONENTS
        Core
        Gui
        Concurrent
        Quick
        QuickControls2
        QuickTest
)

find_package(TagLib 2.0 REQUIRED)

qt_standard_project_setup(REQUIRES 6.11)

# ---------------------------------------------------------------------------
# Core application logic
# ---------------------------------------------------------------------------

add_library(AudioLibrarianCore STATIC
        src/library/audiofiletablemodel.h       src/library/audiofiletablemodel.cpp
        src/metadata/audiometadata.h            src/metadata/audiometadata.cpp
        src/metadata/tageditormodel.h           src/metadata/tageditormodel.cpp
        src/metadata/taglibmetadatabackend.h    src/metadata/taglibmetadatabackend.cpp
)

target_link_libraries(AudioLibrarianCore
        PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Concurrent
        TagLib::tag
)

target_include_directories(AudioLibrarianCore PRIVATE
    src
)

# ---------------------------------------------------------------------------
# QML UI module
# ---------------------------------------------------------------------------
qt_add_library(AudioLibrarianUi STATIC)

set_source_files_properties(
        qml/app/MainWindow.qml
        PROPERTIES QT_RESOURCE_ALIAS "MainWindow.qml"
)

set_source_files_properties(
        qml/components/AppIcon.qml
        PROPERTIES QT_RESOURCE_ALIAS "AppIcon.qml"
)

set_source_files_properties(
        qml/components/AppToolButton.qml
        PROPERTIES QT_RESOURCE_ALIAS "AppToolButton.qml"
)

set_source_files_properties(
        qml/editor/EditorView.qml
        PROPERTIES QT_RESOURCE_ALIAS "EditorView.qml"
)

set_source_files_properties(
        qml/editor/TagEditorView.qml
        PROPERTIES QT_RESOURCE_ALIAS "TagEditorView.qml"
)

set_source_files_properties(
        qml/library/AudioFileDelegate.qml
        PROPERTIES QT_RESOURCE_ALIAS "AudioFileDelegate.qml"
)

set_source_files_properties(
        qml/library/LibraryPane.qml
        PROPERTIES QT_RESOURCE_ALIAS "LibraryPane.qml"
)

set_source_files_properties(
        qml/library/LibraryView.qml
        PROPERTIES QT_RESOURCE_ALIAS "LibraryView.qml"
)

set_source_files_properties(
        qml/navigation/NavigationView.qml
        PROPERTIES QT_RESOURCE_ALIAS "NavigationView.qml"
)

set_source_files_properties(
        qml/navigation/NavigationItem.qml
        PROPERTIES QT_RESOURCE_ALIAS "NavigationItem.qml"
)

set_source_files_properties(
        qml/navigation/NavigationPlaceholderView.qml
        PROPERTIES QT_RESOURCE_ALIAS "NavigationPlaceholderView.qml"
)

set_source_files_properties(
        qml/player/PlayerBar.qml
        PROPERTIES QT_RESOURCE_ALIAS "PlayerBar.qml"
)

set_source_files_properties(
        qml/theme/AppColors.qml
        PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
        QT_RESOURCE_ALIAS "AppColors.qml"
)

set_source_files_properties(
        qml/theme/AppMetrics.qml
        PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
        QT_RESOURCE_ALIAS "AppMetrics.qml"
)

qt_add_qml_module(AudioLibrarianUi
        URI AudioLibrarian
        VERSION 0.1

        # QML_ELEMENT types must be listed as SOURCES of the QML module so
        # qmltyperegistrar generates their module registration.  The model's
        # implementation remains in AudioLibrarianCore above.
        SOURCES
        src/library/audiofiletablemodel.h
        src/metadata/tageditormodel.h

        QML_FILES
        qml/Main.qml

        qml/app/MainWindow.qml

        qml/components/AppIcon.qml
        qml/components/AppToolButton.qml

        qml/editor/EditorView.qml
        qml/editor/TagEditorView.qml

        qml/library/AudioFileDelegate.qml
        qml/library/LibraryPane.qml
        qml/library/LibraryView.qml

        qml/player/PlayerBar.qml

        qml/navigation/NavigationBar.qml
        qml/navigation/NavigationItem.qml
        qml/navigation/NavigationPlaceholderView.qml

        qml/theme/AppColors.qml
        qml/theme/AppMetrics.qml

        RESOURCES
        assets/albums.svg
        assets/artists.svg
        assets/backward.svg
        assets/duplicate.svg
        assets/files.svg
        assets/forward.svg
        assets/music-library.svg
        assets/music.svg
        assets/pause.svg
        assets/play.svg
        assets/settings.svg
)

target_link_libraries(AudioLibrarianUi
        PRIVATE
        AudioLibrarianCore
        Qt6::Quick
        Qt6::QuickControls2
)

target_include_directories(AudioLibrarianUi PRIVATE
        src
        src/library
        src/metadata
)

# ---------------------------------------------------------------------------
# Application
# ---------------------------------------------------------------------------


qt_add_executable(AudioLibrarian
        src/main.cpp
)

target_link_libraries(AudioLibrarian
        PRIVATE
        AudioLibrarianCore
        AudioLibrarianUiplugin
        Qt6::Gui
        Qt6::Quick
        Qt6::QuickControls2
)

# ---------------------------------------------------------------------------
# QML tests
# ---------------------------------------------------------------------------

enable_testing()

add_executable(tst_AudioLibrarian
        tests/qml/tst_audioLibrarian.cpp
)

target_link_libraries(tst_AudioLibrarian
        PRIVATE
        AudioLibrarianUiplugin
        Qt6::QuickTest
        Qt6::Qml
        Qt6::Gui
)

target_compile_definitions(tst_AudioLibrarian
        PRIVATE
        QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/tests/qml"
)

add_test(
        NAME tst_AudioLibrarian
        COMMAND tst_AudioLibrarian -platform offscreen
)


# ---------------------------------------------------------------------------
# Metadata tests
# ---------------------------------------------------------------------------

add_executable(tst_TagLibMetadataBackend
        tests/metadata/tst_taglibmetadatabackend.cpp
)

target_link_libraries(tst_TagLibMetadataBackend
        PRIVATE
        AudioLibrarianCore
        Qt6::Test
)

add_test(
        NAME tst_TagLibMetadataBackend
        COMMAND tst_TagLibMetadataBackend
)

# ---------------------------------------------------------------------------
# Library model tests
# ---------------------------------------------------------------------------

add_executable(tst_AudioFileTableModel
        tests/library/tst_audiofiletablemodel.cpp
)

target_link_libraries(tst_AudioFileTableModel
        PRIVATE
        AudioLibrarianCore
        Qt6::Test
)

target_include_directories(tst_AudioFileTableModel PRIVATE
        src
)

add_test(
        NAME tst_AudioFileTableModel
        COMMAND tst_AudioFileTableModel
)


# ---------------------------------------------------------------------------
# Windows / Qt deployment
# ---------------------------------------------------------------------------
#
# Qt provides a CMake deployment API for desktop applications.
# Since AudioLibrarian is a Qt Quick/QML application, use the QML-specific
# deployment script. It invokes the appropriate deployment tool internally
# and determines the required Qt libraries, plugins and QML modules from
# the application target.
#
# The generated script is executed by "cmake --install", not during linking.
# ---------------------------------------------------------------------------

if (WIN32)
    install(TARGETS AudioLibrarian
            RUNTIME DESTINATION bin
    )

    qt_generate_deploy_qml_app_script(
            TARGET AudioLibrarian
            OUTPUT_SCRIPT deploy_script
    )

    install(SCRIPT ${deploy_script})
endif()