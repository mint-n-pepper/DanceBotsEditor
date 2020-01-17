cmake_minimum_required( VERSION 3.0.0 )

include( CMakeParseArguments )

function( version_from_git )
  # find git or quit
  find_package( Git )
  if( NOT GIT_FOUND )
    message( FATAL_ERROR "[GitVersion] Git not found" )
  endif( NOT GIT_FOUND )

  # first try to get tag
  execute_process(
    COMMAND           "${GIT_EXECUTABLE}" describe --tags --abbrev=0
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    RESULT_VARIABLE   git_result
    OUTPUT_VARIABLE   git_output
    ERROR_VARIABLE    git_error
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE
    )

  # if there isn't a tag, get the commit hash
  if( NOT git_result EQUAL 0 )
    execute_process(
    COMMAND           "${GIT_EXECUTABLE}" log --pretty=format:'%h' -n 1
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    RESULT_VARIABLE   git_result
    OUTPUT_VARIABLE   git_output
    ERROR_VARIABLE    git_error
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE
    )
  endif()

  # strip out apostrophes
  string(REPLACE "'" "" version ${git_output})

  # set parent scope variables
  set( VERSION "${version}" PARENT_SCOPE )

  message( STATUS "[Version] ${version}" )
    
endfunction( version_from_git )
