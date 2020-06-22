#!/bin/sh
hr() {
	echo
	echo
	echo ================================================================================
	echo
	echo
}

hr &&
./ldl.py --help && hr &&
./ldl.py convert --help && hr &&
./ldl.py build --help && hr &&
./ldl.py play --help && hr &&
./ldl.py roundtrip --help && hr
