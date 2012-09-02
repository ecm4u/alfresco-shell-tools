#!/bin/bash
#set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

# intended to be replaced in command script by a command specific output
function __show_command_options() {
  echo "  command options:"
  echo "    no command specific options"

}

# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    ALFURL          pointer to an Alfesco document"
}


# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfGet.sh command downloads a file from Alfresco and prints its contents to stdout"
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfGet.sh some/path/goto.pdf > goto.pdf"
  echo "     --> downloads the file goto.pdf and saves it to the local disk."
  echo "  ./alfGet.sh workspace://SpacesStore/1234-1234-123-1234 > myfile.docx"
  echo "     --> downloads the content given with the given noderef and cm:content property and saves it contents to the local file myfile.docx"
}


# command local options
ALF_CONTENT_PROP=cm:content

__process_global_options $@

# shift away parsed args
shift $((OPTIND-1))

# command arguments
ALF_URL=$1

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
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
 
  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW $ALF_EP/service/api/node/$ENC_PROTOCOL/$ENC_STORE/$ENC_UUID/content
else
  __encode_url_path $ALF_URL
  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW $ALF_EP/webdav/$ENCODED_PATH
fi






