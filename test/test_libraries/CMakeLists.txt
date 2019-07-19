project(lib_test)

find_package(Qt5 COMPONENTS Widgets REQUIRED)

add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME}
                        lib-qm-vamp
                        samplerate
                        mp3lame
                        sndfile
                        Qt5::Widgets)

# copy visual studio user file to binary folder to have
# qt in debug path:
if(WIN32)
  file(COPY template.vcxproj.user
       DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
  file(RENAME ${CMAKE_CURRENT_BINARY_DIR}/template.vcxproj.user
              ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.vcxproj.user)
endif()
