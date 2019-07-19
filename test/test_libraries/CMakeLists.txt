project(lib_test)

find_package(Qt5 COMPONENTS Widgets REQUIRED)

add_executable(lib_test main.cpp ${BEAT_TRACK_SRC})

target_link_libraries(lib_test
                        lib-qm-vamp
                        samplerate
                        mp3lame
                        sndfile
                        Qt5::Widgets)