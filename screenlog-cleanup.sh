#!/usr/bin/env zsh

#if [ "$#" -lt 1 ]; then
#    echo "Remove .jpg files if there exists an .mp4 file in the directory." >&2
#    echo "Unless the size of the .mp4-file is 0, if so, the .mp4 file is removed." >&2
#    echo "Usage: $0 <directory/ies>" >&2
#    exit 1
#fi

screenlog_dir=$HOME/screenlog

# check if nullglob is on
if [[ $options[nullglob] = "off" ]];then
    turn_off_nullglob=1
    #echo "Turning on nullglob."
    setopt nullglob
else
    turn_off_nullglob=0
fi

dirs=($@)

# if no params specified, check all subdirs of $screenlog_dir
if [[ $# -eq 0 ]]; then
    dirs=${screenlog_dir}/*
    dirs=($~dirs)
fi


# $~dirs means explicitly glob the value of the var
for dir in $dirs; do
    if [[ -d $dir ]] && [[ $dir =~ "-" ]]; then
        dir_name=$(basename $dir)

        #echo "Checking $dir..."
        jpgs=${dir%/}/*.jpg
        jpgs=($~jpgs)
        movie_file=$dir/$dir_name.mp4
        if [[ -f $movie_file ]];then
            if ! [[ -s $movie_file ]] ; then
                echo "$dir: Deleting zero size movie: $movie_file..."
                rm -f $movie_file
            elif [[ $#jpgs -gt 0 ]]; then
                echo "$dir: Movie found with leftover image files. Removing images..."
                rm ${dir%/}/*.jpg
            else
                echo "$dir: Movie found without leftover image files. [CLEAN]"
            fi
        else
            echo "$dir: No movie found. [CREATE MOVIE NEEDED]"
        fi


        # delete dir if empty  (check if listing the dir without the ./ or ../
        # dir is zero)
        if [[ -z $(ls -A $dir) ]]; then
            echo "$dir: No content found. Deleting directory."
            rmdir $dir
        fi
    else
        echo "Skipping $dir."
    fi
done


# turn off nullglob if the script turned it on
if [[ $turn_off_nullglob -eq 1 ]]; then
    #echo "Turning off nullglob."
    unsetopt nullglob
fi

