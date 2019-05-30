#!/bin/sh
for bsp in *.bsp; do
	orig=${bsp%.*}-orig.bsp
	if [ -r $orig ]; then
		origsize=$(stat -f %z $orig)
		bspsize=$(stat -f %z $bsp)
		if [ $origsize != $bspsize ]; then
			echo $orig $bsp are different sizes!
		fi
	fi
done
