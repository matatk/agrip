#!/bin/sh
echo Converting each map...
for mapfile in $(ls *.map | grep -v orig); do
	basename=${mapfile%.*}
	echo $basename
	./indmap-build.sh $basename > /dev/null
	if [ $? != 0 ]; then
		./indmap-build.sh $basename
	fi
	echo
done
