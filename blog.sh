#!/bin/bash

declare -A frontendfiletypes
frontendfiletypes=(
  ["css"]="text/css"
  ["gif"]="image/gif"
  ["html"]="text/html"
  ["ico"]="image/x-icon"
  ["js"]="application/javascript"
  ["jpg"]="image/jpeg"
  ["png"]="image/png"
  ["webmanifest"]="application/manifest+json"
)

declare -A storyfiletypes
storyfiletypes=(
  ["gif"]="image/gif"
  ["jpg"]="image/jpeg"
  ["json"]="application/json"
)

validate_aws_dependency() {
  if ! command -v aws &> /dev/null
  then
    echo "aws cli dependency could not be found. You should install the AWS CLI."
    exit 1
  fi

  AWSVERSION=$(aws --version)
  if [ "$AWSVERSION" != "aws-cli/2.9.19 Python/3.9.11 Linux/6.1.9-arch1-1 exe/x86_64.arch prompt/off" ]
  then
    echo "WARNING: Using untested aws version. This has only been tested with aws-cli/2.9.19 Python/3.9.11 Linux/6.1.9-arch1-1 exe/x86_64.arch prompt/off."
  fi
}

validate_go_dependency() {
  if ! command -v go &> /dev/null
  then
    echo "Go dependency could not be found. You should install go1.20 linux/amd64 before proceeding."
    exit 1
  fi

  GOVERSION=$(go version)
  if [ "$GOVERSION" != "go version go1.20 linux/amd64" ]
  then
    echo "WARNING: Using untested go version. This has only been tested with 1.20 linux/amd64."
  fi
}

validate_tls_dependency() {
  if ! command -v certbot &> /dev/null
  then
    echo "Certbot dependency could not be found. You should install certbot 1.32.2 before proceeding."
    exit 1
  fi

  CERTBOTVERSION=$(certbot --version)
  if [ "$CERTBOTVERSION" != "certbot 1.32.2" ]
  then
    echo "WARNING: Using untested certbot version. This has only been tested with 1.32.2."
  fi

  if ! p=$(certbot plugins | grep dns-route53)
  then
    echo "WARNING: Could not locate route53 plugin. This has only been tested with it installed."
  fi
}

# load the specific environment's variables from a local file
set_environment() {
  while read line; do
    eval $line
  done < "$GBLOG_ENVFILE"
}

# one-off for local dev stuff
dev() {
  cd backend
  set_environment
  go build . && \
  echo "[$(date +%T)] Blog API listening on port $PORT" && ./blog
}


# 1. validate every story has an index.json file. exit 1 on fail
# 2. validate every story file is an allowed extensions. exit 1 on fail
validate_story_filetypes() {
  cd stories

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

  cd ..
}

# deploy the story files to the s3 story bucket
deploy_stories() {
  cd stories
  set_environment

  echo "[Stories] Destroying bucket contents"
  result=$(aws s3 rm s3://"$S3_BUCKET_NAME" --recursive)

  for directory in $(ls -d */)
  do
    echo "[Stories] Uploading $directory"
    for file in $(ls $directory)
    do
      filename="${file##*/}"
      extension="${filename##*.}"
      mimetype=${storyfiletypes["$extension"]}
      result=$(aws s3api put-object --bucket "$S3_BUCKET_NAME" --key "$directory$file" --body "$directory$file" --content-type "$mimetype" 2>&1)

    if [ "$?" -eq 0 ]
    then
      echo "[Stories] Published $directory$file"
    else
      echo "[Stories] There was an error publishing $file:"
      echo "$result"
      exit $?
    fi
    done
  done

  cd ..
}

# build the backend and deploy it to the ec2 instance
deploy_backend() {
  cd backend
  set_environment

  CGO_ENABLED=0 go build .

  PID=$(ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" pgrep -f "^./blog")
  ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" sudo kill -9 "$PID"
  echo "[Backend] Previous binary halted"

  scp -i "$EC2_CREDENTIAL" blog "$EC2_USER"@"$EC2_ADDRESS":"$EC2_PATH"/blog

  echo "[Backend] Binary planted"

  ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" sudo ./blog &
  echo "[Backend] Binary invoked"

  cd ..
}

# build the frontend and deploy it to the s3 frontend bucket
deploy_frontend() {
  cd frontend
  set_environment

  rm -rf dist
  cp -r static dist

  # -todo: tap into a frontend build process

  cd dist
  echo "[Frontend] destroying bucket contents"
  result=$(aws s3 rm s3://"$S3_BUCKET_NAME" --recursive)

  for file in *
  do
    filename="${file##*/}"
    extension="${filename##*.}"
    mimetype=${frontendfiletypes["$extension"]}
    result=$(aws s3api put-object --bucket "$S3_BUCKET_NAME" --key "$file" --body "$file" --cache-control "max-age=$CLOUDFRONT_CACHE_MAX_AGE" --content-type "$mimetype" 2>&1)

  if [ "$?" -eq 0 ]
  then
    echo "[Frontend] Published file: $file"
  else
    echo "[Frontend] There was an error publishing $file:"
    echo "$result"
    exit $?
  fi
  done

  cd ../..
}

shipit() {
  validate_story_filetypes
  deploy_stories
  deploy_backend
  deploy_frontend
}

generate_tls_certificate() {
  cd tls
  set_environment
  sudo -E certbot certonly -d "$APEX_DOMAIN" -d "$WILDCARD_DOMAIN" --email "$EMAIL" --dns-route53 --agree-tos --preferred-challenges=dns --non-interactive
  cd ..
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
          5. generate a tls certificate with certbot

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
   validate_go_dependency
   echo "[$(date +%T)] Starting a development build & deploy, then running the local back-end server."
   GBLOG_ENVFILE='.env.dev'
   dev
   ;;
 2)
   validate_aws_dependency
   validate_go_dependency
   echo "[$(date +%T)] Starting staging build & deploy."
   GBLOG_ENVFILE=".env.staging"
   shipit
   exit 0
   ;;
 3)
   validate_aws_dependency
   validate_go_dependency
   echo "[$(date +%T)] Starting production build & deploy."
   GBLOG_ENVFILE=".env.production"
   shipit
   exit 0
   ;;
 4)
   echo "Which story needs a new index file?"
   read GBLOG_STORYNAME
   echo "[$(date +%T)] Building index file for $GBLOG_STORYNAME."
   generate_index
   exit 0
   ;;
  5)
   validate_aws_dependency
   validate_tls_dependency
   echo "[$(date +%T)] Generating a new certificate for staging."
   GBLOG_ENVFILE=".env.staging"
   generate_tls_certificate
   ;;
 *)
   echo "Invalid operation requested."
   show_help
   ;;
esac

exit 1