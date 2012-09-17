#!/bin/bash
# set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh


# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    ALF_GROUP_NAME      an Alfresco group name."
  echo "    ALF_AUTHORITY_NAME  an Alfresco authority name. Either a user id or a full group name"
  echo "                        prefixed with GROUP_"
  echo
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfDeleteAuthorityToGroup.sh adds a user or a group to an existing group."
  echo
  echo "  usage examples:"
  echo
  echo "  alfDeleteAuthoritytoGroup.sh GroupA user123"
  echo "     --> Remove the user user123 as a member of the group GroupA"
  echo
  echo "  alfDeleteAuthoritytoGroup.sh ParentGroup GROUP_subgroup"
  echo "     --> remove the group subgroup as a sub group of the group ParentGroup" 
  echo
}

ALF_GROUP=""
ALF_AUTHORITY_NAME=""
ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}"

__process_options "$@"

# shift away parsed args
shift $((OPTIND-1))

ALF_GROUP=$1
ALF_AUTHORITY_NAME=$2


if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
  echo "  group name: $ALF_GROUP"
  echo "  authority name: $ALF_AUTHORITY_NAME"
fi

if [[ "$ALF_GROUP" == "" ]]
then
  echo "a group name is required"
  exit 1
fi

if [[ "$ALF_AUTHORITY_NAME" == "" ]]
then
  echo "an authority name is required"
  exit 1
fi

# remove optional GROUP_ prefix
ALF_GROUP=${ALF_GROUP#GROUP_}

#echo $ALF_JSON

__encode_url_param $ALF_GROUP
ENC_GROUP=$ENCODED_PARAM
__encode_url_param $ALF_AUTHORITY_NAME
ENC_AUTHORITY=$ENCODED_PARAM

curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -H 'Content-Type:application/json' -X DELETE "$ALF_EP/service/api/groups/$ENC_GROUP/children/$ENC_AUTHORITY"


