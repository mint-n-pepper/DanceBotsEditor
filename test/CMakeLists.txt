add_subdirectory(test_libraries)
add_subdirectory(test_audiofile)
add_subdirectory(test_gtest)

# COPY TEST MP3 to build test folder
FILE(COPY ${CMAKE_CURRENT_SOURCE_DIR}/test_mp3_files
     DESTINATION ${CMAKE_CURRENT_BINARY_DIR})