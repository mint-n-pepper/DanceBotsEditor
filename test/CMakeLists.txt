add_subdirectory(test_audiofile)
add_subdirectory(test_audioplayer)
add_subdirectory(test_kissfft)
add_subdirectory(test_utils)
add_subdirectory(test_beatdetect)

# COPY TEST MP3 to build test folder
FILE(COPY ${CMAKE_CURRENT_SOURCE_DIR}/test_mp3_files
     DESTINATION ${CMAKE_CURRENT_BINARY_DIR})