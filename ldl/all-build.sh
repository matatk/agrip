#!/bin/sh
echo Cleaning up...
rm -f *_level0*.xml
echo Converting each map...
for xmlfile in *.xml; do
	if [[ $xmlfile != 'style.xml' ]]; then
		basename=${xmlfile%.*}
		echo $basename
		if [[ $basename != 'test_04_roomsnstuff' ]]; then
			./indmap-down.sh $basename > /dev/null
		else
			# FIXME this is a bit !DRY
			MAP=$basename

			cat $MAP.xml           | ./04-d-buildermac.py > ${MAP}_level03.xml && \
			cat ${MAP}_level03.xml | ./03-d-lightingst.py > ${MAP}_level02.xml && \
			cat ${MAP}_level02.xml | ./02-d-roomsnstuf.py > ${MAP}_level01.xml && \
			cat ${MAP}_level01.xml | ./01-d-brushsizes.py > ${MAP}_level00.xml && \
			cat ${MAP}_level00.xml | ./00-d-map2mapxml.py > $MAP.map

			rm -f ${MAP}_level*xml

			./indmap-build.sh $MAP > /dev/null
		fi
		rm -f $basename.map
		echo
	fi
done
