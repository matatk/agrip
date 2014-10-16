# Note that in /usr/local/Cellar/docbook-xsl/1.78.1/docbook-xsl/xhtml/sections.xsl I changed line 441 to be section level + 2 (was level + 1)

function doit() {
	NAME=$1
	TEMPFILE=${NAME}-from-docbook.temp.html
	HTMLFILE=${NAME}-from-docbook.html
	MDFILE=${NAME}.md
	echo "Converting $NAME to Markdown"
	echo "(DocBook XML --[ XSL ]--> HTML --[ Pandoc ]--> Markdown)..."
	xsltproc \
		--output $TEMPFILE \
		--param generate.toc nop \
		/usr/local/Cellar/docbook-xsl/1.78.1/docbook-xsl/xhtml/docbook.xsl \
		${NAME}.xml \
	&& cat $TEMPFILE | sed -E \
		-e 's/<h3 class="title">Warning<\/h3><p>/<p><strong>Warning:<\/strong>/g' \
		-e 's/<h3 class="title">Note<\/h3><p>/<p><strong>Note:<\/strong>/g' \
		-e 's/<h3 class="title">Tip<\/h3><p>/<p><strong>Tip:<\/strong>/g' \
		-e 's/ class="title"//g' \
		> $HTMLFILE \
	&& rm $TEMPFILE \
	&& pandoc \
		--from html \
		--to markdown \
		--standalone \
		--output $MDFILE \
		$HTMLFILE \
	&& rm $HTMLFILE \
	&& echo Created $MDFILE
}

doit user-manual
echo
doit development-manual
