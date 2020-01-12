project(test-audioplayer)

set(CMAKE_CXX_STANDARD 14)

set(CMAKE_AUTOMOC ON)

find_package(Qt5 COMPONENTS Widgets Multimedia REQUIRED)

set(AUDIOFILE_SRC ${CMAKE_SOURCE_DIR}/src/audio_file.cc
                  ${CMAKE_SOURCE_DIR}/src/audio_player.cc
                  ${CMAKE_CURRENT_SOURCE_DIR}/dummy_ui.cc)

set(HEADERS ${CMAKE_SOURCE_DIR}/src/audio_file.h
            ${CMAKE_SOURCE_DIR}/src/audio_player.h
            ${CMAKE_CURRENT_SOURCE_DIR}/dummy_ui.h
            ${CMAKE_SOURCE_DIR}/test/test_folder_path.h)

include_directories(${CMAKE_SOURCE_DIR})
source_group("Headers" FILES ${HEADERS})

add_executable(${PROJECT_NAME} main.cc ${AUDIOFILE_SRC} ${HEADERS})

target_link_libraries(  ${PROJECT_NAME}
                        lib-qm-dsp
                        mp3lame
                        sndfile
                        tag
                        Qt5::Widgets
                        Qt5::Multimedia)

# copy visual studio user file to binary folder to have
# qt in debug path:
if(WIN32)
  configure_file(${CMAKE_SOURCE_DIR}/template.vcxproj.in
			   ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.vcxproj.user
			   @ONLY)
endif()

# group libraries in IDE folder:
set_target_properties(${PROJECT_NAME} PROPERTIES FOLDER manual_tests)
