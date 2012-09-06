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
  echo "    ALFURL          pointer to an Alfesco document. Using - as the argument reads the first line from stdin."
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfDelete.sh command deletes an object from Alfresco."
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfDelete.sh /app:company_home/cm:some/cm:path/cm:goto.pdf"
  echo "     --> deletes the file goto.pdf. The path must be a qname path"
  echo "  ./alfDelete.sh workspace://SpacesStore/1234-1234-123-1234"
  echo "     --> deletes the content or folder with the given noderef"
}


# command local options

__process_options $@

# shift away parsed args
shift $((OPTIND-1))

# command arguments, read first line from stdin if argument is -
ALF_URL=$1
if [[ "$ALF_URL" == "-" ]]
then
  read line
  ALF_URL=$line
fi

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
  echo "  alf url: $ALF_URL"
fi

if [[ "$ALF_URL" == "" ]]
then
  echo "missing alfresco url"
  exit 1
fi

if ! __is_noderef $ALF_URL
then
  ALF_URL=`$ALFTOOLS_BIN/alfPath2NodeRef.sh "$ALF_URL"`
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
 
#  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -X DELETE $ALF_EP/service/api/node/$ENC_PROTOCOL/$ENC_STORE/$ENC_UUID
  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -X DELETE $ALF_EP/service/slingshot/doclib/action/file/node/$ENC_PROTOCOL/$ENC_STORE/$ENC_UUID
else
  echo "just noderefs are supported"
  exit 1
fi
