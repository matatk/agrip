#!/bin/sh
MAP=$1
AQDIR=../audioquake/dist/AudioQuake.app/Contents/MacOS
cp $MAP.bsp $AQDIR/id1/maps/
cd $AQDIR
./zquake-glsdl -window -width 640 -height 480 +deathmatch 0 +set cl_confirmquit 0 +map $MAP
cd -
