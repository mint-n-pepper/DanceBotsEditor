project(test-audiofile)

find_package(Qt5 COMPONENTS Widgets REQUIRED)

set(AUDIOFILE_SRC ${CMAKE_SOURCE_DIR}/src/AudioFile.cpp)

set(HEADERS ${CMAKE_SOURCE_DIR}/src/AudioFile.h
            ${CMAKE_SOURCE_DIR}/test/TestFolderPath.h
)

include_directories(${CMAKE_SOURCE_DIR})
source_group("Headers" FILES ${HEADERS})

add_executable(${PROJECT_NAME} main.cpp ${AUDIOFILE_SRC} ${HEADERS})

target_link_libraries(${PROJECT_NAME}
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
