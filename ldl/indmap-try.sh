#!/bin/sh
MAP=$1
AQDIR=../audioquake/dist/AudioQuake.app/Contents/MacOS
if [ ! -r $MAP.bsp ]; then
	./indmap-build.sh $MAP
fi
cp $MAP.bsp $AQDIR/id1/maps/
cd $AQDIR
echo ./zquake-glsdl -window -width 640 -height 480 +deathmatch 0 +set cl_confirmquit 0 +map $MAP
./zquake-glsdl -window -width 640 -height 480 +deathmatch 0 +set cl_confirmquit 0 +map $MAP > /dev/null
cd -
