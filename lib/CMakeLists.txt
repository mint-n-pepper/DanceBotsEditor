# Override options in libsndfile CMakeLists:
set(MAKE_DOCS OFF CACHE BOOL "en/disable doc building for libsndfile")
set(BUILD_TESTING OFF CACHE BOOL "en/disable test building for libsndfile")
set(BUILD_PROGRAMS OFF CACHE BOOL "en/disable program build for libsndfile")
set(BUILD_EXAMPLES OFF CACHE BOOL "en/disable example build for libsndfile")
set(ENABLE_CPACK OFF CACHE BOOL "en/disable cpack build for libsndfile")
set(ENABLE_PACKAGE_CONFIG OFF CACHE BOOL "en/disable pkg config build for libsndfile")

add_subdirectory(libsndfile)

# copy libsndfile include to lib/include
FILE(COPY ${CMAKE_CURRENT_BINARY_DIR}/libsndfile/src/sndfile.h
     DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_include_directories(sndfile PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)

# add lame lib:
add_subdirectory(lame-3.100)

# pull in lib-qm-vamp
add_subdirectory(qm-vamp-plugins)

# add taglib:
set(BUILD_BINDINGS OFF CACHE BOOL "en/disable simple c interface building")
set(ENABLE_STATIC_RUNTIME ON CACHE BOOL "enable static library building" FORCE)

add_subdirectory(taglib)
target_compile_definitions(tag PUBLIC -DTAGLIB_STATIC)
target_include_directories(tag PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/taglib/taglib)
target_include_directories(tag PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/taglib/taglib/toolkit)
target_include_directories(tag PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/taglib/taglib/mpeg)
target_include_directories(tag PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/taglib/taglib/mpeg/id3v1)
target_include_directories(tag PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/taglib/taglib/mpeg/id3v2)
target_include_directories(tag PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/taglib/3rdparty)
target_include_directories(tag PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
FILE(COPY ${CMAKE_CURRENT_BINARY_DIR}/taglib/taglib_config.h
     DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/include)

# add Google Test
add_subdirectory(googletest)

# group libraries in IDE folder:
set_target_properties(lib-qm-dsp lib-qm-vamp mp3lame sndfile tag uninstall docs gtest gtest_main gmock gmock_main PROPERTIES FOLDER libs)