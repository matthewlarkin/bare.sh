
# ffmpeg

Video and audio manipulation with ffmpeg

## Options

`video-to-mp3`   Convert video to mp3
`video.chunk`   Takes a file as input and separates it into equal chunks
`video.merge`   Merges given chunks into a single file
`video.size`   Converts a video to a specified size

## Examples

# Convert video to mp3
> ffmpeg video-to-mp3 -v video.mp4 -o audio.mp3

# Converts a video to a specified size
> ffmpeg video.size 240 -v video.mp4 -o video.240.mp4

