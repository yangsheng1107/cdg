#!/bin/bash

CDGLIST=$HOME/cdg/listpath

function insertPath() {
    local tmpList=$CDGLIST.tmp
    mv $CDGLIST $tmpList
    echo $PWD >> $tmpList

    # remove duplicates
    awk '!/./ || !seen[$0]++' $tmpList > $CDGLIST
    rm $tmpList

    exit 0
}

function delPath() {
    sed -i "\~$PWD~d" $CDGLIST 
    exit 0
}

function catList() {
    list=`cat $CDGLIST | sed 's/#.*//g'`
    echo -e "$list" | sed '/^\s*$/d'
    exit 0
}

function install() {
cat >> $HOME/.bashrc <<EOF
# Setup cdg function
# ------------------
unalias cdg 2> /dev/null
cdg() {
    if [ -z "$1" ]; then
        local dest_dir=$($HOME/cdg/cdg.sh -l | fzf )
        if [[ $dest_dir != '' ]]; then
            cd "$dest_dir"
        fi
    else
        $HOME/cdg/cdg.sh $1
    fi
}
export -f cdg > /dev/null
EOF

    exit 0
}


function usage() {
    base="${0##*/}"
    echo "Usage: $base [OPTIONS]"
    echo "Options:"
    echo "  -h, --help                   Print this help message"
    echo "  -a, --add                    Add current path"
    echo "  -d, --delete                 Remove current path"
    echo "  -l  --list                   List all path"
    echo "  -I  --install                   Install"
    echo ""
    exit 1
}

# ----------------- main --------------------

OPTS=`getopt -o hadlI --long help,add,delete,list,install -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
#echo "$OPTS"
eval set -- "$OPTS"
while true; do
  case "$1" in
    -h | --help )    usage;   shift ;;
    -a | --add )  insertPath;   shift ;;
    -d | --delete )  delPath;   shift ;;
    -l | --list )    catList;   shift ;;
    -I | --install )    install;   shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done


