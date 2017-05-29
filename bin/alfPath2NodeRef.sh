#!/bin/bash
# set -x
# param section

# Tested - Workgin with Alfresco 5.1

# source function library


ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfPath2NodeRef.sh maps an Alfresco QName-path to a nodeRef"
  echo "    A QName path is prefixed with a namespace: /app:company_home/cm:testfolder/cm:testfile.pdf"
  echo "    Example: alfPath2NodeRef.sh /app:company_home/st:sites/cm:My_Site/cm:documentLibrary/cm:My_Folder/Subfolder"
}

function __show_command_arguments() {
  echo "  command arguments:"
  echo "    ALF_PATH   A QName path to some object in Alfresco."
  echo
}

# command local options

__process_options $@

# shift away parsed args
shift $((OPTIND-1))

ALF_PATH=$1

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
  echo "  alf path: $ALF_PATH"
fi

if [[ "$ALF_PATH" == "" ]]
then
  echo "an alfresco path is required"
  exit 1
fi

# use a search to retrieve the company home noderef
$ALFTOOLS_BIN/alfSearch.sh -p nodeRef "PATH:\"$ALF_PATH\""




