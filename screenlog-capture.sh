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


# TODO: if dspsizes says one screen, do existing code. else add files to the list
# of files for screencapture to save to
# then make a big image from all screenshots and resize that

# The command dspsizes outputs multiple lines, so we save each line to an
# element in the array $dspsizes using `dspsizes=($(dspsizes))`
#
# lines are then accessed using:
# ${dspsizes[0]}
# ${dspsizes[1]}
# ${dspsizes[2]}
dspsizes=($(dspsizes))

# Two displays
if [ ${#dspsizes[@]} -eq 3 ]; then
    echo "Capturing two displays.."

    # capture
    screencapture -x -t jpg $logpath/$datetime-large1.jpg $logpath/$datetime-large2.jpg

    echo "Resizing and adding timestamp.."
    # resize both screenshots to same height (480), preserving aspect ratio
    convert $logpath/$datetime-large1.jpg -resize x480\> $logpath/$datetime-h480_1.jpg
    convert $logpath/$datetime-large2.jpg -resize x480\> $logpath/$datetime-h480_2.jpg

    # tile the two screenshots that have the same height
    convert $logpath/$datetime-h480_1.jpg $logpath/$datetime-h480_2.jpg\
            +append $logpath/$datetime-notext.jpg

    # resize tiled image to 768x480 with pillboxing
    mogrify -resize 768x480 -background black -gravity center -extent 768x480\
            -format jpg -quality 75 $logpath/$datetime-notext.jpg
    rm $logpath/$datetime-large1.jpg
    rm $logpath/$datetime-large2.jpg
    rm $logpath/$datetime-h480_1.jpg
    rm $logpath/$datetime-h480_2.jpg

    convert $logpath/$datetime-notext.jpg -fill white -undercolor "#00000080" \
        -gravity South -annotate +0+5 "$prettydatetime" -font "Verdana" \
        -pointsize 64 $logpath/$datetime.jpg
    rm $logpath/$datetime-notext.jpg
    echo "Saved $logpath/$datetime.jpg"

# One display
elif [ ${#dspsizes[@]} -eq 2 ]; then
    echo "Capturing single display.."

    # screenshot
    screencapture -x -t jpg $logpath/$datetime-large.jpg

    echo "Resizing and adding timestamp.."
    # resize screenshot to a 768x480 with pillboxing if needed
    mogrify -resize 768x480 -background black -gravity center -extent 768x480\
            -format jpg -quality 100 $logpath/$datetime-notext.jpg
    rm $logpath/$datetime-large.jpg

    # add time stamp
    convert $logpath/$datetime-notext.jpg -fill white -undercolor "#00000080" \
        -gravity South -annotate +0+5 "$prettydatetime" -font "Verdana" \
        -pointsize 64 $logpath/$datetime.jpg
    rm $logpath/$datetime-notext.jpg
    echo "Saved $logpath/$datetime.jpg"
fi
