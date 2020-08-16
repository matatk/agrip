#!/bin/sh
# Build both the "*-orig.map" files from the pre-Python 3 version of the LDL
# code as well as freshly converting and building directly from XML files, then
# compare the sizes of the resultant BSPs.
./ldl.py build -- \
	first_20080427_1353.xml \
	test_05_*.xml tut*.xml \
	reference-maps/*-orig.map \
	|| exit 42  # TODO doesn't actually exit on error

# Now check the sizes
mismatched_count=0
for bsp in *.bsp; do
	orig=reference-maps/${bsp%.*}-orig.bsp
	if [ -r "$orig" ]; then
		origsize=$(stat -f %z "$orig")
		bspsize=$(stat -f %z "$bsp")
		if [ "$origsize" != "$bspsize" ]; then
			echo "DIFF: $orig ($origsize), $bsp ($bspsize)"
			mismatched_count=$((mismatched_count + 1))
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
