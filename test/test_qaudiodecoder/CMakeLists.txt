project(test-qaudiodecoder)

set(CMAKE_AUTOMOC ON)

find_package(Qt5 COMPONENTS Widgets Multimedia REQUIRED)

set(DECODER_SRC ${CMAKE_CURRENT_SOURCE_DIR}/../../src/Decoder.cpp)

set(HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/../../src/Decoder.h)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../src)
source_group("Headers" FILES ${HEADERS})

add_executable(${PROJECT_NAME} main.cpp ${HEADERS} ${DECODER_SRC})

target_link_libraries(${PROJECT_NAME}
                      gtest
                      Qt5::Multimedia
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
