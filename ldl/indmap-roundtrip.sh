#!/bin/sh
MAP=$1
if [[ ! -r $MAP.map ]]; then
    echo "ERROR: Can't find $MAP.map!"
    exit 42
fi
echo "sending the map to mapxml... "
echo "00 "
cat $MAP.map	| ./00-u-map2mapxml.py > $MAP.00.xml && \
echo 01 && \
cat $MAP.00.xml | ./01-u-brushsizes.py > $MAP.01.xml && \
echo "sending the mapxml back to a map... " && \
echo "01 " && \
cat $MAP.01.xml | ./01-d-brushsizes.py > $MAP.00.xml && \
echo 00 && \
cat $MAP.00.xml | ./00-d-map2mapxml.py > ${MAP}_rt.map
# NOTE: we use ``_rt'' as a suffix to the name so that we don't overwrite the original map.  We use the underscore specifically because if we used a hyphen, ZQuake would interpret this as part of a commandline argument.
