# Override options in libsamplerate CMakeLists:
set(LIBSAMPLERATE_TESTS OFF CACHE BOOL "en/disable test building for libsamplerate")
set(LIBSAMPLERATE_INSTALL OFF CACHE BOOL "en/disable install for libsamplerate")
set(BUILD_SHARED_LIBS OFF CACHE BOOL "en/disable shared lib building for libsamplerate")

add_subdirectory(libsamplerate)#${CMAKE_CURRENT_BINARY_DIR}/lib/libsamplerate)

# Override options in libsndfile CMakeLists:
set(MAKE_DOCS OFF CACHE BOOL "en/disable doc building for libsndfile")
set(BUILD_TESTING OFF CACHE BOOL "en/disable test building for libsndfile")
set(BUILD_PROGRAMS OFF CACHE BOOL "en/disable program build for libsndfile")
set(BUILD_EXAMPLES OFF CACHE BOOL "en/disable example build for libsndfile")
set(ENABLE_CPACK OFF CACHE BOOL "en/disable cpack build for libsndfile")
set(ENABLE_PACKAGE_CONFIG OFF CACHE BOOL "en/disable pkg config build for libsndfile")

add_subdirectory(libsndfile)#${CMAKE_CURRENT_BINARY_DIR}/lib/libsndfile)

# copy libsndfile include to lib/include
FILE(COPY ${CMAKE_CURRENT_BINARY_DIR}/libsndfile/src/sndfile.h
     DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_include_directories(sndfile PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)

# add lame lib:
add_subdirectory(libmp3lame-CMAKE)#${CMAKE_CURRENT_BINARY_DIR}/lib/libmp3lame)

# pull in lib-qm-vamp
add_subdirectory(qm-vamp-plugins)# ${CMAKE_CURRENT_BINARY_DIR}/lib/lib-qm-vamp)