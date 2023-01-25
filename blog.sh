#!/bin/bash

GBLOG_ENVIRONMENT="staging"

validate_go_dependency() {
  if ! command -v go &> /dev/null
  then
    echo "Go dependency could not be found. You should install go1.19.5 linux/amd64 before proceeding."
    exit 1
  fi

  GOVERSION=$(go version)
  if [ "$GOVERSION" != "go version go1.19.5 linux/amd64" ]
  then
    echo "Using untested go version. This has only been tested with 1.19.5 linux/amd64."
  fi
}

dev() {
  validate_go_dependency
  cd backend && \
  while read line; do
    eval $line
  done < "$GBLOG_ENVFILE" && \
  go build . && \
  echo "[$(date +%T)] Blog API listening on port $PORT" && ./blog
}

staging() {
  cd stories && \
  while read line; do
    eval $line
  done < "$GBLOG_ENVFILE"

  # 1. Loop through local directories
  #     - validate there's an index.json file. exit 1 on fail
  #     - validate files have allowed extensions. exit 1 on fail
  # 2. Delete everything from the bucket
  # 3. Loop through local directories and upload to s3

  for directory in $(ls -d */)
  do
    indexFile="$directory""index.json"
    if [ ! -f $indexFile ]
    then
      echo "No index file found in stories/$directory. You must create one to proceed."
      exit 1
    else
      for file in $(ls $directory)
      do
        if [ "$file" == "index.json" ]
        then
          continue
        fi

        EXTENSION=$(echo $file | cut -d "." -f 2)

        case "$EXTENSION" in
          "gif"|"jpg")
            continue
          ;;
          *)
            echo "$file has invalid extension. Valid options: .gif, .jpg"
            exit 1
          ;;
        esac
      done
    fi
  done

  result=$(aws s3 rm s3://"$S3_BUCKET_NAME" --recursive)

  declare -A filetypes
  filetypes=(
    ["gif"]="image/gif"
    ["jpg"]="image/jpeg"
    ["json"]="application/json"
  )

  for directory in $(ls -d */)
  do
    echo "Uploading $directory"
    for file in $(ls $directory)
    do
      filename="${file##*/}"
      extension="${filename##*.}"
      mimetype=${filetypes["$extension"]}
      result=$(aws s3api put-object --bucket "$S3_BUCKET_NAME" --key "$directory$file" --body "$directory$file" --content-type "$mimetype" 2>&1)

    if [ "$?" -eq 0 ]
    then
      echo "Published $directory$file"
    else
      echo "There was an error publishing $file:"
      echo "$result"
      exit $?
    fi
    done
  done

  # deploy api
  # - big ole TBD
  #
  # deploy static files
  # - tap into a frontend build process
  # - deploy the resulting dist files + any other stuff
}

prod() {
  echo "TODO: prod stuff"
}

generate_index() {
  STORY_DIRECTORY="./stories/$GBLOG_STORYNAME"
  if [ ! -d "$STORY_DIRECTORY" ]
  then
    echo "No directory exists for story $GBLOG_STORYNAME. You should first create the directory and place all desired media files in it."
    exit 1
  fi

  GBLOG_INDEX_FILE="$STORY_DIRECTORY/index.json"
  SHOULD_PROCEED="y"
  if [ -f "$GBLOG_INDEX_FILE" ]
  then
    echo "Index file already exists. If you proceed it will be rewritten. Do you wish to proceed? y/N"
    read SHOULD_PROCEED
  fi

  if [ "$SHOULD_PROCEED" != "y" ]
  then
    exit 0
  fi

  INDEX_ENTRIES=""
  cd $STORY_DIRECTORY
  for f in *
  do
    if [ "$f" == "index.json" ]
    then
      continue
    fi

    EXTENSION=$(echo $f | cut -d "." -f 2)

    case "$EXTENSION" in
      "gif"|"jpg")
        INDEX_ENTRIES="$INDEX_ENTRIES,{\"metadata\":{},\"filename\":\"$f\"}"
      ;;
      *)
        echo "$f has invalid extension. Valid options: .gif, .jpg"
        exit 1
      ;;
    esac
  done
  INDEX_ENTRIES_LENGTH=$(echo $INDEX_ENTRIES | wc -m)
  CLEANED_INDEX_ENTRIES=$(echo $INDEX_ENTRIES | cut -c 2-$INDEX_ENTRIES_LENGTH)
  INDEX="{\"accessToken\":\"\",\"metadata\": {}, \"entries\": [$CLEANED_INDEX_ENTRIES]}"
  echo -n $INDEX > index.json
  echo "Index generated."
}

show_help() {
cat << EOF

Usage: blog.sh [-o -h]

Do the blog thing.

    -o, --operation
        Operation to perform.

        Options:
          1: build and run development backend environment
          2. build and deploy to staging
          3. build and deploy to production
          4. generate index file for a story

    -h, --help
        Display this help file.

EOF
}

if [[ $# -eq 0 ]] ; then
    show_help
    exit 0
fi

while :; do
  case "$1" in
    -o|--operation)
      if [ "$2" ]
      then
        GBLOG_OPERATION="$2"
        shift
      else
        echo "-o or --operation requires a non-empty argument."
        exit 1
      fi
      ;;
    -h|--help)
      show_help
      exit
      ;;
    *)
      break
  esac
  shift
done


case "$GBLOG_OPERATION" in
 1)
   echo "[$(date +%T)] Starting a development build & deploy, then running the local back-end server."
   GBLOG_ENVFILE='.env.dev'
   dev
   ;;
 2)
   echo "[$(date +%T)] Starting staging build & deploy."
   GBLOG_ENVFILE=".env.staging"
   staging
   exit 0
   ;;
 3)
   echo "[$(date +%T)] Starting production build & deploy."
   GBLOG_ENVFILE=".env.production"
   prod
   exit 0
   ;;
 4)
   echo "Which story needs a new index file?"
   read GBLOG_STORYNAME
   echo "[$(date +%T)] Building index file for $GBLOG_STORYNAME."
   generate_index
   exit 0
   ;;
 *)
   echo "Invalid operation requested."
   show_help
   ;;
esac

exit 1