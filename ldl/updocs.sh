#!/bin/sh
pod2html ldl.pod > index.html && pod2text ldl.pod > ldl.tutorial && \
cp ldl.tutorial ldl.txt && flip -m ldl.txt && \
cp index.html ldl.tutorial ldl.txt ../simple-web/ldl/tutorial/ && backup for_real && \
rm pod2*tmp index.html
