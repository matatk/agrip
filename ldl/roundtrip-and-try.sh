#!/bin/sh
base=$1
if [ ! -r $base.map ] && [ -r $base.xml ]; then
	./indmap-down.sh $base
fi
./indmap-roundtrip.sh $base && ./indmap-try.sh ${base}_rt
