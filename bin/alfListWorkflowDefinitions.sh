#!/bin/bash
#set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh


# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfListWorkflowDefinitions.sh command lists all workflow definnitions in Alfresco"
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
echo " "
echo "Returned info: id, name, title, description"
echo " "
curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW "$ALF_EP/service/api/workflow-definitions" | $ALF_JSHON -Q -e data -a -e id -u -p -e name -u -p -e title -u -p -e description -u | sed 's/^$/-/' | paste -s -d '\t\t\t\n'
echo " "