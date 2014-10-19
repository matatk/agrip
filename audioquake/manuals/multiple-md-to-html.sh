function munge() {
	NAME=$1
	HTMLFILE=${NAME}.html
	echo "Converting $NAME (in multiple Markdown files) to HTML..."
	pandoc \
		--to html5 \
		--standalone \
		--smart \
		--table-of-contents \
		--toc-depth 6 \
		--number-sections \
		--css agrip.css \
		--include-in-header in-head.html \
		--output $HTMLFILE \
		${NAME}*.md \
	&& echo Created $HTMLFILE
}

munge user-manual
echo
munge development-manual
open *-manual.html
