# About
screenlog consists of two scripts made to be run via launchd (Mac).

The first script, `screenlog-capture.sh`, captures a screenshot and resizes it to 768x480 pixels. The screenshot is saved as `/path/to/screenlog/YY-MM-DD/YYMMDD_HHMMSS.jpg`. You have to provide the `/path/to/screenlog` when calling the script.

The second script, `create-screenlog-movie.sh`, creates a movie of the *screenshots for today*. The movie is saved as `/path/to/screenlog/YY-MM-DD/YYMMDD.mp4`. You have to provide the `/path/to/screenlog` when calling the script.

# Requirements
* convert (ImageMagick)
* ffmpeg

# Usage
Set up the paths to `convert` and `ffmpeg` in the scripts.

I use screenlog by setting up launchd to run screenlog-capture.sh every 45 seconds. I use Lingon X to set up the launch agent. You need to pass the path to your `screenlog` directory as argument.

I then have create-screenlog-movie.sh run at 23:00 every day, also using Lingon X to set up the launch agent. You need to pass the path to your `screenlog` directory as argument.
