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
  echo
}

# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    ALFURL          pointer to an Alfesco document. Using - as the argument reads the first line from stdin."
  echo "                    This have to be a nodeRef."
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfMetadata.sh command prints the nodes metadata to stdout in json format"
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfMetadata.sh workspace://SpacesStore/1234-1234-123-1234 | jshon"
  echo "     --> fetches the metadata and pretty-prints the json by piping it through the jshon tool"
  echo
  echo "  alfMetadata.sh workspace://SpacesStore/1234-1234-123-1234 | jshon -e properties -e cm:description -u"
  echo "     --> prints the contents of the cm:description property" 
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
  echp "  alf url: $ALF_URL"
fi

if [[ "$ALF_URL" == "" ]]
then
  echo "missing alfresco url"
  exit 1
fi


if __is_noderef $ALF_URL
then
  __encode_url_param $ALF_URL
  ENC_NODEREF=$ENCODED_PARAM 

  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW "$ALF_EP/service/api/metadata?nodeRef=$ENC_NODEREF&shortQNames=true"
else
  echo "not a noderef"
  exit 1
fi






