#!/usr/bin/env bash

set -u

SCRIPT_FULLPATH=$(readlink -e "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")
#FILENAME_PROG=1.zip

cd "$SCRIPT_DIR"

#[ -e "$SCRIPT_DIR/$FILENAME_PROG" ] || wget "https://path_to_arc/${FILENAME_PROG}"

cd -
