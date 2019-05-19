#!/bin/sh
for bspfile in *.bsp; do
	basename=${bspfile%.*}
	echo $basename
	say $basename
	./indmap-try $basename
done
