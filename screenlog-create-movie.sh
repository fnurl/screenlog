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
# Date: 2014-07-11, 2018-03-13

# EDIT THIS LINE SO IT POINTS TO ffmpeg ON YOUR SYSTEM
PATH=${PATH}:/usr/local/bin

# debug=3, info=2, errors=1, silent=0
LOGLEVEL=2

logdir=${HOME}/Library/Logs/se.fnurl
mkdir -p ${logdir}

logfile="${logdir}/screenlog.createmovie.log"
touch ${logfile}

ffmpeglogfile="${logdir}/screenlog.ffmpeg.log"

function usage() {
    echo "Usage: `basename $0` [-d YYYY-MM-DD] [-r] <path to screenlog dir>"
    echo "Create a movie of the screencaptures in _yesterday's_ log dir unless the -d is used."
    echo ""
    echo "    -d <YYYY-MM-DD>  create movie for a specific date"
    echo "    -r deletes the jpgs after the movie has been created"
}

# https://stackoverflow.com/questions/2342826/how-to-pipe-stderr-and-not-stdout
# use syslog util for log messages, print to stderr and save to file

# error message level=1
function errmsg() {
  if [[ $LOGLEVEL -ge 1 ]]; then
    #echo "$(date +%Y-%m-%d\ %H:%M:%S): $1" | tee -a ${logfile}
    logger -s -t screenlog -p local3.err $1 2>&1 | tee -a ${logfile}
  fi
}

# infomessage level=2
function infomsg() {
  if [[ $LOGLEVEL -ge 2 ]];then 
    #echo "$(date +%Y-%m-%d\ %H:%M:%S): $1" | tee -a ${logfile}
    logger -s -t screenlog -p local3.info $1 2>&1 | tee -a ${logfile}
  fi
}

# debug message level=3 (not saved to log file)
function debugmsg() {
  if [[ $LOGLEVEL -ge 3 ]]; then
    logger -s -t screenlog -p local3.debug $1
  fi
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

infomsg "Processing screenlog for ${date}..."
#echo ARGS: $1

# Remove trailing / from path if it exists and append date to screenlogpath
screenlogpath="${1%/}/${date}"
mkdir -p ${screenlogpath}
infomsg "screenlogpath: ${screenlogpath}"

# check for ffmpeg
if hash ffmpeg 2>/dev/null; then
    #infomsg "ffmpeg found, creating movie..."
    ffmpeg -r 15 \
           -pattern_type glob \
           -i "$screenlogpath/*.jpg" \
           -vcodec libx264 $screenlogpath/$date.mp4 \
           2>> ${ffmpeglogfile}
    
    # if movie created (return code 0
    if [ $? -eq 0 ]; then
        infomsg "screenlog movie $screenlogpath/$date.mp4 created."
        if [ -n "$remove" ]; then
            infomsg "Deleting source jpgs (${screenlogpath}/*.jpg)..."
            rm $screenlogpath/*.jpg
        else
            infomsg "Keeping source jpgs..."
        fi
    else
        errmsg "ERROR: Failed to create movie for ${date}. Not deleting any source jpgs."
        exit $?
    fi
else
    errmsg "ERROR: ffmpeg not found"
    exit 1
fi
