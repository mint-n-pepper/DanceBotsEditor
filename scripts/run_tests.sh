#!/bin/sh
#
# Run all unit tests
#
# Usage
#   sh run_tests.sh <path_to_build_directory>
#

# constants
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# display usage instructions
usage()
{
  echo ""
  echo "usage: run_tests.sh <build-dir>"
  echo ""
  echo "Run all unit tests."
  echo ""
  echo "positional arguments:"
  echo ""
  echo "  build-dir             cmake build directory"
  echo ""
  exit 1
}

# check for build-directory
if [ "$#" -ne 1 ]; then
  echo "Incorrect number of arguments" >&2
  usage
fi

if ! [ -e "$1" ]; then
  echo "$1 not found" >&2
  usage
fi

if ! [ -d "$1" ]; then
  echo "$1 is not a directory" >&2
  usage
fi

BUILD_DIR=$1

# run all unit tests (except the manual ones)
"${BUILD_DIR}/test/test_audiofile/test-audiofile"
STATUS=$?
"${BUILD_DIR}/test/test_beatdetect/test-beatdetect"
STATUS=$(($STATUS + $?))
"${BUILD_DIR}/test/test_kissfft/test-kissfft"
STATUS=$(($STATUS + $?))
"${BUILD_DIR}/test/test_primitives/test-primitives"
STATUS=$(($STATUS + $?))
"${BUILD_DIR}/test/test_utils/test-utils"
STATUS=$(($STATUS + $?))

# output result of all tests
if [ $STATUS -eq 0 ]; then
  echo "${GREEN}ALL TESTS SUCCESSFUL${NC}"
  exit 0
else
  echo "${RED}NOT ALL TESTS SUCCESSFUL, SEE ABOVE${NC}" >&2
  exit 1
fi
