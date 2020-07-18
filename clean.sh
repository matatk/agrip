#!/bin/sh
echo 'Are you sure you want to remove all ignored files in this repo,'
echo 'and reset each submodule to its checked-out state?'
echo 'Press Enter to continue or Ctrl-C to break.'
read -r
git clean -fdX -e '!.venv' -e '!.venv/**'
git submodule foreach --recursive git reset --hard
git submodule foreach --recursive git clean -fdx
