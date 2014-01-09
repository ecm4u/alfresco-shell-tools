#!/bin/bash
# set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

# intended to be replaced in command script by a command specific output
function __show_command_options() {
  echo "  command options:"
  echo "    -s SHORT_NAME  optional, the sites short name"
  echo "    -d DESCRIPTION optional, the site description"
  echo "    -a ACCESS  optional, either 'public' or 'private'"
  echo "    -p SITE_PRESET optional, standard preset is 'site-dashboard'"
  echo
}

# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    SITE_TITLE     the main title of the site"
  echo
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfRename.sh command just renames an Alfresco node by settings its cm:name property."
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfRename.sh {nodeRef} newName"
  echo "     --> renames the item to 'newName'"
  echo
  
}


# command local options
ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}s:d:a:p:"
ALF_SITE_SHORT_NAME=""
ALF_SITE_DESCRIPTION=""
ALF_SITE_VISIBILITY="PUBLIC"
ALF_SITE_PRESET="site-dashboard"
ALF_SITE_TITLE=""

function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME
  in
    s)
      ALF_SITE_SHORT_NAME=$OPTARG;;
    d)
      ALF_SITE_DESCRIPTION="$OPTARG";;
    a)
      ALF_SITE_VISIBILITY=$OPTARG;;
    p)
      ALF_SITE_PRESET=$OPTARG;;
  esac
}

__process_options "$@"

# shift away parsed args
shift $((OPTIND-1))

# command arguments,
ALF_URL=$1
ALF_NEWNAME=$2

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
fi

# parameter check
if [[ "$ALF_URL" == "" ]]
then
  echo "a noderef is required"
  exit 1
fi

if [[ "$ALF_NEWNAME" == "" ]]
then
  echo "a new name is required"
  exit 1
fi


# craft json body
ALF_JSON=`echo '{ "properties" : {} }' | $ALF_JSHON -e properties -s "$ALF_NEWNAME" -i "cm:name" -p`
echo $ALF_JSON
if __is_noderef $ALF_URL
then
  __split_noderef $ALF_URL
  __encode_url_param $UUID
  ENC_UUID=$ENCODED_PARAM
  __encode_url_param $STORE
  ENC_STORE=$ENCODED_PARAM
  __encode_url_param $PROTOCOL
  ENC_PROTOCOL=$ENCODED_PARAM

  echo "$ALF_JSON" | curl $ALF_CURL_OPTS -H "Content-Type: application/json" -u $ALF_UID:$ALF_PW -d@- -X POST $ALF_EP/service/api/metadata/node/$ENC_PROTOCOL/$ENC_STORE/$ENC_UUID
else
  echo "ERROR: only noderefs are supported"
  exit 1
fi







