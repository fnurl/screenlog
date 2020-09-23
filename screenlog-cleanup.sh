#!/usr/bin/env zsh

#if [ "$#" -lt 1 ]; then
#    echo "Remove .jpg files if there exists an .mp4 file in the directory." >&2
#    echo "Unless the size of the .mp4-file is 0, if so, the .mp4 file is removed." >&2
#    echo "Usage: $0 <directory/ies>" >&2
#    exit 1
#fi

# debug=3, info=2, errors=1, silent=0
LOGLEVEL=2


screenlogpath=$HOME/screenlog

logdir=${HOME}/Library/Logs/se.fnurl
mkdir -p ${logdir}

logfile="${logdir}/screenlog.createmovie.log"
touch ${logfile}

function usage() {
    echo "Usage: $(basename ${0}) <directory/ies>"
    echo "Removes .jpg files if there exists an non-zero size .mp4 file in the directory."
    echo "If the size of the .mp4-file is zero, the .mp4 file is removed."
    echo ""
    echo "Also removes empty dirs." 
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

# check if nullglob is on
if [[ $options[nullglob] = "off" ]];then
    turn_off_nullglob=1
    #echo "Turning on nullglob."
    setopt nullglob
else
    turn_off_nullglob=0
fi

echo "Logging to '${logfile}'"

dirs=($@)

# if no params specified, check all subdirs of $screenlogpath
if [[ $# -eq 0 ]]; then
  debugmsg "[DEFAULT PATH] No paths specified. Using '${screenlogpath}'.."
  dirs=${screenlogpath}/*
  dirs=($~dirs)
fi


# $~dirs means explicitly glob the value of the var
for dir in $dirs; do
    if [[ -d $dir ]] && [[ $dir =~ "-" ]]; then
        dir_name=$(basename $dir)

        # was there a movie in $dir?
        found_movie_file=0

        #echo "Checking $dir..."
        jpgs=${dir%/}/*.jpg
        jpgs=($~jpgs)
        movie_file=$dir/$dir_name.mp4
        debugmsg "[DEBUG] jpgs: ${#jpgs}, movie_file: ${movie_file} in ${dir}"

        # can we find a mp4 file? {{{2
        if [[ -f $movie_file ]];then
            found_movie_file=1
            debugmsg "[DEBUG] ${movie_file} found in '${dir}'"

            # is its size zero?
            if ! [[ -s $movie_file ]] ; then
                infomsg "[DELETING] Deleting zero size movie $movie_file..."
                echo "rm -f $movie_file"
                found_movie_file=0
            fi
        fi

        # jpgs found {{{2
        if [[ $#jpgs -gt 0 ]]; then
            # Images can be removed
            if [[ $found_movie_file -eq 1 ]]; then
              infomsg "[REMOVING JPGS] Movie + leftover images in '${dir}'. Removing images."
              rm -f ${dir%/}/*.jpg
            # Movie needs to be made
            else
                infomsg "[MOVIE MISSING] No movie found in '${dir}'."
            fi
        # no jpgs found {{{2
        else
            # Everything is fine
            if [[ $found_movie_file -eq 1 ]]; then
                infomsg "[DIR CLEAN] Movie without leftover image found in '${dir}'."
            # Dir is empty
            else
                infomsg "[DIR EMPTY] Directory '${dir}' is empty. Deleting dir."
                rmdir ${dir}
            fi
        fi  # }}}2
      
        # Images can be removed
        #if [[ $found_movie_file -eq 1 ]] && [[ $found_jpgs -eq 1 ]]; then
        #    infomsg "${dir}: Movie found with leftover image files. Removing images..."
        #        rm ${dir%/}/*.jpg
        #    else
        #        echo "$dir: Movie found without leftover image files. [CLEAN]"
        #    fi
        #else
        #  no_movie_file=1
        #
        #if
        #    echo "$dir: No movie found. [CREATE MOVIE NEEDED]"
        #fi


        # delete dir if empty  (check if listing the dir without the ./ or ../
        # dir is zero)
        #if [[ -z $(ls -A $dir) ]]; then
        #    infomsg "No content found in '${dir}'. Deleting directory."
        #    #rmdir $dir
        #fi
    else
        infomsg "Skipping '${dir}', not a screenlog dir."
    fi
done


# turn off nullglob if the script turned it on
if [[ $turn_off_nullglob -eq 1 ]]; then
    #echo "Turning off nullglob."
    unsetopt nullglob
fi

