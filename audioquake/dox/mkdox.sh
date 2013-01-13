#!/bin/bash
rm -rf doxygen/
cp -a ../zq-repo/qc/agrip/ .
find -name '*.qc' | xargs ./mungeqc.pl && doxygen qc.doxygen.conf
rm -rf agrip/
