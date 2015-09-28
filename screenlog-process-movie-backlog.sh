#!/bin/bash

EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]; then
    echo -e "Usage: `basename $0` <path to screenlog dir>\nCreates screenlog movies if they do not exist."
    exit $E_BADARGS
fi

logpath=${1%/}

for dir in $logpath/*/
do
    dir_noslash=${dir%*/}
    dir_name=${dir_noslash##*/}
    #echo raw: $dir, noslash: $dir_noslash, name: $dir_name
    #echo "Checking if $dir_noslash/$dir_name.mp4 exists.."
    if [ ! -f $dir_noslash/$dir_name.mp4 ]; then
        echo "Movie missing for $dir_name, creating..."
        create-screenlog-movie.sh -d $dir_name -r /Users/jodfo01/screenlog        
    fi
done
