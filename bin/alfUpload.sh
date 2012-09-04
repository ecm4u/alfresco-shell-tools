#!/bin/bash
#set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

# intended to be replaced in command script by a command specific output
function __show_command_options() {
  echo "  command options:"
  echo "    -n NAME        filename to use for Alfresco"
  echo
}

# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    LOCAL_FILE      path to a local file, or - to read contents from stdin."
  echo "    ALFURL          pointer to an Alfesco document."
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfUpload.sh command adds content to Alfresco"
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfUpload.sh ./local/file.pdf /some/repo/path/to/space"
  echo "     --> uploads the local file at ./local/file.pdf to the space /some/repo/path/to/space"
  echo
  echo "  ./alfUpload.sh ./local/file.pdf workspace://SpacesStore/1234-1234-1234-1234"
  echo "     --> uplodas the local file at ./local/file.pdf to the space given by the nodeRef"
  echo
  echo "  ./alfUpload.sh -n "filename.pdf" - /some/repo/path/to/space"
  echo "     --> uploads content read from stdin and saves it to a file at /some/repo/path/to/space/filename.pdf"
  
}


# command local options
ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}n:"
ALF_CONTENT_PROP=cm:content
ALF_FILENAME=""

function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME
  in
    n)
      ALF_FILENAME=$OPTARG;;
  esac
}

__process_options $@

# shift away parsed args
shift $((OPTIND-1))

# command arguments,
ALF_LOCAL_FILE=$1
ALF_URL=$2

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
fi

if [[ "$ALF_URL" == "" ]]
then
  echo "missing alfresco url"
  exit 1
fi


if __is_noderef $ALF_URL
then
  __split_noderef $ALF_URL
  __encode_url_param $UUID
  ENC_UUID=$ENCODED_PARAM
  __encode_url_param $STORE
  ENC_STORE=$ENCODED_PARAM
  __encode_url_param $PROTOCOL
  ENC_PROTOCOL=$ENCODED_PARAM
 
#  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW $ALF_EP/service/api/node/$ENC_PROTOCOL/$ENC_STORE/$ENC_UUID/content
else
  __encode_url_path $ALF_URL/$ALF_FILENAME
  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -H 'Content-Type:application/octet-stream' --data-binary @$ALF_LOCAL_FILE -X PUT $ALF_EP/webdav/$ENCODED_PATH
fi






