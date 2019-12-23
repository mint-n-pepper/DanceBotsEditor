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
#
# @TODO configure style file to follow this guideline?
# ## Naming
#
# | Element 	| Example | Comment |
# | ------- 	| ------- | ------- |
# | Variable 	| `fileName` | camelCase |
# | Member Variable | `mFileName` | m + CamelCase|
# | Constant	| `fileName` | like variable |
# | Enum | `eWriteOnly` | e + CamelCase|
# | Class | `FileHandler` | CamelCase|
# | Files | `FileHandler.h` | CamelCase + file ending|
#
# ## Indentation / Tabs
# are two spaces.


CLANG_FORMAT_STYLE_FILE="Google"

# start Python virtual environment
. venv/bin/activate

# auto-format and lint each folder
for FOLDER in "../gui/" "../src/" "../test/"; do
	# auto-format
	find "${FOLDER}" -regex '.*\.\(cpp\|hpp\|c\|h\)' -exec clang-format -i -style="${CLANG_FORMAT_STYLE_FILE}" {} \;

	# lint recursively
	cpplint --recursive --filter=-whitespace/indent "${FOLDER}"
done

# close Python virtual environment
deactivate
