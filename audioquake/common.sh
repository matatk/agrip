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
