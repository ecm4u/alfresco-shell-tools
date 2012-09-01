#!/bin/bash
#set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

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






