#!/bin/sh
echo 'Are you sure you want to remove ALL non-tracked files, and reset each'
echo 'submodule (but not the main repo) to its checked-out state?'
echo 'Press Enter to continue or Ctrl-C to break.'
read -r
git clean -fdx
git submodule foreach --recursive git reset --hard
git submodule foreach --recursive git clean -fdx
