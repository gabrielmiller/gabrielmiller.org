#!/bin/bash

GBLOG_ENVIRONMENT="staging"
SKIP_BACKEND=false
SKIP_FRONTEND=false
SKIP_BLOG=false
OPTIMIZED_IMAGE_SIZE=1920

VALIDAWSVERSION="aws-cli/2.9.19 Python/3.9.11 Linux/6.5.9-arch2-1 exe/x86_64.arch prompt/off"
VALIDCERTBOTVERSION="certbot 2.6.0"
VALIDGOVERSION="go version go1.21.3 linux/amd64"
VALIDNODEJSVERSION="v18.14.0"

declare -A frontendfiletypes
frontendfiletypes=(
  ["css"]="text/css"
  ["gif"]="image/gif"
  ["html"]="text/html"
  ["ico"]="image/x-icon"
  ["js"]="application/javascript"
  ["jpg"]="image/jpeg"
  ["png"]="image/png"
  ["txt"]="text/plain"
  ["webmanifest"]="application/manifest+json"
  ["xml"]="application/xml"
)

declare -A storyfiletypes
storyfiletypes=(
  ["gif"]="image/gif"
  ["jpg"]="image/jpeg"
  ["json"]="application/json"
  ["png"]="image/png"
)

validate_aws_dependency() {
  if ! command -v aws &> /dev/null
  then
    echo "aws cli dependency could not be found. You should install the AWS CLI."
    exit 1
  fi

  AWSVERSION=$(aws --version)
  if [ "$AWSVERSION" != "$VALIDAWSVERSION" ]
  then
    echo "WARNING: Using untested aws version. This has only been tested with $VALIDAWSVERSION."
  fi
}

validate_go_dependency() {
  if ! command -v go &> /dev/null
  then
    echo "Go dependency could not be found. You should install $VALIDGOVERSION before proceeding."
    exit 1
  fi

  GOVERSION=$(go version)
  if [ "$GOVERSION" != "$VALIDGOVERSION" ]
  then
    echo "WARNING: Using untested go version. This has only been tested with $VALIDGOVERSION."
  fi
}

validate_nodejs_dependency() {
  if ! command -v node &> /dev/null
  then
    echo "Nodejs dependency could not be found. You should install node $VALIDNODEJSVERSION before proceeding."
    exit 1
  fi

  NODEJSVERSION=$(node -v)
  if [ "$NODEJSVERSION" != "$VALIDNODEJSVERSION" ]
  then
    echo "WARNING: Using untested nodejs version. This has only been tested with node $VALIDNODEJSVERSION."
  fi
}

validate_image_optimize_dependency() {
  if ! command -v identify &> /dev/null
  then
    echo "identify dependency could not be found. You should install identify before proceeding."
    exit 1
  fi

  if ! command -v bc &> /dev/null
  then
    echo "bc dependency could not be found. You should install bc before proceeding."
    exit 1
  fi
}

validate_tls_dependency() {
  if ! command -v certbot &> /dev/null
  then
    echo "Certbot dependency could not be found. You should install $VALIDCERTBOTVERSION before proceeding."
    exit 1
  fi

  CERTBOTVERSION=$(certbot --version)
  if [ "$CERTBOTVERSION" != "$VALIDCERTBOTVERSION" ]
  then
    echo "WARNING: Using untested certbot version. This has only been tested with $VALIDCERTBOTVERSION."
  fi

  if ! p=$(certbot plugins | grep dns-cloudflare)
  then
    echo "WARNING: Could not locate cloudflare plugin. This has only been tested with it installed."
  fi
}

# load the specific environment's variables from a local file
initialize_environment() {
  while read line; do
    eval $line
  done < "$GBLOG_ENVFILE"
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

        EXTENSION="${file##*.}"

        case "$EXTENSION" in
          "gif"|"jpg"|"png")
            continue
          ;;
          *)
            echo "$file has invalid extension. Valid options: .gif, .jpg, .png"
            exit 1
          ;;
        esac
      done
    fi
  done

  cd ..
}

