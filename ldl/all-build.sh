#!/bin/sh
echo Cleaning up...
rm -f *_level0*.xml

echo Converting each map...
for xmlfile in *.xml; do
	if [ $xmlfile == 'style.xml' ]; then
		continue
	fi

	basename=${xmlfile%.*}
	echo $basename

	if [ $basename != 'test_04_roomsnstuff' ]; then
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
	fi

	./indmap-build.sh $basename > /dev/null
	if [ $? != 0 ] && [ $basename != 'tut03_invalid' ]; then
		./indmap-build.sh $basename
		exit 42
	fi

	rm -f $basename.map
	echo
done
