#!/bin/sh
MAP=$1
WAD=quake.wad
BINS='q1tools_gpl.qutils/qbsp'
QBSP="$BINS/qbsp"
LIGHT="$BINS/light"
VIS="$BINS/vis"
BSPINFO="$BINS/bspinfo"

if [ ! -r $MAP.map ]; then
    echo "ERROR: Can't find $MAP.map!"
    exit 42
fi

echo Running qbsp...
$QBSP $MAP > /dev/null
if [ $? != 0 ]; then
	$QBSP $MAP
	exit 42
fi

echo Running light...
$LIGHT -extra $MAP > /dev/null
if [ $? != 0 ]; then
	$LIGHT -extra $MAP
	exit 42
fi

echo Running vis...
$VIS -level 4 $MAP > /dev/null
if [ $? != 0 ]; then
	$VIS -level 4 $MAP
	exit 42
fi

echo Running bspinfo...
$BSPINFO $MAP

echo Cleaning up...
rm -f $MAP.h* $MAP.prt $MAP.lit $MAP.pts

# NOTE: .bsp is already in $QMAPPATH dir (as are we).

exit 0
