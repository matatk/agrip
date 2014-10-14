function munge() {
	NAME=$1
	pandoc \
		--to html5 \
		--standalone \
		--smart \
		--table-of-contents \
		--toc-depth 6 \
		${NAME}.md \
		--output ${NAME}.html \
	&& open ${NAME}.html
}

munge user-manual
munge development-manual
