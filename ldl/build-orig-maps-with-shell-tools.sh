#!/bin/sh
for orig in *-orig.map; do
	echo $orig
	./indmap-build.sh ${orig%.*} > /dev/null
done
