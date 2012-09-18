#!/bin/bash
#set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

function __show_command_options() {
  echo "  command options:"
  echo "    -g    just groups"
  echo "    -u    just users"
  echo
}

# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    ALF_GROUP       a full Alfresco group name (GROUP_)"
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfListGroupMembers.sh command lists all members of an Alfresco Group"
  echo
}


# command local options
# command option defaults
ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}gu"
ALF_SHOW_USERS=true
ALF_SHOW_GROUPS=true

function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME
  in
    g)
      ALF_SHOW_USERS=false;;
    u)
      ALF_SHOW_GROUPS=false;;
  esac
}


__process_options $@

# shift away parsed args
shift $((OPTIND-1))

ALF_GROUP=$1

if [[ "$ALF_GROUP" == "" ]]
then
  echo "a group name is required"
  exit 1
fi

# remove optional GROUP_ prefix
ALF_GROUP=${ALF_GROUP#GROUP_}



if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
  echo "  alf group: $ALF_GROUP"
  echo "  users: $ALF_SHOW_USERS"
  echo "  groups: $ALF_SHOW_GROUPS"
fi

__encode_url_param $ALF_GROUP
ENC_GROUP=$ENCODED_PARAM

ALF_API_URI="/service/api/groups/$ENC_GROUP/children"
echo $ALF_SHOW_USERS
echo $ALF_SHOW_GROUPS
if [[ $ALF_SHOW_GROUPS == true]]
then
  ALF_API_URI="/service/api/groups/$ENC_GROUP/children?authorityType=GROUP"
fi

if [[ $ALF_SHOW_USERS == true ]]
then
  ALF_API_URI="/service/api/groups/$ENC_GROUP/children?authorityType=USER"
fi


curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW "$ALF_EP$ALF_API_URI" | $ALF_JSHON -Q -e data -a -e fullName -u

