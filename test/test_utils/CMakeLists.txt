project(test-utils)

include_directories(${CMAKE_SOURCE_DIR})

set(HEADERS ${CMAKE_SOURCE_DIR}/src/utils.h)

source_group("Header Files" FILES ${HEADERS})

add_executable(${PROJECT_NAME} main.cc ${HEADERS})

target_link_libraries(  ${PROJECT_NAME}
                        gtest)

# group libraries in IDE folder:
set_target_properties(${PROJECT_NAME} PROPERTIES FOLDER tests)
