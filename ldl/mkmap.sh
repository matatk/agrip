#!/bin/sh
QMDIR=~/.zquake/id1/maps
MAP=$1
CLEAN=$2
if [ $2 ] || [ ! -r $QMDIR/$MAP.bsp ] || [ $(stat -c%Y $MAP.xml) -gt $(stat -c%Y $QMDIR/$MAP.bsp) ] ; then
    ./indmap-down.sh $MAP && ./indmap-build.sh $MAP && ./indmap-test.sh $MAP
else
    ./indmap-test.sh $MAP
fi