deploy_story() {
  cd stories
  initialize_environment

  echo "[Stories] Deleting contents for story $1"

  result=$(aws s3 rm s3://"$S3_BUCKET_NAME/$1" --recursive)
  directory="$1/"
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
      echo "[Stories] There was an error publishing $directory$file:"
      echo "$result"
      exit $?
    fi
  done

  cd ..
}

deploy_stories() {
  cd stories
  initialize_environment

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

deploy_backend() {
  cd serverless
  initialize_environment
  npx sst deploy --stage="$GBLOG_ENVIRONMENT"
  cd ..
}

traverse_and_upload_frontend_files() {
  # WARNING: depends on global variable, frontend_files_to_upload
  for pathname in "$1"/*; do
    if [ -d "$pathname" ]; then
      traverse_and_upload_frontend_files "$pathname"
    elif [ -e "$pathname" ]; then
        frontend_files_to_upload+=("$pathname")
    fi
  done
}

deploy_frontend() {
  cd frontend
  initialize_environment

  rm -rf dist
  cp -r static dist

  npm install

  if [ "$SKIP_BLOG" = false ]
  then
    npm run build -w blog
    # build processes independently move their output to the dist dir
  else
    echo "[Frontend] Blog build & deployment skipped";
  fi

  npm run build -w story-viewer

  cd dist
  echo "[Frontend] Destroying bucket contents"
  # todo: if skip_blog was set, make this not accidentally destroy the last deployed blog
  result=$(aws s3 rm s3://"$S3_BUCKET_NAME" --recursive)

  frontend_files_to_upload=()
  traverse_and_upload_frontend_files .
  echo "[Frontend] Uploading files to s3"
  for file in "${frontend_files_to_upload[@]}"
  do
    filename="${file##*/}"
    extension="${filename##*.}"
    mimetype=${frontendfiletypes["$extension"]}
    key="${file:2}" # shave the ./ prefix off for the s3 key
    result=$(aws s3api put-object --bucket "$S3_BUCKET_NAME" --key "$key" --body "$file" --cache-control "max-age=$CLOUDFRONT_CACHE_MAX_AGE" --content-type "$mimetype" 2>&1)

    if [ "$?" -ne 0 ]
      then
        echo "[Frontend] There was an error publishing $key:"
        echo "$result"
        exit $?
      fi
  done

  cd ../..
}

shipit() {
  if [ "$SKIP_BACKEND" = false ]
  then
    deploy_backend
  else
    echo "[Backend] Build & deployment skipped";
  fi

  if [ "$SKIP_FRONTEND" = false ]
  then
    deploy_frontend
  else
    echo "[Frontend] Build & deployment skipped";
  fi
}

generate_tls_certificate() {
  cd dns
  initialize_environment
  sudo -E certbot certonly -d "$APEX_DOMAIN" -d "$WILDCARD_DOMAIN" --email "$EMAIL" --dns-cloudflare --agree-tos --preferred-challenges dns --non-interactive --dns-cloudflare-credentials cloudflare.ini --dns-cloudflare-propagation-seconds 30
  # --force-renewal if doing this off of the usual schedule
  cd ..
}

generate_index_file() {
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
  for file in *
  do
    if [ "$file" == "index.json" ]
    then
      continue
    fi

    EXTENSION="${file##*.}"

    case "$EXTENSION" in
      "gif"|"jpg"|"png")
        INDEX_ENTRIES="$INDEX_ENTRIES,{\"metadata\":{\"description\":\"\"},\"filename\":\"$file\"}"
      ;;
      *)
        echo "$file has invalid extension. Valid options: .gif, .jpg, .png"
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

optimize_image_sizes() {
  cd stories
  echo "Optimizing images in $GBLOG_STORYNAME"
  mkdir -p "$GBLOG_STORYNAME"/optimized
  for file in $(ls "$GBLOG_STORYNAME")
  do
    EXTENSION="${file##*.}"
    case "$EXTENSION" in
      "jpg"|"png")
        height=$(identify -format "%h" $GBLOG_STORYNAME/$file)
        width=$(identify -format "%w" $GBLOG_STORYNAME/$file)
        aspectratio=$(echo "scale=2; $width/$height" | bc)

        if [ 1 -eq "$(echo "$aspectratio > 2" | bc)" ]
        then
          # Don't resize panoramas
          continue
        elif [ 1 -eq "$(echo "$aspectratio > 1" | bc)" ]
        then
          # Resize based on width for landscape
          GEOMETRY="$OPTIMIZED_IMAGE_SIZE"
          VALUE=$width
        else
          # Resize based on height for portrait
          GEOMETRY=x"$OPTIMIZED_IMAGE_SIZE"
          VALUE=$height
        fi

        if [ "$VALUE" -lt "$OPTIMIZED_IMAGE_SIZE"  ]
        then
          # Don't resize images that are already an optimal dimension
          continue
        fi

        convert "$GBLOG_STORYNAME/$file" -geometry $GEOMETRY -quality 80 "$GBLOG_STORYNAME"/optimized/"$file"
      ;;
      *)
        continue
      ;;
    esac
  done
  cd ..
}

plant_tls_certificate_in_acm() {
  cd cert2
  initialize_environment
  sudo -E aws acm import-certificate --certificate-arn "$CERTIFICATE_ARN" --certificate fileb://"$CERTIFICATE_PUBLIC" --private-key fileb://"$CERTIFICATE_PRIVATE_KEY" --certificate-chain fileb://"$CERTIFICATE_CHAIN" --profile="$GBLOG_ENVIRONMENT"
  cd ..

  #todo: consolidate aws accounts...
  cd cert
  initialize_environment
  sudo -E aws acm import-certificate --certificate-arn $CERTIFICATE_ARN --certificate fileb://"$CERTIFICATE_PUBLIC" --private-key fileb://"$CERTIFICATE_PRIVATE_KEY" --certificate-chain fileb://"$CERTIFICATE_CHAIN"
  echo "[TLS] Token planted in acm"
  cd ..
}

