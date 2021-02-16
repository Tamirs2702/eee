#!/bin/bash
set -eo pipefail
source /ez/util.sh

if [ $1 -eq 0 ] || [ $1 -eq 256 ]; then
  debug $(basename $PWD) exited with code $1
else
  warn $(basename $PWD) exited with error code $1
fi
