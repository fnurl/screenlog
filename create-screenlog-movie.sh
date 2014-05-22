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

EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
    echo -e "Usage: `basename $0` <path to screenlog dir>\nCreates a movie of the screencaptures in _todays_ log dir."
    exit $E_BADARGS
fi

# add path to ffmpeg
PATH=${PATH}:/usr/local/bin

function log() {
    message="`date +%Y-%m-%d\ %H:%M:%S`: $1"
    echo $message
    echo $message >> ~/Library/Logs/se.fnurl.createScreenlogMovie.log
}

date=$(date +%Y-%m-%d)
logpath=${1%/}/$date
mkdir -p $logpath

# check for ffmpeg
if hash ffmpeg 2>/dev/null; then
    log "ffmpeg found, creating movie..."
    ffmpeg -r 15 -pattern_type glob -i "$logpath/*.jpg" -vcodec libx264 $logpath/$date.mp4
    log "screenlog movie $logpath/$date.mp4 created."
else
    log "ffmpeg not found"
    exit 1
fi
