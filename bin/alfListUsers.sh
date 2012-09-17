#!/bin/bash
# set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

function __show_command_options() {
  echo "  command options:"
  echo "    -j    optional, switch to enable raw json output"
  echo
}



# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfListPersons.sh command lists all user names of alfresco"
  echo
}

# command local options
ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}jg"
ALF_JSON_OUTPUT=false

function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME
  in
    j)
      ALF_JSON_OUTPUT=true;;
  esac
}


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


if $ALF_JSON_OUTPUT
then
  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW "$ALF_EP/service/api/people"
else
  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW "$ALF_EP/service/api/people" | $ALF_JSHON -Q -e people -a -e  userName -u 
fi
