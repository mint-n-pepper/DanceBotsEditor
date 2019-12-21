#!/bin/sh
#
# Auto-format and lint code
#
# Usage
#	  ./lint.sh
#
#
# Note: Folders to format and lint
# - gui
# - src
# - test


CLANG_FORMAT_STYLE_FILE="Google"

# start Python virtual environment
. venv/bin/activate

# auto-format and lint each folder
for FOLDER in "../gui/" "../src/" "../test/"; do
	# auto-format
	find "${FOLDER}" -regex '.*\.\(cpp\|hpp\|c\|h\)' -exec clang-format -style="${CLANG_FORMAT_STYLE_FILE}" {} \;

	# lint recursively
	cpplint --recursive "${FOLDER}"
done

# close Python virtual environment
deactivate