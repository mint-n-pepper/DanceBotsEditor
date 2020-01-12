project(test-primitives)

set(CMAKE_AUTOMOC ON)

find_package(Qt5 COMPONENTS Widgets REQUIRED)

include_directories(${CMAKE_SOURCE_DIR})

set(HEADERS ${CMAKE_SOURCE_DIR}/src/primitive.h
            ${CMAKE_SOURCE_DIR}/src/audio_file.h)

source_group("Header Files" FILES ${HEADERS})

set(TEST_SRC ${CMAKE_SOURCE_DIR}/src/primitive.cc
             ${CMAKE_SOURCE_DIR}/src/audio_file.cc
             ${CMAKE_CURRENT_SOURCE_DIR}/main.cc)

add_executable(${PROJECT_NAME} ${TEST_SRC} ${HEADERS})

target_link_libraries(  ${PROJECT_NAME}
                        gtest
                        lib-qm-dsp
                        mp3lame
                        sndfile
                        tag
                        Qt5::Widgets)

# copy visual studio user file to binary folder to have
# qt in debug path:
if(WIN32)
  configure_file(${CMAKE_SOURCE_DIR}/template.vcxproj.in
                 ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.vcxproj.user
                 @ONLY)
endif()

# group libraries in IDE folder:
set_target_properties(${PROJECT_NAME} PROPERTIES FOLDER tests)
