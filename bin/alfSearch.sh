#!/bin/bash
#set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

function __show_command_options() {
  echo "  command options:"
  echo "    no command specific options"
  echo
}

# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    SEARCHTERM       an Alfresco search term"
}


# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfSearch.sh command issues a search against the Alfresco repository and prints"
  echo "    each the nodeRef of each hit."
  echo
  echo "  usage examples:"
  echo
  echo "    ./alfSearch.sh 'this is fun'"
  echo "       --> executes a full text search for 'this is fun'"
  echo "    ./alfSearch.sh 'TYPE:"myns:mydoctype"' | wc -l"
  echo "       --> prints the number of documents of type myns:mydoctype"
  echo
  echo "  side note about the Alfresco search and the implications of the various implementations"
  echo
  echo "    If Alfresco uses the LUCENE search backend, the result list will not be stable. This is due"
  echo "    to internal performance optimizations done by Alfresco and depends on cache filling levels and"
  echo "    system load. As a result the search will return more results on subsequence executions."
  echo
  echo "    If Alfresco is configured to use the SOLR search backend, the result list will be 'eventual consistent'"
  echo "    This simple means, the Alfresco content is indexed by a background job in an asynchronous manner and"
  echo "    and therefore will not contain all content at any point in time."
  echo "    However, the result list is stable, taking into account what is indexed so far." 
}


__process_global_options $@

# shift away parsed args
shift $((OPTIND-1))

# command arguments
ALF_SEARCHTERM=$1

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
fi

if [[ "$ALF_SEARCHTERM" == "" ]]
then
  echo "missing alfresco search term"
  exit 1
fi


