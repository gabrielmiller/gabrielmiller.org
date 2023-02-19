#!/bin/bash

GBLOG_ENVIRONMENT="staging"
ONLY_BACKEND=false
ONLY_FRONTEND=false

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

validate_nodejs_dependency() {
  if ! command -v node &> /dev/null
  then
    echo "Nodejs dependency could not be found. You should install node v18.14.0 before proceeding."
    exit 1
  fi

  NODEJSVERSION=$(node -v)
  if [ "$NODEJSVERSION" != "v18.14.0" ]
  then
    echo "WARNING: Using untested nodejs version. This has only been tested with v18.14.0."
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
initialize_environment() {
  while read line; do
    eval $line
  done < "$GBLOG_ENVFILE"
}

attach_to_api_server() {
  cd backend
  initialize_environment
  CGO_ENABLED=0 go build .
  ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS"
  echo "[Backend] Connection closed."
  cd ..
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
  cd backend
  initialize_environment

  CGO_ENABLED=0 go build .

  ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" rm "$EC2_PATH"/blog
  scp -i "$EC2_CREDENTIAL" blog "$EC2_USER"@"$EC2_ADDRESS":"$EC2_PATH"/blog &> /dev/null
  echo "[Backend] Previous binary removed and new binary planted"

  OLDPID=$(ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" pgrep -f "^./blog")
  ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" sudo kill -9 "$OLDPID"
  echo "[Backend] Previous binary halted"

  ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" \
  AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION" \
  PORT="$PORT" \
  FRONTEND_DOMAIN="$FRONTEND_DOMAIN" \
  S3_BUCKET_NAME="$S3_BUCKET_NAME" \
  TLS_CHAIN_CERT="$EC2_CERTIFICATE_CHAIN_PATH" \
  TLS_PRIVATE_KEY="$EC2_CERTIFICATE_PRIVATE_PATH" \
  sudo -E nohup ./blog &

  echo "[Backend] New binary invoked"

  cd ..
}

deploy_frontend() {
  cd frontend
  initialize_environment

  rm -rf dist
  cp -r static dist

  npm install
  npm run build

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
  if [ "$ONLY_FRONTEND" = false ]
  then
    deploy_backend
  else
    echo "[Backend] build & deployment skipped";
  fi

  if [ "$ONLY_BACKEND" = false ]
  then
    deploy_frontend
  else
    echo "[Frontend] build & deployment skipped";
  fi
}

generate_tls_certificate() {
  cd dns
  initialize_environment
  sudo -E certbot certonly -d "$APEX_DOMAIN" -d "$WILDCARD_DOMAIN" --email "$EMAIL" --dns-route53 --agree-tos --preferred-challenges=dns --non-interactive
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

plant_tls_certificate_in_acm() {
  cd cert
  initialize_environment
  sudo -E aws acm import-certificate --certificate-arn $CERTIFICATE_ARN --certificate fileb://"$CERTIFICATE_PUBLIC" --private-key fileb://"$CERTIFICATE_PRIVATE_KEY" --certificate-chain fileb://"$CERTIFICATE_CHAIN"
  echo "[TLS] token planted"

  cd ..
}

plant_tls_certificate_in_ec2() {
  cd backend
  initialize_environment

  ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" sudo mkdir -p "$EC2_CERTIFICATE_PATH"

  sudo scp -i "$EC2_CREDENTIAL" "$CERTIFICATE_CHAIN" "$EC2_USER"@"$EC2_ADDRESS":"$EC2_PATH"/fullchain.pem &> /dev/null
  ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" sudo mv "$EC2_PATH"/fullchain.pem "$EC2_CERTIFICATE_CHAIN_PATH"

  sudo scp -i "$EC2_CREDENTIAL" "$CERTIFICATE_PRIVATE_KEY" "$EC2_USER"@"$EC2_ADDRESS":"$EC2_PATH"/privkey.pem &> /dev/null
  ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" sudo mv "$EC2_PATH"/privkey.pem "$EC2_CERTIFICATE_PRIVATE_PATH"

  echo "[TLS] token planted"

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
          2. deploy stories
          3. generate index file for a story
          4. generate a tls certificate
          5. plant the tls certificate in acm
          6. plant the tls certificate in ec2 (& reboot api?)
          7. attach terminal to api server

    --only-frontend
        Complete the code build & deploy only for the frontend.

    --only-backend
        Complete the code build & deploy only for the backend.

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
    --only-frontend)
      ONLY_FRONTEND=true
      ;;
    --only-backend)
      ONLY_BACKEND=true
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
   if [ -f "$GBLOG_INDEX_FILE" ]
   then
     echo "Procedure requested in production environment. Are you sure? y/N"
     read PROCEED_IN_PRODUDCTION
   fi
   if [ "$PROCEED_IN_PRODUDCTION" != "y" ]
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
   validate_aws_dependency
   echo "[$(date +%T)] Starting $GBLOG_ENVIRONMENT story deployment."
   validate_story_filetypes
   deploy_stories
   echo "[$(date +%T)] Story deploy complete."
   exit 0
   ;;
 3)
   echo "Which story needs a new index file?"
   read GBLOG_STORYNAME
   echo "[$(date +%T)] Building index file for $GBLOG_STORYNAME."
   generate_index_file
   echo "[$(date +%T)] Index file generated."
   exit 0
   ;;
 4)
   validate_aws_dependency
   validate_tls_dependency
   echo "[$(date +%T)] Generating a new certificate for $GBLOG_ENVIRONMENT."
   generate_tls_certificate
   echo "[$(date +%T)] Certificate generated."
   exit 0
   ;;
 5)
   validate_aws_dependency
   echo "[$(date +%T)] Planting the $GBLOG_ENVIRONMENT certificate in acm."
   plant_tls_certificate_in_acm
   echo "[$(date +%T)] Certificate planted in acm."
   exit 0
   ;;
 6)
   echo "[$(date +%T)] Planting the $GBLOG_ENVIRONMENT certificate in ec2."
   plant_tls_certificate_in_ec2
   echo "[$(date +%T)] Certificate planted in ec2."
   exit 0
   ;;
 7)
   echo "Attaching to $GBLOG_ENVIRONMENT api server."
   attach_to_api_server
   exit 0
   ;;
 *)
   echo "Invalid operation requested."
   show_help
   exit 1
   ;;
esac

exit 1