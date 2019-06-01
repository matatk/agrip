#!/bin/sh
mismatched_count=0
for bsp in *.bsp; do
	orig=${bsp%.*}-orig.bsp
	if [ -r $orig ]; then
		origsize=$(stat -f %z $orig)
		bspsize=$(stat -f %z $bsp)
		if [ $origsize != $bspsize ]; then
			echo "DIFF: $orig ($origsize), $bsp ($bspsize)"
			mismatched_count=$(($mismatched_count + 1))
		else
			echo "  ok: $orig, $bsp"
		fi
	fi
done
echo $mismatched_count maps differ in size
exit $mismatched_count
