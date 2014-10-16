function filter() {
	NAME=$1
	HTMLFILE=${NAME}.html
	echo "Filtering Part and Chapter mentions"
	echo "from $NAME's multiple Markdown files..."
	for mdfile in ${NAME}-part*.md; do
		tmpfile=${mdfile}.tmp
		cat $mdfile | sed -E -e 's/^(Part|Chapter|Appendix).+\.[[:space:]]//' \
			> $tmpfile \
		&& mv $tmpfile $mdfile \
		&& ./mdpretty.sh $mdfile
	done
}

filter user-manual
echo
filter development-manual
