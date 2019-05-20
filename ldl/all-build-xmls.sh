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
	./indmap-down.sh $basename > /dev/null

	./indmap-build.sh $basename > /dev/null
	if [ $? != 0 ] && [ $basename != 'tut03_invalid' ]; then
		./indmap-build.sh $basename
		exit 42
	fi

	rm -f $basename.map
	echo
done
