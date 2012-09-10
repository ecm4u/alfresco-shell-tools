#!/bin/bash
# set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfNodeRef2Path.sh maps a nodeRef to an Alfresco QName Path"
  echo "    A QName path is prefixed with a namespace: /app:company_home/cm:testfolder/cm:testfile.pdf"
}

function __show_command_arguments() {
  echo "  command arguments:"
  echo "    ALF_NODEREF   A nodeRef of Alfresco."
  echo
}

# command local options

__process_options $@

# shift away parsed args
shift $((OPTIND-1))

ALF_NODEREF=$1

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
  echo "  alf noderef: $ALF_NODEREF"
fi

if [[ "$ALF_NODEREF" == "" ]]
then
  echo "an alfresco noderef is required"
  exit 1
fi

__encode_url_param $ALF_NODEREF
ENC_REF=$ENCODED_PARAM
__split_noderef $ALF_NODEREF
ALF_STORE="$PROTOCOL://$STORE"
__encode_url_param $ALF_STORE
ENC_STORE=$ENCODED_PARAM

curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW "$ALF_EP/service/slingshot/node/search?q=$ENC_REF&lang=noderef&store=$ENC_STORE" | $ALF_JSHON -Q -e results -e 0 -e qnamePath -e prefixedName -u





