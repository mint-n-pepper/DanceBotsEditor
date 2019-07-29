project(audiofile)

find_package(Qt5 COMPONENTS Widgets REQUIRED)

set(AUDIOFILE_SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/../../src/AudioFile.cpp)
    
file(GLOB HEADERS_SRC ${CMAKE_CURRENT_SOURCE_DIR}/../../src/*.hpp)
    
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../src)
source_group("Headers" FILES ${HEADERS_SRC})

add_executable(${PROJECT_NAME} main.cpp ${AUDIOFILE_SRC} ${HEADERS_SRC})

target_link_libraries(${PROJECT_NAME}
						gtest
						lib-qm-dsp
                        mp3lame
                        tag
                        Qt5::Widgets)

# copy visual studio user file to binary folder to have
# qt in debug path:
if(WIN32)
  file(COPY template.vcxproj.user
       DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
  file(RENAME ${CMAKE_CURRENT_BINARY_DIR}/template.vcxproj.user
              ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.vcxproj.user)
endif()

# group libraries in IDE folder:
set_target_properties(${PROJECT_NAME} PROPERTIES FOLDER tests)