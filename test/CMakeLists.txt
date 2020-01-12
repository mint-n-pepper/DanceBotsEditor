add_subdirectory(test_audiofile)
add_subdirectory(test_audioplayer)
add_subdirectory(test_kissfft)
add_subdirectory(test_utils)
add_subdirectory(test_beatdetect)
add_subdirectory(test_primitives)

# Configure header that has path for unit tests to find MP3 files:
SET(TEST_FOLDER_PATH ${CMAKE_CURRENT_SOURCE_DIR}/test_mp3_files/)
configure_file(test_folder_path.in ${CMAKE_CURRENT_SOURCE_DIR}/test_folder_path.h)
