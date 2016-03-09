# About
I use screenlog to take screenshots of my display at regular intervals during the day and then creating a time-lapse movie using the screenshots at the end of the day. **screenlog** consists of three scripts that you can run manually or e.g. schedule via launchd (Mac).

* `screenlog-capture.sh`: Captures a screenshot and resizes it to 768x480 pixels. The screenshot is saved as `/path/to/screenlog/YY-MM-DD/YYMMDD_HHMMSS.jpg`. You have to provide the `/path/to/screenlog` when calling the script.
* `screenlog-create-movie.sh`: Creates a movie of the *screenshots taken yesterday*. The movie is saved as `/path/to/screenlog/YY-MM-DD/YYMMDD.mp4`. You have to provide the `/path/to/screenlog` when calling the script. Use the -d flag to specify a specific date to create the movie for and the -r flag to remove screenshots after the movie has been created (no files will be deleted if movie creation fails).
* `screenlog-process-movie-backlog.sh`: Creates movies in all directories that lack a movie (using `create-screenlog-movie.sh`).

All screenlog source code is licensed under the Apache License 2.0.

# Requirements
* ImageMagick (for convert)
* ghostscript (dependency for convert using fonts)
* ffmpeg
* gnu `date` command, `gdate` (for a more reliable way to get yesterday's date)
* `dspsizes` command which returns the number of attached displays and their sizes.

All requirements except dspsizes can be installed via [Homebrew](http://brew.sh/):

    % brew install ghostscript imagemagick ffmpeg coreutils

Depending on the order you install stuff, you might need to unlink, and then link ghostscript:

    % brew unlink ghostscript
    % brew link ghostscript

# Usage
Set up the paths to `convert` and `ffmpeg` in the scripts.

I use screenlog by setting up launchd to run `screenlog-capture.sh` every 60 seconds. I use [Lingon X](http://www.peterborgapps.com/lingon/) to set up the launch agent. You need to pass the path to your `screenlog` directory as an argument.

I then have `create-screenlog-movie.sh` run at 23:00 every day, also using [Lingon X](http://www.peterborgapps.com/lingon/) to set up the launch agent. Pass the path to your `screenlog` directory as an argument.

# TODO

Use either

- `system_profiler SPDisplaysDataType` or
- `defaults read /Library/Preferences/com.apple.windowserver.plist`

to get number of displays instead of using `dspsizes`.