show_help() {
cat << EOF

Usage: blog.sh [-o -h]

Do the blog thing.

    -e, --environment
        Environment to use.

        Options:
          - staging (default)
          - production

    -o, --operation
        Operation to perform.

        Options:
          1. build and deploy code
          2. deploy individual story
          3. optimize image sizes for a story
          4. generate index file for a story
          5. generate a tls certificate
          6. plant the tls certificate in acm
          7. deploy all stories

    -t, --title
        Title of story to deploy.

    --skip-frontend
        Skip build & deploy of the frontend.

    --skip-blog
        Skip build & deploy of the blog frontend.

    --skip-backend
        Skip build & deploy of the backend.

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
    -e|--environment)
      if [ "$2" ]
      then
        GBLOG_ENVIRONMENT="$2"
        shift
      else
        echo "-e or --environment requires a non-empty argument."
        exit 1
      fi
      ;;
    -h|--help)
      show_help
      exit
      ;;
    -t|--title)
      if [ "$2" ]
      then
        GBLOG_STORY_TITLE="$2"
        shift
      else
        echo "-t or --title requires a non-empty argument."
        exit 1
      fi
      ;;
    --skip-blog)
      SKIP_BLOG=true
      ;;
    --skip-frontend)
      SKIP_FRONTEND=true
      ;;
    --skip-backend)
      SKIP_BACKEND=true
      ;;
    *)
      break
  esac
  shift
done

case "$GBLOG_ENVIRONMENT" in
 staging)
   GBLOG_ENVFILE=".env.staging"
   ;;
 prod|production)
   GBLOG_ENVIRONMENT="production"
   GBLOG_ENVFILE=".env.production"

   PROCEED_IN_PRODUDCTION="n"
   echo "Procedure requested in production environment. Are you sure? y/N"
   read PROCEED_IN_PRODUCTION

   if [ "$PROCEED_IN_PRODUCTION" != "y" ]
   then
     echo "Bailing out of operation."
     exit 0
   fi
   ;;
 *)
   echo "Invalid environment requested."
   exit 1
   ;;
esac


case "$GBLOG_OPERATION" in
 1)
   validate_aws_dependency
   validate_go_dependency
   validate_nodejs_dependency
   echo "[$(date +%T)] Starting $GBLOG_ENVIRONMENT build & deployment."
   shipit
   echo "[$(date +%T)] Code build & deployment complete."
   exit 0
   ;;
 2)
   if [ "$GBLOG_STORY_TITLE" = "" ]
   then
    echo "ERROR: You must specify a title."
    exit 1
   fi

   if [ ! -d "stories/$GBLOG_STORY_TITLE" ]
   then
     echo "ERROR: Could not find story $GBLOG_STORY_TITLE."
     exit 1
   fi

   validate_aws_dependency
   echo "[$(date +%T)] Starting $GBLOG_ENVIRONMENT story deployment of $GBLOG_STORY_TITLE."
   # todo: only validate the selected story
   validate_story_filetypes
   deploy_story $GBLOG_STORY_TITLE
   echo "[$(date +%T)] Story deploy complete."
   exit 0
   ;;
 3)
   validate_image_optimize_dependency
   echo "Which story's images should be optimized?"
   read GBLOG_STORYNAME
   echo "[$(date +%T)] Optimizing images for $GBLOG_STORYNAME."
   optimize_image_sizes
   echo "[$(date +%T)] Images optimized."
   exit 0
   ;;
 4)
   echo "Which story needs a new index file?"
   read GBLOG_STORYNAME
   echo "[$(date +%T)] Building index file for $GBLOG_STORYNAME."
   generate_index_file
   echo "[$(date +%T)] Index file generated."
   exit 0
   ;;
 5)
   validate_aws_dependency
   validate_tls_dependency
   echo "[$(date +%T)] Generating a new certificate for $GBLOG_ENVIRONMENT."
   generate_tls_certificate
   echo "[$(date +%T)] Certificate generated."
   exit 0
   ;;
 6)
   validate_aws_dependency
   echo "[$(date +%T)] Planting the $GBLOG_ENVIRONMENT certificate in acm."
   plant_tls_certificate_in_acm
   echo "[$(date +%T)] Certificate planted in acm."
   exit 0
   ;;
 7)
   validate_aws_dependency
   echo "[$(date +%T)] Starting $GBLOG_ENVIRONMENT story deployment."
   validate_story_filetypes
   deploy_stories
   echo "[$(date +%T)] Story deploy complete."
   exit 0
   ;;
 *)
   echo "Invalid operation requested."
   show_help
   exit 1
   ;;
esac

exit 1