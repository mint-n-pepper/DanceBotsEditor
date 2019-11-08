project(test-beatdetect)

find_package(Qt5 COMPONENTS Widgets REQUIRED)

set(SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/../../src/AudioFile.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/../../src/BeatDetector.cpp)
    
set(INCLUDE_DIRS  ${CMAKE_CURRENT_SOURCE_DIR}/../../src
                  ${CMAKE_CURRENT_SOURCE_DIR}/../../lib/kissfft)

include_directories(${INCLUDE_DIRS})

set(HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/../../lib/kissfft/kissfft.hh
            ${CMAKE_CURRENT_SOURCE_DIR}/../../src/AudioFile.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../../src/BeatDetector.h)

source_group("Header Files" FILES ${HEADERS})

add_executable(${PROJECT_NAME} main.cpp ${SOURCES} ${HEADERS})

target_link_libraries(  ${PROJECT_NAME}
                        gtest
                        gmock
                        lib-qm-dsp
                        mp3lame
                        lib-qm-vamp
                        sndfile
                        tag
                        Qt5::Widgets)

# copy visual studio user file to binary folder to have
# qt in debug path:
if(WIN32)
  file(COPY ../../template.vcxproj.user
       DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
  file(RENAME ${CMAKE_CURRENT_BINARY_DIR}/template.vcxproj.user
              ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.vcxproj.user)
endif()

# group libraries in IDE folder:
set_target_properties(${PROJECT_NAME} PROPERTIES FOLDER tests)