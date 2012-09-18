#!/bin/bash
# set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh


# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    LOCAL_FILE      path to a local file, or - to read contents from stdin."
  echo "    ALF_USER_NAME   a valid alfresco username."
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfSetAvatar.sh set ups the users avatar picture."
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfSetAvatar.sh ./local/pic.png admin"
  echo "     --> updates the avatar picture of admin "
  echo
  
}


# command local options
ALF_CONTENT_PROP=cm:content
ALF_FILENAME=""
ALF_CONTENT_TYPE="cm:content"
ALF_MIMETYPE=""

__process_options $@

# shift away parsed args
shift $((OPTIND-1))

# command arguments,
ALF_LOCAL_FILE=$1
ALF_USER_NAME=$2

# parameter check
if [[ "$ALF_FILENAME" == "" && "$ALF_LOCAL_FILE" == "-" ]]
then
  echo "option -n is required if contents are read from stdin"
  exit 1
fi

# use locals file name as name in alfresco if -n option is not used
if [[ "$ALF_FILENAME" == "" ]]
then
  ALF_FILENAME=`basename "$ALF_LOCAL_FILE"`
fi

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
  echo "  local file: $ALF_LOCAL_FILE"
  echo "  alf filename: $ALF_FILENAME"
  echo "  alf user: $ALF_USER_NAME"
fi

if [[ "$ALF_USER_NAME" == "" ]]
then
  echo "missing alfresco user id"
  exit 1
fi

if [[ "$ALF_MIMETYPE" != "" ]]
then
  ALF_MT_ARG=";type=$ALF_MIMETYPE"
else
  ALF_MT_ARG=""
fi

curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW --form "contentType=cm:content" --form "filedata=@$ALF_LOCAL_FILE;filename=${ALF_FILENAME}${ALF_MT_ARG}" --form "username=$ALF_USER_NAME" --form "overwrite=false" $ALF_EP/service/slingshot/profile/uploadavatar | $ALF_JSHON -Q -e nodeRef -u











