#!/bin/sh
MAP=$1
WAD=quake.wad

if [ -x ./qbsp ]; then
	QBSP="`pwd`/qbsp"
else
	QBSP='qbsp'
fi
if [ -x ./light ]; then
	LIGHT="`pwd`/light"
else
	LIGHT='light'
fi
if [ -x ./vis ]; then
	VIS="`pwd`/vis"
else
	VIS='vis'
fi

if [ ! -r $MAP.map ]; then
    echo "ERROR: Can't find $MAP.map!"
    exit 42
fi

echo Running BSP...
$QBSP $MAP > /dev/null
if [ $? != 0 ]; then
	$QBSP $MAP
	exit 42
fi

echo Running $LIGHT...
$LIGHT -extra $MAP > /dev/null
if [ $? != 0 ]; then
	$LIGHT -extra $MAP
	exit 42
fi

echo Running $VIS...
$VIS -level 4 $MAP > /dev/null
if [ $? != 0 ]; then
	$VIS -level 4 $MAP
	exit 42
fi

echo Cleaning up...
rm -fv $MAP.h* $MAP.prt $MAP.lit $MAP.pts $MAP.map

# NOTE: .bsp is already in $QMAPPATH dir (as are we).

exit 0
