#!/bin/sh
# The "*-orig.map" files came from a run of the LDL code before the move to
# Python 3. This script checks the sizes of BSP files created from those maps
# and ones freshly converted from XML.
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
if [ $mismatched_count -eq 0 ]; then
	echo no maps differ in size -- test successful
else
	echo "$mismatched_count map(s) differ in size -- test failed"
fi
exit $mismatched_count
