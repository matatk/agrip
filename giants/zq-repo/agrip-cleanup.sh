#!/bin/sh
echo "Running the distclean target of the Makefile..."
echo "  for zquake"
cd zquake
make distclean > /dev/null 2> /dev/null
cd - > /dev/null
echo "  for zqcc"
cd zqcc
make distclean > /dev/null 2> /dev/null
cd - > /dev/null
echo "Finding .dat files and removing from qc..."
cd qc
find . -iname '*.dat' -exec rm {} \;
