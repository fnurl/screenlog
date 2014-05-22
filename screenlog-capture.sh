#!/bin/bash

# This script is part of screenlog <http://>
#
# This script captures a screenshot and saves it to <screenlog path>/YY-MM-DD.
# Where YY-MM-DD is today's date. The screenlog path is passed to the script
# as its argument.
#
# Author: Jody Foo <jody.foo@gmail.com>
# Date: 2014-05-22

EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]; then
    echo -e "Usage: `basename $0` <path to screenlog dir>\nSaves screenshot to <path to screenlog dir>/YY-MM-DD"
    exit $E_BADARGS
fi

# add path to convert (ImageMagick)
PATH=${PATH}:/usr/local/bin

date=$(date +%Y-%m-%d)
logpath=${1%/}/$date
mkdir -p $logpath

datetime=$(date +%Y%m%d\_%H%M%S)
prettydatetime=$(date +%Y-%m-%d\ %H:%M:%S)

#/usr/sbin/screencapture -x -t jpg $logpath/$datetime-large.jpg
screencapture -x -t jpg $logpath/$datetime-large.jpg
convert $logpath/$datetime-large.jpg -resize 768x480\> $logpath/$datetime-notext.jpg
rm $logpath/$datetime-large.jpg

convert $logpath/$datetime-notext.jpg -fill white -undercolor "#00000080" \
    -gravity South -annotate +0+5 "$prettydatetime" -font "Verdana" \
    -pointsize 64 $logpath/$datetime.jpg
rm $logpath/$datetime-notext.jpg
echo "Saved $logpath/$datetime.jpg"
