#!/bin/bash
#set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

# intended to be replaced in command script by a command specific output
function __show_command_options() {
  echo "  command options:"
  echo "    no command specific options"

}

# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    ALF_GROUP       the unique group name. Use - to read the group name from stdin."
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfDeleteGroup.sh command deletes a group from Alfresco. The group is removed and all its"
  echo "    subgroups will become root groups. It is not a recursive group delete."
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfDeleteGroud.sh TopicProjectX"
  echo "     --> deletes the group TopicProjectX"
  echo
  echo "  ./alfDeleteGroup.sh GROUP_TopicProjectX"
  echo "     --> GROUP_ prefix is accepted too"
  echo
}


# command local options

__process_options $@

# shift away parsed args
shift $((OPTIND-1))

# command arguments, read first line from stdin if argument is -
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
  echo "  alf group: $ALF_GROUP"
fi

if [[ "$ALF_GROUP" == "" ]]
then
  echo "missing alfresco group name"
  exit 1
fi

# remove optional GROUP_ prefix
ALF_GROUP=${ALF_GROUP#GROUP_}

__encode_url_param $ALF_GROUP
ENC_GROUP=$ENCODED_PARAM
curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -X DELETE $ALF_EP/service/api/groups/$ENC_GROUP



