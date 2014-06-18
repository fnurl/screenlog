#!/bin/bash

# This script is part of screenlog <http://>
#
# This script creates a movie using todays screenshots. The directory
# for todays screenshots is directory <screenlog path>/YY-MM-DD. Where
# YY-MM-DD is today's date.
#
# The screenlog path is passed to the script as its argument.
#
# Author: Jody Foo <jody.foo@gmail.com>
# Date: 2014-05-22

# default values
date=$(date +%Y-%m-%d)
clear=""

# extract options to variables
while getopts ":d:c" options; do
    case "${options}" in
        d)
            date=$2
            ;;
        c)
            clear=1
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1));

echo "Date set to" $date
echo ARGS: $1

### TODO ###
# * Check number of args

# add path to ffmpeg
PATH=${PATH}:/usr/local/bin

function usage() {
    echo -e "Usage: `basename $0` <path to screenlog dir> [-d YY-MM-DD] [-c]"
    echo -e "Creates a movie of the screencaptures in _todays_ log dir unless"
    echo -e "the -d <YY-MM-DD> option is used."
    echo -e "Using the -c flag deletes the jpgs after the movie has been created."
}

function log() {
    message="`date +%Y-%m-%d\ %H:%M:%S`: $1"
    echo $message
    echo $message >> ~/Library/Logs/se.fnurl.createScreenlogMovie.log
}

logpath=${1%/}/$date
mkdir -p $logpath

echo LOGPATH: $logpath
#exit 0

# check for ffmpeg
if hash ffmpeg 2>/dev/null; then
    log "ffmpeg found, creating movie..."
    ffmpeg -r 15 -pattern_type glob -i "$logpath/*.jpg" -vcodec libx264 $logpath/$date.mp4
    log "screenlog movie $logpath/$date.mp4 created."
    if [ -n "$clear" ]; then
        echo "Deleting source jpgs..."
        rm $logpath/*.jpg
    else
        echo "Keeping source jpgs..."
    fi
else
    log "ffmpeg not found"
    exit 1
fi
