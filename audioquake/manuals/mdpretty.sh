function prettify() {
	MDFILE=$1
	TMPFILE=$1.tmp
	echo Prettifying ${MDFILE}...
	pandoc \
		--to markdown \
		--standalone \
		$MDFILE \
		> $TMPFILE \
	&& mv -f $TMPFILE $MDFILE
}

if [[ "$1" == "" ]]; then
	for mdfile in *.md; do
		prettify $mdfile
	done
else
	if [[ -e "$1" ]]; then
		prettify "$1"
	else
		echo "Markdown file '$1' does not exist."
	fi
fi
