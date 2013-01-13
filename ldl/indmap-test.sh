#!/bin/sh
MAP=$1
QPATH=~/.zquake
MPATH=$QPATH/id1/maps
if [ ! -r $MPATH/$MAP.bsp ]; then
    echo "$MPATH/$MAP.bsp doesn't exist!"
    exit 42
fi
cd $QPATH
./start.pl rawlaunch -width 640 -height 480 +deathmatch 0 +set cl_confirmquit 0 +map $MAP
cd -
