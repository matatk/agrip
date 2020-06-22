#!/bin/sh
pandoc \
	--standalone  \
	--toc \
	--metadata pagetitle="LDL Concept Release Tutorial" \
	< ldl-tutorial.md \
	> ldl-tutorial.html
