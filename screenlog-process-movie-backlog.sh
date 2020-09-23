#!/bin/bash

EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]; then
    echo "Usage: `basename $0` <path to screenlog day dir>"
    echo "Creates screenlog movies if they do not exist. Todays screenlog day dir will be ignored."
    echo ""
    echo "Examples:"
    echo "  $(basename ${0}) ~/screenlog/2017/"
    echo "  $(basename ${0}) ~/screenlog/2017/2017-01-01"
    exit $E_BADARGS
fi

logpath=${1%/}

for dir in $logpath/*/
do
    dir_noslash=${dir%*/}
    dir_name=${dir_noslash##*/}
    if [[ $dir_name != $(date "+%Y-%m-%d") ]]; then
        #echo raw: $dir, noslash: $dir_noslash, name: $dir_name
        echo "Checking for $dir_noslash/$dir_name.mp4..."
        if [ ! -f $dir_noslash/$dir_name.mp4 ]; then
            echo -e "\n## Movie missing for $dir_name, creating..."
            screenlog-create-movie.sh -d $dir_name -r $logpath
        fi
    else
        echo -e "\n## Skipping dir: $dir_noslash"
    fi
done
