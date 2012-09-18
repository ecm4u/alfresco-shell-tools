#!/bin/bash
# set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh


# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    ALF_USER_NAME   a valid alfresco username."
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfResetAvatar.sh restores the Alfresco default avatar."
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfResetAvatar.sh admin"
  echo "     --> admin will have standard picture again"
  echo
  
}


# command local options

__process_options $@

# shift away parsed args
shift $((OPTIND-1))

# command arguments,
ALF_USER_NAME=$1

# parameter check

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
  echo "  local file: $ALF_LOCAL_FILE"
  echo "  alf user: $ALF_USER_NAME"
fi

if [[ "$ALF_USER_NAME" == "" ]]
then
  echo "missing alfresco user id"
  exit 1
fi

__encode_url_param $ALF_USER_NAME
ENC_USER=$ENCODED_PARAM

curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW --data-binary '{}' -H 'Content-Type:application/json' -X PUT $ALF_EP/service/slingshot/profile/resetavatar/$ENC_USER











