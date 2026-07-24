cmake_minimum_required(VERSION 3.9)
project(AudioLibrarian LANGUAGES CXX)

set(CMAKE_PREFIX_PATH /usr/local/qt/Qt-6.6.1)

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.6)

qt_add_executable(AudioLibrarian
    main.cpp
)

qt_add_qml_module(AudioLibrarian
        URI Main
        QML_FILES
            Main.qml
        RESOURCES
            assets/audio-file.svg
)

target_link_libraries(AudioLibrarian
        PRIVATE
        Qt6::Quick
)