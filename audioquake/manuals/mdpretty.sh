MDFILE=$1
TMPFILE=$1.tmp
pandoc \
	--to markdown \
	--standalone \
	$MDFILE \
	> $TMPFILE \
&& mv -f $TMPFILE $MDFILE
