#!/bin/bash

INPUT_DIRS=(
  # newline delimited absolute paths to directories that contain images
  "/home/gabe/Pictures/2026-06-chedward-memories/blog-post/raw"
  "/home/gabe/Pictures/2026-06-chedward-memories/blog-post/raw_catsnugs"
  "/home/gabe/Pictures/2026-06-chedward-memories/blog-post/raw_peoplesnugs"
)

OUTPUT_DIR="/home/gabe/Pictures/2026-06-chedward-memories/blog-post/processed"


process_image() {
  INPUT_DIR=$1
  FILE=$2

  EXTENSION="${FILE##*.}"
  FILENAME="${FILE%.*}"
  case "$EXTENSION" in
    "mp4"|"gif")
      PROCESS_IMAGE="n"
      PROCESS_VIDEO="n"
      COPY="y"
    ;;
    "jpg"|"heic"|"heif")
      PROCESS_IMAGE="y"
      PROCESS_VIDEO="n"
      COPY="n"
    ;;
    "mov")
      PROCESS_IMAGE="n"
      PROCESS_VIDEO="y"
      COPY="n"
    ;;
    *)
      echo "$FILE has invalid extension."
      exit 1
    ;;
  esac

  if [ "$PROCESS_IMAGE" == "y" ]
  then
    echo "processing image $FILE"

    magick "$INPUT_DIR/$FILE" -strip "$OUTPUT_DIR/$FILENAME"_original.jpg
    magick "$INPUT_DIR/$FILE" -strip -quality 90% -resize 1920x1920\> "$OUTPUT_DIR/$FILENAME"_web.avif
  fi

  if [ "$PROCESS_VIDEO" == "y" ]
  then
    echo "processing video $FILE"

    # strip audio and re-encode in h.265
    ffmpeg -i "$INPUT_DIR/$FILE" -c:v libx265 -crf 26 -preset slow -an "$OUTPUT_DIR/$FILENAME".mp4
  fi

  if [ "$COPY" == "y" ]
  then
    echo "copying file $FILE"
    cp "$INPUT_DIR/$FILE" "$OUTPUT_DIR/$FILE"
  fi
}

if [ -z "$INPUT_DIRS" ]
then
  echo "No input dirs specified."
  exit 1
fi

if [ -z "$OUTPUT_DIR" ]
then
  echo "No output dir specified."
  exit 1
fi

for directory in "${INPUT_DIRS[@]}"
do
  for file in $(ls "$directory")
  do
    process_image "$directory" "$file"
  done
done