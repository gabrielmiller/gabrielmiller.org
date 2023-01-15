#!/bin/bash

dev() {
  while read line; do
    eval $line
  done < $GBLOG_ENVFILE
  cd backend && go build . && echo "[$(date +%T)] Blog listening on port $PORT" && ./blog
}

staging() {
  echo "TODO: staging stuff"
}

prod() {
  echo "TODO: prod stuff"
}

show_help() {
cat << EOF
Usage: blog.sh [-o -y]

Do the blog thing.
    
    -o, --operation
        Operation to perform.
        Options:
          1: build and run development backend environment
          2. build and deploy to staging
          3. build and deploy to production

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
        exit 1;
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
   ;;
 3)
   echo "[$(date +%T)] Starting production build & deploy."
   GBLOG_ENVFILE=".env.production"
   prod
   ;;
 *)
   ;;
esac

echo "end of script"

exit 1;