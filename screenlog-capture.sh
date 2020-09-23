#!/usr/bin/env zsh -f

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

if [ -f "${HOME}/noscreenlog" ]; then
  exit
fi

if [ $# -ne $EXPECTED_ARGS ]; then
    echo -e "Usage: `basename $0` <path to screenlog dir>\nSaves screenshot to <path to screenlog dir>/YY-MM-DD"
    exit $E_BADARGS
fi

# add path to convert (ImageMagick)
PATH=${PATH}:/usr/local/bin

date=$(date +%Y-%m-%d)
logpath=${1%/}/$date
mkdir -p ${logpath}

datetime=$(date +%Y%m%d\_%H%M%S)
prettydatetime=$(date +%Y-%m-%d\ %H:%M:%S)

width=1024
height=640

# The command dspsizes outputs multiple lines, so we save each line to an
# element in the array $dspsizes using `dspsizes=($(dspsizes))`
#
# lines are then accessed using:
# ${dspsizes[0]}
# ${dspsizes[1]}
# ${dspsizes[2]}
dspsizes=($(dspsizes))

# get length of array (last line is the number of displays)
num_displays=${#dspsizes[@]}
((num_displays-=1))

# set up file names
screencaps=()
for i in {1..$num_displays}; do
    screencaps+=("${logpath}/${datetime}-large${i}.jpg")
done

echo "${datetime}: Capturing screenshots from $num_displays display(s)..."
screencapture -x -t jpg $screencaps

echo "Resizing screencaps to a maximum height of ${height}..."
screencaps=()
for i in {1..$num_displays}; do
    currentfile="${logpath}/${datetime}_${height}_${i}.jpg"
    convert ${logpath}/${datetime}-large${i}.jpg \
            -resize x${height} \
            ${currentfile}
    screencaps+=($currentfile)
done

echo "Creating tiled screenshot..."
# Unfortunately, there is no way of changeing the order of the tiling
# since the order is decided by the display numbering which always sets
# the internal display as display 0
convert ${screencaps} +append ${logpath}/${datetime}-notext.jpg

echo "Resizing tiled screenshot and adding timestamp..."
# resize tiled image to ${width}x${height} with pillboxing
mogrify -resize ${width}x${height} \
        -background black \
        -gravity center -extent ${width}x${height} \
        -format jpg \
        -quality 75 ${logpath}/${datetime}-notext.jpg
# add time stamp
convert ${logpath}/${datetime}-notext.jpg \
    -fill "#44444488" -draw 'rectangle 0,585,1024,635' \
    -fill white -gravity South -font Helvetica-Bold -pointsize 32 \
    -annotate +0+10 "${prettydatetime}" \
    ${logpath}/${datetime}.jpg
echo "${datetime}: Saved ${logpath}/${datetime}.jpg"

# remove tmp files
echo "Deleting tmp files..."
rm -f ${logpath}/${datetime}-large?.jpg
rm -f ${logpath}/${datetime}_${height}_?.jpg
rm -f ${logpath}/${datetime}-notext.jpg
