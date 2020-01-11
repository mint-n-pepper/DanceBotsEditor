#!/bin/sh
# help user:
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 BUILD_FOLDER" >&2
  exit 1
fi
if ! [ -e "$1" ]; then
  echo "$1 not found" >&2
  exit 1
fi
if ! [ -d "$1" ]; then
  echo "$1 not a directory" >&2
  exit 1
fi

# run all unit tests (except the manual ones)
$1test/test_audiofile/test-audiofile
status=$?
$1test/test_beatdetect/test-beatdetect
status=$(($status + $?))
$1test/test_kissfft/test-kissfft
status=$(($status + $?))
$1test/test_primitives/test-primitives
status=$(($status + $?))
$1test/test_utils/test-utils
status=$(($status + $?))

# output result of all tests
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
if [ $status -eq 0 ]
then
  echo "${GREEN}ALL TESTS SUCCESSFUL${NC}"
else
  echo "${RED}NOT ALL TESTS SUCCESSFUL, SEE ABOVE${NC}"
fi
