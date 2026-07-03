#!/bin/bash

INPUT_DIR="/home/gabe/Pictures/2026-06-chedward-memories/blog-post/processed"
S3_PREFIX="cheddar"
BUCKET="assets.gabrielmiller.org"
AWS_PROFILE="personal-production"

declare -A FILETYPES
FILETYPES=(
  ["avif"]="image/avif"
  ["gif"]="image/gif"
  ["jpg"]="image/jpeg"
  ["mp4"]="video/mp4"
)

upload_file() {
  FILE=$1

  EXTENSION="${FILE##*.}"
  KEY="$S3_PREFIX/$FILE"
  MIMETYPE=${FILETYPES["$EXTENSION"]}

  RESULT=$(aws s3api put-object --profile "$AWS_PROFILE" --bucket "$BUCKET" --key "$KEY" --body "$INPUT_DIR/$FILE" --content-type "$MIMETYPE" 2>&1)

  if [ "$?" -eq 0 ]
  then
    echo "Published $FILE"
  else
    echo "There was an error publishing $FILE:"
    echo "$RESULT"
    exit $?
  fi
}

for FILE in $(ls "$INPUT_DIR")
do
  upload_file "$FILE"
done