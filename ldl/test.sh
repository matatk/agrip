#!/bin/sh
# Build both the "*-orig.map" files from the pre-Python 3 version of the LDL
# code as well as freshly converting and building directly from XML files, then
# compare the sizes of the resultant BSPs.
./ldl.py build *.xml *-orig.map && ./compare-orig-new-bsp-sizes.sh
