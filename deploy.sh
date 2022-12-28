#!/bin/bash

GBLOG_ENVIRONMENT=staging
GBLOG_CODEBASE=all

show_help() {
cat << EOF
Usage: deploy.sh [-c -e]

Deploy blog code.
Defaults to deployment of all code on staging environment.

    -c, --codebase
        Codebase to deploy
        Options: (all, be, fe)

        Default: both

    -e, --environment
        Environment to deploy
        Options: (staging, prod)

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
    -c|--codebase)
      if [ "$2" ]
      then
        GBLOG_CODEBASE="$2"
        shift
      else
        echo "-c or --codebase requires a non-empty argument."
        exit 1;
      fi
      ;;
    -e|--environment)
      if [ "$2" ]
      then
        GBLOG_ENVIRONMENT="$2"
        shift
      else
        echo "-e or --environment requires a non-empty argument."
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

declare -a VALID_ENVIRONMENT_ARRAY=(
 staging prod
)
declare -A VALID_ENVIRONMENTS
for key in "${!VALID_ENVIRONMENT_ARRAY[@]}"; do VALID_ENVIRONMENTS[${VALID_ENVIRONMENT_ARRAY[$key]}]="$key"; done

if [ -n "${VALID_ENVIRONMENTS[$GBLOG_ENVIRONMENT]}" ]
then
    echo "$GBLOG_ENVIRONMENT environment specified."
else 
    echo "Invalid environment specified: $GBLOG_ENVIRONMENT. Valid options: staging, prod"
    exit 1;
fi

declare -a VALID_CODEBASE_ARRAY=(
 all be fe
)
declare -A VALID_CODEBASES
for key in "${!VALID_CODEBASE_ARRAY[@]}"; do VALID_CODEBASES[${VALID_CODEBASE_ARRAY[$key]}]="$key"; done

if [ -n "${VALID_CODEBASES[$GBLOG_CODEBASE]}" ]
then
    echo "$GBLOG_CODEBASE codebase(s) specified."
else 
    echo "Invalid codebase specified: $GBLOG_CODEBASE. Valid options: all, be, fe"
    exit 1;
fi

# ship it
exit 1;
