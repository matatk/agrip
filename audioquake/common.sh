PYGUI="PyGUI-2.5.3"

function get_summat() {
	# Checks for presence of a certain type of file; downloads the
	# default data of the type if need be.  Then removes the download.
	# $1 is the dir to check for and to extract to
	# $2 is the file to check for
	# $3 is the plural name of the type of thing
	# $4 is the messaage about the download
	# $5 is the URL to download
	# $6 is the type ('zip' or 'tar.gz')

	GET_CMD="curl --silent --remote-name $5"

	echo Copying $3 in...
	if [[ ! -d $1 ]] || [[ ! -r $2 ]]; then
		echo "    It appears you don't have $3 in this development tree;"
		echo "    default(s) will now be downloaded."
		[[ "$4" ]] && echo "    $4"
	    echo "    Downloading $5..."
		if [ $6 == 'zip' ]; then
			$GET_CMD && unzip -q $1.zip && rm $1.zip
		elif [ $6 == 'tar.gz' ]; then
			$GET_CMD && tar zxf $1.tar.gz && rm $1.tar.gz
		else
			echo "ERROR: Invalid download type '$6' specified."
		fi
	fi
}

function clean_ds
{
	echo Cleaning Finder clart...
	find . -name ".DS_Store" -exec rm {} \;
}

function chk_dir
{
    if [[ ! -d $1 ]]; then
        echo -n "Couldn't find the directory $1"
        if [[ $2 ]]; then
            echo ", which is needed for $2."
        else
            echo
        fi
        exit 42
    fi
}

function chk_file
{
    if [[ ! -r $1 ]]; then
        echo -n "Couldn't find the directory $1"
        if [[ $2 ]]; then
            echo ", which is needed for $2."
        else
            echo
        fi
        exit 42
    fi
}

function chk_cmd
{
    if [[ ! -x $(which $1) ]]; then
        echo -n "Can't execute the command $1"
        if [[ $2 ]]; then
            echo ", which is needed for $2."
        else
            echo
        fi
        exit 42
    fi
}

function chk_cmd_local
{
    if [[ ! -x $1 ]]; then
        echo -n "Can't execute the command $1"
        if [[ $2 ]]; then
            echo ", which is needed for $2."
        else
            echo
        fi
        exit 42
    fi
}
