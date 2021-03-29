get_filename_component(SRC_DIR ${SRC} DIRECTORY)



# Generate a git-describe-like version string from Mercurial repository tags

if(HG_EXECUTABLE AND NOT DEFINED VAL_VERSION)

  execute_process(
    COMMAND ${HG_EXECUTABLE} log --rev . --template
      "{latesttag}{sub\('\^-0-.*', '', '-{latesttagdistance}-m{node|short}'\)}"
    WORKING_DIRECTORY ${SRC_DIR}
    OUTPUT_VARIABLE HG_REVISION
    RESULT_VARIABLE HG_LOG_ERROR_CODE
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )



  # Append "-dirty" if the working copy is not clean

  execute_process(
    COMMAND ${HG_EXECUTABLE} id --id
    WORKING_DIRECTORY ${SRC_DIR}
    OUTPUT_VARIABLE HG_ID
    RESULT_VARIABLE HG_ID_ERROR_CODE
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )

  # The hg id ends with '+' if there are uncommitted local changes

  if(HG_ID MATCHES "\\+$")
    set(HG_REVISION "${HG_REVISION}-dirty")
  endif()

  if(NOT HG_LOG_ERROR_CODE AND NOT HG_ID_ERROR_CODE)
    set(FOOBAR_VERSION ${HG_REVISION})
  endif()

endif()



# Generate a git-describe version string from Git repository tags

if(GIT_EXECUTABLE AND NOT DEFINED FOOBAR_VERSION)

  execute_process(
    COMMAND ${GIT_EXECUTABLE} describe --always --tags --dirty --match "v*"
    WORKING_DIRECTORY ${SRC_DIR}
    OUTPUT_VARIABLE GIT_DESCRIBE_VERSION
    RESULT_VARIABLE GIT_DESCRIBE_ERROR_CODE
#    OUTPUT_FILE "${CMAKE_BINARY_DIR}/dynamic_decoder_version.txt"
#    ERROR_FILE "${CMAKE_BINARY_DIR}/dynamic_decoder_version_error.txt"         
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )

  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
    OUTPUT_VARIABLE GIT_FULL_SHA
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  set(GIT_SHA ${GIT_FULL_SHA})
  
  execute_process(
    COMMAND ${GIT_EXECUTABLE} branch --show-current
    OUTPUT_VARIABLE GIT_CURRENT_BRANCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  set(GIT_BRANCH ${GIT_CURRENT_BRANCH})  
  
  execute_process(
    COMMAND date +%Y-%m-%dT%H:%M:%S
    OUTPUT_VARIABLE BUILDTIMESTAMP
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )  
  set(BUILD_TIMESTAMP ${BUILDTIMESTAMP})  
  
  execute_process(
    COMMAND ${GIT_EXECUTABLE} diff --shortstat
    OUTPUT_VARIABLE GIT_DIRTY_STATUS
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  set(GIT_IS_DIRTY "TRUE")

  if(NOT GIT_DESCRIBE_ERROR_CODE)
    set(FOOBAR_VERSION ${GIT_DESCRIBE_VERSION})
  endif()

  if(NOT GIT_DIRTY_STATUS)
    set(GIT_IS_DIRTY "FALSE")
  endif()
  
endif()

message(WARNING "Version \"${FOOBAR_VERSION}\".")
message(WARNING "SHA     \"${GIT_SHA}\".")
message(WARNING "Branch  \"${GIT_BRANCH}\".")
message(WARNING "Dirty?  \"${GIT_IS_DIRTY}\".")
message(WARNING "Time?  \"${BUILD_TIMESTAMP}\".")



# Final fallback: Just use a bogus version string that is semantically older

# than anything else and spit out a warning to the developer.

if(NOT DEFINED FOOBAR_VERSION)
  set(FOOBAR_VERSION v0.0.0-unknown)
  message(WARNING "Failed to determine FOOBAR_VERSION from repository tags. Using default version \"${FOOBAR_VERSION}\".")
endif()

if(NOT DEFINED GIT_SHA)
  set(GIT_SHA 0000000000000000)
  message(WARNING "Failed to determine GIT_SHA from repository tags. Using default version \"${GIT_SHA}\".")
endif()

configure_file(${SRC} ${DST} @ONLY)
