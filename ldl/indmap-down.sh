#!/bin/sh
MAP=$1
if [ ! -r $MAP.xml ]; then
    echo "ERROR: Can't find $MAP.xml!"
    exit 42
fi
echo converting the mapxml to a map...
cat $MAP.xml			| ./05-d-3dconlevel.py > ${MAP}_level04.xml && \
cat ${MAP}_level04.xml	| ./04-d-buildermac.py > ${MAP}_level03.xml && \
cat ${MAP}_level03.xml	| ./03-d-lightingst.py > ${MAP}_level02.xml && \
cat ${MAP}_level02.xml	| ./02-d-roomsnstuf.py > ${MAP}_level01.xml && \
cat ${MAP}_level01.xml	| ./01-d-brushsizes.py > ${MAP}_level00.xml && \
cat ${MAP}_level00.xml	| ./00-d-map2mapxml.py > $MAP.map && \
echo removing intermediate files... && \
rm ${MAP}_level*xml
