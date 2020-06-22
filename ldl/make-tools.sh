#!/bin/sh
cd q1tools_gpl.qutils/qbsp || exit 42
make
cd - /dev/null || exit 42
if [ ! -d bin ]; then
	mkdir bin || exit 42
fi
cp -v \
	q1tools_gpl.qutils/qbsp/qbsp \
	q1tools_gpl.qutils/qbsp/vis \
	q1tools_gpl.qutils/qbsp/light \
	q1tools_gpl.qutils/qbsp/bspinfo \
	bin/
