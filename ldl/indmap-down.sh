#!/bin/sh
MAP=$1
if [ ! -r $MAP.xml ]; then
	echo "ERROR: Can't find $MAP.xml!"
	exit 42
fi
if [ $MAP != 'test_04_roomsnstuff' ]; then
	echo converting the mapxml to a map...
	cat $MAP.xml			| ./level_05_down_connections.py > ${MAP}_level04.xml && \
	cat ${MAP}_level04.xml	| ./level_04_down_buildermacros.py > ${MAP}_level03.xml && \
	cat ${MAP}_level03.xml	| ./level_03_down_lighting.py > ${MAP}_level02.xml && \
	cat ${MAP}_level02.xml	| ./level_02_down_rooms.py > ${MAP}_level01.xml && \
	cat ${MAP}_level01.xml	| ./level_01_down_brushsizes.py > ${MAP}_level00.xml && \
	cat ${MAP}_level00.xml	| ./level_00_down_map2mapxml.py > $MAP.map
else
	cat $MAP.xml           | ./level_04_down_buildermacros.py > ${MAP}_level03.xml && \
	cat ${MAP}_level03.xml | ./level_03_down_lighting.py > ${MAP}_level02.xml && \
	cat ${MAP}_level02.xml | ./level_02_down_rooms.py > ${MAP}_level01.xml && \
	cat ${MAP}_level01.xml | ./level_01_down_brushsizes.py > ${MAP}_level00.xml && \
	cat ${MAP}_level00.xml | ./level_00_down_map2mapxml.py > $MAP.map
fi
#echo removing intermediate files...
#rm ${MAP}_level*xml
