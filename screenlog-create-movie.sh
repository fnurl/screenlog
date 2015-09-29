#!/bin/bash

# This script is part of screenlog <https://github.com/fnurl/screenlog>
#
# This script creates a movie using todays screenshots. The directory
# for todays screenshots is directory <screenlog path>/YYYY-MM-DD. Where
# YY-MM-DD is today's date.
#
# The screenlog path is passed to the script as its argument. Use the -d option
# select another date than today.
#
# Use the -r flag to remove the jpegs after creating the movie.
#
# Author: Jody Foo <jody.foo@gmail.com>
# Date: 2014-07-11

# EDIT THIS LINE SO IT POINTS TO ffmpeg ON YOUR SYSTEM
PATH=${PATH}:/usr/local/bin

function usage() {
    echo "Usage: `basename $0` [-d YYYY-MM-DD] [-r] <path to screenlog dir>"
    echo "Create a movie of the screencaptures in _yesterday's_ log dir unless the -d is used."
    echo ""
    echo "    -d <YYYY-MM-DD>  create movie for a specific date"
    echo "    -r deletes the jpgs after the movie has been created"
}

function log() {
    message="`date +%Y-%m-%d\ %H:%M:%S`: $1"
    echo $message
    echo $message >> ~/Library/Logs/se.fnurl.screenlog.createMovie.log
}

# default values
date=$(gdate -d "yesterday 13:00" "+%Y-%m-%d")
remove=""

# extract options to variables
while getopts ":d:r" options; do
    case "${options}" in
        d)
            date=$2
            ;;
        r)
            remove=1
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1));

# After processing flags and options, check for required arguments.
EXPECTED_ARGS=1
E_BADARGS=65
if [ $# -ne $EXPECTED_ARGS ]
then
  usage
  exit $E_BADARGS
fi

echo "Processing screenlog for" $date"..."
#echo ARGS: $1

# Remove trailing / from path if it exists and append date to logpath
logpath=${1%/}/$date
mkdir -p $logpath
echo LOGPATH: $logpath

# check for ffmpeg
if hash ffmpeg 2>/dev/null; then
    log "ffmpeg found, creating movie..."
    ffmpeg -r 15 -pattern_type glob -i "$logpath/*.jpg" -vcodec libx264 $logpath/$date.mp4
    
    # if movie created
    if [ $? -eq 0 ]; then
        log "screenlog movie $logpath/$date.mp4 created."
        if [ -n "$remove" ]; then
            echo "Deleting source jpgs ($logpath/*.jpg)..."
            rm $logpath/*.jpg
        else
            echo "Keeping source jpgs..."
        fi
    else
        log "ERROR: Failed to create movie. Not deleting any source jpgs."
    fi
else
    log "ERROR: ffmpeg not found"
    exit 1
fi
