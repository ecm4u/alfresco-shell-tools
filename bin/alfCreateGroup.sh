#!/bin/bash
# set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

# intended to be replaced in command script by a command specific output
function __show_command_options() {
  echo "  command options:"
  echo "    -d groups display name. If this option is not used the groups name is used as the display name."
  echo "    -p parent group name if any"
  echo
}

# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    ALF_GROUP_NAME   an Alfresco group name. If - read from stdin"
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfCreateGroup.sh creates a new local group in Alfresco."
  echo
  echo "  usage examples:"
  echo
  echo "  alfCreateGroup.sh GroupA"
  echo "     --> creates the group GroupA. To add users to the group use the command alfAddMember.sh"
  echo
  echo "  alfCreateGroup.sh -p ParentGroup GroupB"
  echo "     --> adds a new group GroupB into the existing group ParentGroup" 
  echo
}

ALF_GROUP=""
ALF_PARENT_GROUP=""
ALF_DISPLAY_NAME=""
ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}p:d:"


function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME
  in
    p)
      ALF_PARENT_GROUP=$OPTARG;;
    d)
      ALF_DISPLAY_NAME=$OPTARG;;
  esac
}

__process_options "$@"

# shift away parsed args
shift $((OPTIND-1))

ALF_GROUP=$1
if [[ "$ALF_GROUP" == "-" ]]
then
  read line
  ALF_GROUP=$line
fi


if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
  echo "  group name: $ALF_GROUP"
fi

if [[ "$ALF_GROUP" == "" ]]
then
  echo "a group name is required"
  exit 1
fi

if [[ "$ALF_DISPLAY_NAME" == "" ]]
then
  ALF_DISPLAY_NAME=$ALF_GROUP
fi


#echo $ALF_JSON

__encode_url_param $ALF_GROUP
ENC_GROUP=$ENCODED_PARAM

# create group first
JSON=`echo '{}' | $ALF_JSHON -s "$ALF_DISPLAY_NAME" -i 'displayName'`
echo $JSON | curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -H 'Content-Type:application/json' -d@- -X POST "$ALF_EP/service/api/rootgroups/$ENC_GROUP"

# add as member if needed
if [[ "$ALF_PARENT_GROUP" != "" ]]
then
  $ALFTOOLS_BIN/alfAddAuthorityToGroup.sh $ALF_PARENT_GROUP "GROUP_$ALF_GROUP"
fi



  #curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -H 'Content-Type:application/json' -X POST "$ALF_EP/service/api/groups/$ENC_PARENT_GROUP/children/$ENC_GROUP"
#{"userName":"lodda","password":"test","firstName":"Lothar","lastName":"MÃ¤rkle","email":"lothar.maerkle@ecm4u.de","disableAccount":false,"quota":-1,"groups":[]}
#
#
#http://localhost:8080/share/proxy/alfresco/api/people

