#!/bin/bash
#set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh


# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfListGroups.sh command lists all groups in Alfresco"
  echo
}


# command local options

__process_options $@

# shift away parsed args
shift $((OPTIND-1))

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
fi

curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW "$ALF_EP/service/api/groups"
