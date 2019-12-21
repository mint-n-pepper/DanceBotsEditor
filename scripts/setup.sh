#!/bin/sh
#
# Auto-generate python virtual environments and install requirements.
#
# Usage
#	  ./setup.sh
#

VENV_PATH="venv"

# if path does not exist, generate a new virtual environment
if [ ! -d "${VENV_PATH}" ]; then
    PYTHON=`which python3`

    if [ ! -f "${PYTHON}" ]; then
        echo "Could not find Python"
    fi
    virtualenv -p "${PYTHON}" "${VENV_PATH}"
fi

# activate the virtual environment
. "${VENV_PATH}/bin/activate"

# install requirements
pip install -r requirements.txt
