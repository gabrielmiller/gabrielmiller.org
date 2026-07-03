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
    "gif"|"mp4")
      PROCESS="n"
      COPY="y"
    ;;
    "jpg")
      PROCESS="y"
      COPY="n"
    ;;
    *)
      echo "$FILE has invalid extension."
      exit 1
    ;;
  esac

  if [ "$PROCESS" == "y" ]
  then
    echo "processing $FILE"

    magick "$INPUT_DIR/$FILE" -strip "$OUTPUT_DIR/$FILENAME"_original.jpg
    magick "$INPUT_DIR/$FILE" -strip -quality 90% -resize 1920x1920\> "$OUTPUT_DIR/$FILENAME"_web.avif
  fi

  if [ "$COPY" == "y" ]
  then
    echo "copying $FILE"
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