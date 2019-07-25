project(gtest-test)
  
add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME}
                        gtest)

# group libraries in IDE folder:
set_target_properties(${PROJECT_NAME} PROPERTIES FOLDER tests)