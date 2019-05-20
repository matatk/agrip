#!/bin/sh
for bsp in *.bsp; do
	orig=${bsp%.*}-orig.bsp
	if [ -r $orig ]; then
		echo $orig $bsp
		diff $orig $bsp
	fi
done
