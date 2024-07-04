#!/bin/bash

GBLOG_ENVIRONMENT="staging"
GBLOG_SUBDOMAIN="apex"
SKIP_BACKEND=false
SKIP_FRONTEND=false
OPTIMIZED_IMAGE_SIZE=1920

VALIDAWSVERSION="aws-cli/2.9.19 Python/3.9.11 Linux/6.7.1-arch1-1 exe/x86_64.arch prompt/off"
VALIDCERTBOTVERSION="certbot 2.8.0"
VALIDGOVERSION="go version go1.21.6 linux/amd64"
VALIDNODEJSVERSION="v20.10.0"

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

declare -A albumfiletypes
albumfiletypes=(
  ["gif"]="image/gif"
  ["jpg"]="image/jpeg"
  ["json"]="application/json"
  ["png"]="image/png"
)

declare -A subdomains
subdomains=(
  ["apex"]=""
  ["www"]="www"
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

# 1. validate every album has an index.json file. exit 1 on fail
# 2. validate every album file is an allowed extensions. exit 1 on fail
validate_album_filetypes() {
  cd albums

  for directory in $(ls -d */)
  do
    indexFile="$directory""index.json"
    if [ ! -f $indexFile ]
    then
      echo "No index file found in albums/$directory. You must create one to proceed."
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

redeploy_index() {
  cd albums

  echo "[Albums] Deleting existing index for album $1"
  aws s3api delete-object --bucket "$ALBUM_BUCKET" --key "$directory$file" --profile "$AWS_PROFILE"

  directory="$1/"
  file="index.json"
  mimetype="application/json"
  result=$(aws s3api put-object --bucket "$ALBUM_BUCKET" --key "$directory$file" --body "$directory$file" --content-type "$mimetype" --profile "$AWS_PROFILE" 2>&1)

  if [ "$?" -eq 0 ]
    then
      echo "[Albums] Published $directory$file"
    else
      echo "[Albums] There was an error publishing $directory$file:"
      echo "$result"
      exit $?
  fi

  cd ..
}

check_tls_certificate_for_subdomain() {
  echo "Which subdomain should be checked? (default: apex)"
  read GBLOG_SUBDOMAIN

  if [[ "${subdomains[@]}" =~ "$GBLOG_SUBDOMAIN" ]] ; then
    MATCH=1
  fi

  if [ "$MATCH" != 1 ]
  then
    echo "ERROR: Provided subdomain '$GBLOG_SUBDOMAIN' is not valid."
    exit 1
  fi

  if [ "$GBLOG_SUBDOMAIN" = "" ]
  then
    DOMAIN="$APEX_DOMAIN"
  else
    DOMAIN="$GBLOG_SUBDOMAIN.$APEX_DOMAIN"
  fi
  echo "The TLS certificate for $DOMAIN says the following:"
  openssl s_client -servername "$DOMAIN" -connect "$DOMAIN":443 | openssl x509 -noout -dates
}

deploy_album() {
  cd albums

  echo "[Albums] Deleting contents for album $1"

  result=$(aws s3 rm s3://"$ALBUM_BUCKET/$1" --recursive --profile "$AWS_PROFILE")
  directory="$1/"
  for file in $(ls $directory)
  do
    filename="${file##*/}"
    extension="${filename##*.}"
    mimetype=${albumfiletypes["$extension"]}
    result=$(aws s3api put-object --bucket "$ALBUM_BUCKET" --key "$directory$file" --body "$directory$file" --content-type "$mimetype" --profile "$AWS_PROFILE" 2>&1)
    if [ "$?" -eq 0 ]
    then
      echo "[Albums] Published $directory$file"
    else
      echo "[Albums] There was an error publishing $directory$file:"
      echo "$result"
      exit $?
    fi
  done

  cd ..
}

#todo probably nuke this since I don't use it
deploy_albums() {
  cd albums

  echo "[Albums] Destroying bucket contents"
  result=$(aws s3 rm s3://"$ALBUM_BUCKET" --recursive --profile "$AWS_PROFILE")

  for directory in $(ls -d */)
  do
    echo "[Albums] Uploading $directory"
    for file in $(ls $directory)
    do
      filename="${file##*/}"
      extension="${filename##*.}"
      mimetype=${albumfiletypes["$extension"]}
      result=$(aws s3api put-object --bucket "$ALBUM_BUCKET" --key "$directory$file" --body "$directory$file" --content-type "$mimetype" --profile "$AWS_PROFILE" 2>&1)
      if [ "$?" -eq 0 ]
      then
        echo "[Albums] Published $directory$file"
      else
        echo "[Albums] There was an error publishing $file:"
        echo "$result"
        exit $?
    fi
    done
  done

  cd ..
}

deploy_backend() {
  npm run deploy -w album-backend -- --stage "$AWS_PROFILE"
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
  rm -rf dist
  cp -r static dist

  # note: build processes independently move their output to the dist dir
  npm run build -w blog
  npm run build -w album-viewer

  cd dist
  echo "[Frontend] Destroying bucket contents"
  rm_result=$(aws s3 rm s3://"$APEX_BUCKET_NAME" --recursive --profile "$AWS_PROFILE" 2>&1)
  if [ "$?" -ne 0 ]
   then
     echo "[Frontend] There was an error destroying bucket contents."
     echo "$rm_result"
     exit $?
  fi

  frontend_files_to_upload=()
  traverse_and_upload_frontend_files .
  echo "[Frontend] Uploading files to s3"
  for file in "${frontend_files_to_upload[@]}"
  do
    filename="${file##*/}"
    extension="${filename##*.}"
    mimetype=${frontendfiletypes["$extension"]}
    key="${file:2}" # shave the ./ prefix off for the s3 key
    result=$(aws s3api put-object --profile "$AWS_PROFILE" --bucket "$APEX_BUCKET_NAME" --key "$key" --body "$file" --cache-control "max-age=$CLOUDFRONT_CACHE_MAX_AGE" --content-type "$mimetype" 2>&1)

    if [ "$?" -ne 0 ]
      then
        echo "[Frontend] There was an error publishing $key:"
        echo "$result"
        exit $?
      fi
  done

  cd ..
}

shipit() {
  cd src
  npm install

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

  cd ..
}

generate_tls_certificate() {
  cd dns
  initialize_environment
  sudo -E certbot certonly -d "$APEX_DOMAIN_ORIGIN" -d "$WILDCARD_DOMAIN" --email "$EMAIL" --dns-cloudflare --agree-tos --preferred-challenges dns --non-interactive --dns-cloudflare-credentials cloudflare.ini --dns-cloudflare-propagation-seconds 30
  # --force-renewal if doing this off of the usual schedule
  cd ..
}

generate_index_file() {
  ALBUM_DIRECTORY="./albums/$GBLOG_ALBUMNAME"
  if [ ! -d "$ALBUM_DIRECTORY" ]
  then
    echo "No directory exists for album $GBLOG_ALBUMNAME. You should first create the directory and place all desired media files in it."
    exit 1
  fi

  GBLOG_INDEX_FILE="$ALBUM_DIRECTORY/index.json"
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
  cd $ALBUM_DIRECTORY
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
  cd albums
  echo "Optimizing images in $GBLOG_ALBUMNAME"
  mkdir -p "$GBLOG_ALBUMNAME"/optimized
  for file in $(ls "$GBLOG_ALBUMNAME")
  do
    EXTENSION="${file##*.}"
    case "$EXTENSION" in
      "jpg"|"png")
        height=$(identify -format "%h" $GBLOG_ALBUMNAME/$file)
        width=$(identify -format "%w" $GBLOG_ALBUMNAME/$file)
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

        convert "$GBLOG_ALBUMNAME/$file" -geometry $GEOMETRY -quality 80 "$GBLOG_ALBUMNAME"/optimized/"$file"
      ;;
      *)
        continue
      ;;
    esac
  done
  cd ..
}

plant_tls_certificate_in_acm() {
  cd cert2 #todo rename to cert
  initialize_environment
  sudo -E aws acm import-certificate --certificate-arn "$CERTIFICATE_ARN" --certificate fileb://"$CERTIFICATE_PUBLIC" --private-key fileb://"$CERTIFICATE_PRIVATE_KEY" --certificate-chain fileb://"$CERTIFICATE_CHAIN" --profile "$AWS_PROFILE"
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
          2. deploy individual album
          3. optimize image sizes for an album
          4. generate index file for an album
          5. authenticate with aws
          6. generate a tls certificate
          7. plant the tls certificate in acm
          8. check subdomain tls certificate expiration date
          9. deploy all albums
          10. update index for an individual album

    -t, --title
        Title of album to deploy.

    --skip-frontend
        Skip build & deploy of the frontend.

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
        GBLOG_ALBUM_TITLE="$2"
        shift
      else
        echo "-t or --title requires a non-empty argument."
        exit 1
      fi
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

   PROCEED_IN_PRODUCTION="n"
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


if [ ! -f $GBLOG_ENVFILE ]
then
cat << EOF
Cannot find $GBLOG_ENVFILE. Run terraform to generate it, like so:

cd infra
terraform -chdir=./$GBLOG_ENVIRONMENT plan -var-file=./variables.tfvars -out changes
terraform -chdir=./$GBLOG_ENVIRONMENT apply changes
cd ..

EOF
  exit 1
else
  set -a
  source "$GBLOG_ENVFILE"
  set +a
fi

case "$GBLOG_OPERATION" in
 1) # build and deploy code
   validate_aws_dependency
   validate_go_dependency
   validate_nodejs_dependency
   echo "[$(date +%T)] Starting $GBLOG_ENVIRONMENT build & deployment."
   shipit
   echo "[$(date +%T)] Code build & deployment complete."
   exit 0
   ;;
 2) # deploy an album
   if [ "$GBLOG_ALBUM_TITLE" = "" ]
   then
    echo "ERROR: You must specify a title."
    exit 1
   fi

   if [ ! -d "albums/$GBLOG_ALBUM_TITLE" ]
   then
     echo "ERROR: Could not find album $GBLOG_ALBUM_TITLE."
     exit 1
   fi

   validate_aws_dependency
   echo "[$(date +%T)] Starting $GBLOG_ENVIRONMENT album deployment of $GBLOG_ALBUM_TITLE."
   # todo: only validate the selected album
   validate_album_filetypes
   deploy_album $GBLOG_ALBUM_TITLE
   echo "[$(date +%T)] album deploy complete."
   exit 0
   ;;
 3) # optimize image sizes for an album
   validate_image_optimize_dependency
   echo "Which album's images should be optimized?"
   read GBLOG_ALBUMNAME
   echo "[$(date +%T)] Optimizing images for $GBLOG_ALBUMNAME."
   optimize_image_sizes
   echo "[$(date +%T)] Images optimized."
   exit 0
   ;;
 4) # generate index file for an album
   echo "Which album needs a new index file?"
   read GBLOG_ALBUMNAME
   echo "[$(date +%T)] Building index file for $GBLOG_ALBUMNAME."
   generate_index_file
   echo "[$(date +%T)] Index file generated."
   exit 0
   ;;
 5) # authenticate with aws
   validate_aws_dependency
   aws sso login --sso-session=gabe
   ;;
 6) # generate tls cert
   validate_aws_dependency
   validate_tls_dependency
   echo "[$(date +%T)] Generating a new certificate for $GBLOG_ENVIRONMENT."
   generate_tls_certificate
   echo "[$(date +%T)] Certificate generated."
   exit 0
   ;;
 7) # plant tls cert in acm
   validate_aws_dependency
   echo "[$(date +%T)] Planting the $GBLOG_ENVIRONMENT certificate in acm."
   plant_tls_certificate_in_acm
   echo "[$(date +%T)] Certificate planted in acm."
   exit 0
   ;;
 8) # check subdomain tls expiration date
   echo "[$(date +%T)] validating tls certificate expiration date..."
   check_tls_certificate_for_subdomain

   exit 0
   ;;
 9) # deploy all albums
   validate_aws_dependency
   echo "[$(date +%T)] Starting $GBLOG_ENVIRONMENT album deployment."
   validate_album_filetypes
   deploy_albums
   echo "[$(date +%T)] album deploy complete."
   exit 0
   ;;
 10) # update index for an individual album
   if [ "$GBLOG_ALBUM_TITLE" = "" ]
   then
    echo "ERROR: You must specify a title."
    exit 1
   fi

   if [ ! -d "albums/$GBLOG_ALBUM_TITLE" ]
   then
     echo "ERROR: Could not find album $GBLOG_ALBUM_TITLE."
     exit 1
   fi

   validate_aws_dependency
   echo "[$(date +%T)] Updating index file for $GBLOG_ENVIRONMENT album deployment of $GBLOG_ALBUM_TITLE."

   validate_album_filetypes
   redeploy_index $GBLOG_ALBUM_TITLE
   echo "[$(date +%T)] Index updated."
   exit 0
   ;;
 *)
   echo "Invalid operation requested."
   show_help
   exit 1
   ;;
esac

exit 1