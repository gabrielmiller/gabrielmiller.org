#!/bin/bash

GBLOG_ENVIRONMENT="staging"
ONLY_BACKEND=false
ONLY_FRONTEND=false
OPTIMIZED_IMAGE_SIZE=1920

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

build_systemd_service_file() {
read -r -d '' systemDServiceFile << EOF
[Unit]
Description=Blog API Service
ConditionPathExists=$EC2_PATH
After=network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=$EC2_PATH
ExecStart=$EC2_PATH/blog
Restart=on-failure
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=blogapiservice
Environment=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
Environment=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
Environment=AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
Environment=PORT=$PORT
Environment=FRONTEND_DOMAIN=$FRONTEND_DOMAIN
Environment=S3_BUCKET_NAME=$S3_BUCKET_NAME
Environment=TLS_CHAIN_CERT=$EC2_CERTIFICATE_CHAIN_PATH
Environment=TLS_PRIVATE_KEY=$EC2_CERTIFICATE_PRIVATE_PATH

[Install]
WantedBy=multi-user.target
EOF
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
  cd backend
  initialize_environment
  build_systemd_service_file

  CGO_ENABLED=0 go build .
  ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" rm "$EC2_PATH"/blog
  scp -i "$EC2_CREDENTIAL" blog "$EC2_USER"@"$EC2_ADDRESS":"$EC2_PATH"/blog &> /dev/null

  echo "$systemDServiceFile" | ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" -T "cat > $EC2_PATH"/blog.service
  ssh -i "$EC2_CREDENTIAL" "$EC2_USER@$EC2_ADDRESS" "
    sudo mv $EC2_PATH/blog.service $EC2_SYSTEMD_SERVICE_FILE_PATH
    sudo chown root $EC2_SYSTEMD_SERVICE_FILE_PATH
    sudo chgrp root $EC2_SYSTEMD_SERVICE_FILE_PATH
    sudo chmod 0644 $EC2_SYSTEMD_SERVICE_FILE_PATH
    sudo systemctl daemon-reload
    sudo systemctl stop blog.service
  "
  echo "[Backend] Previous binary halted"

  ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" sudo systemctl start blog.service
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
  echo "[Frontend] Destroying bucket contents"
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
    echo "[Backend] Build & deployment skipped";
  fi

  if [ "$ONLY_BACKEND" = false ]
  then
    deploy_frontend
  else
    echo "[Frontend] Build & deployment skipped";
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
  cd cert
  initialize_environment
  sudo -E aws acm import-certificate --certificate-arn $CERTIFICATE_ARN --certificate fileb://"$CERTIFICATE_PUBLIC" --private-key fileb://"$CERTIFICATE_PRIVATE_KEY" --certificate-chain fileb://"$CERTIFICATE_CHAIN"
  echo "[TLS] Token planted"

  cd ..
}

plant_tls_certificate_in_ec2() {
  cd backend
  initialize_environment

  ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" sudo mkdir -p "$EC2_CERTIFICATE_PATH"

  sudo scp -i "$EC2_CREDENTIAL" "$CERTIFICATE_CHAIN" "$EC2_USER"@"$EC2_ADDRESS":"$EC2_PATH"/fullchain.pem &> /dev/null
  sudo scp -i "$EC2_CREDENTIAL" "$CERTIFICATE_PRIVATE_KEY" "$EC2_USER"@"$EC2_ADDRESS":"$EC2_PATH"/privkey.pem &> /dev/null
  ssh -i "$EC2_CREDENTIAL" "$EC2_USER"@"$EC2_ADDRESS" "
    sudo mv $EC2_PATH/fullchain.pem $EC2_CERTIFICATE_CHAIN_PATH
    sudo mv "$EC2_PATH"/privkey.pem $EC2_CERTIFICATE_PRIVATE_PATH
    sudo chown root $EC2_CERTIFICATE_CHAIN_PATH
    sudo chgrp root $EC2_CERTIFICATE_CHAIN_PATH
    sudo chown root $EC2_CERTIFICATE_PRIVATE_PATH
    sudo chgrp root $EC2_CERTIFICATE_PRIVATE_PATH
  "

  echo "[TLS] Token planted"

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
          3. attach terminal to api server
          4. optimize image sizes for a story
          5. generate index file for a story
          6. generate a tls certificate
          7. plant the tls certificate in acm
          8. plant the tls certificate in ec2 (& reboot api?)
          9. deploy all stories

    -t, --title
        Title of story to deploy.

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
   validate_story_filetypes
   deploy_story $GBLOG_STORY_TITLE
   echo "[$(date +%T)] Story deploy complete."
   exit 0
   ;;
 3)
   echo "Attaching to $GBLOG_ENVIRONMENT api server."
   attach_to_api_server
   exit 0
   ;;
 4)
   validate_image_optimize_dependency
   echo "Which story's images should be optimized?"
   read GBLOG_STORYNAME
   echo "[$(date +%T)] Optimizing images for $GBLOG_STORYNAME."
   optimize_image_sizes
   echo "[$(date +%T)] Images optimized."
   exit 0
   ;;
 5)
   echo "Which story needs a new index file?"
   read GBLOG_STORYNAME
   echo "[$(date +%T)] Building index file for $GBLOG_STORYNAME."
   generate_index_file
   echo "[$(date +%T)] Index file generated."
   exit 0
   ;;
 6)
   validate_aws_dependency
   validate_tls_dependency
   echo "[$(date +%T)] Generating a new certificate for $GBLOG_ENVIRONMENT."
   generate_tls_certificate
   echo "[$(date +%T)] Certificate generated."
   exit 0
   ;;
 7)
   validate_aws_dependency
   echo "[$(date +%T)] Planting the $GBLOG_ENVIRONMENT certificate in acm."
   plant_tls_certificate_in_acm
   echo "[$(date +%T)] Certificate planted in acm."
   exit 0
   ;;
 8)
   echo "[$(date +%T)] Planting the $GBLOG_ENVIRONMENT certificate in ec2."
   plant_tls_certificate_in_ec2
   echo "[$(date +%T)] Certificate planted in ec2."
   exit 0
   ;;
 9)
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