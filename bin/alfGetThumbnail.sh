#!/bin/bash
#set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

# intended to be replaced in command script by a command specific output
function __show_command_options() {
  echo "  command options:"
  echo "    -t thumbnail type  optional, one of doclib, medium, webpreview, imgpreview, avatar, avatar32"
  echo "                       or any name of a registered thumbnail definition. The default value is doclib."
  echo "    -f                 force generation of thumbnail"
  echo
}

# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    ALF_NODEREF       the unique user name of an Alfresco user. Use - to read the user id from stdin."
  echo
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfGetThumbnail.sh prints the thumbnail (rendition) to stdout. If the thumbnail is not available the"
  echo "    script will exit with an error."
  echo "    Using the -f(orce) option will make Alfresco to generate the thumbnial on the fly if the thumbnail has not"
  echo "    been generated before"
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfGetThumbnail.sh workspace://SpacesStore/uuuu-uuuuu-iiii-ddddd > doclib.png" 
  echo "     --> saves the small thumbnail to the file doclib.png"
  echo
  echo "  ./alfGetThumbnail.sh -t webpreview workspace://SpacesStore/uuuu-uuuuu-iiii-ddddd > webpreview.png" 
  echo "     --> saves the webpreview rendition to the file webpreview.png"
  echo
}


# command local options
ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}t:f"
# defaults to the doclib thumbnail
ALF_THUMBNAIL_TYPE="doclib"
# dont force by default
ALF_FORCE=false

function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME
  in
    t)
      ALF_THUMBNAIL_TYPE=$OPTARG;;
    f)
      ALF_FORCE=true;;
  esac
}

__process_options $@

# shift away parsed args
shift $((OPTIND-1))

# command arguments, read first line from stdin if argument is -
ALF_URL=$1
if [[ "$ALF_NODEREF" == "-" ]]
then
  read line
  ALF_URL=$line
fi

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
  echo "  alf noderef: $ALF_URL"
  echo "  thumbail type: $ALF_THUMBNAIL_TYPE"
  echo "  force:  $ALF_FORCE"
fi

if [[ "$ALF_URL" == "" ]]
then
  echo "An Alfresco noderef is required"
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
  __encode_url_param $ALF_THUMBNAIL_TYPE
  ENC_THUMBNAIL_TYPE=$ENCODED_PARAM

  QUERY=""
  if $ALF_FORCE
  then
    QUERY="?c=force"
  fi
  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW $ALF_EP/service/api/node/$ENC_PROTOCOL/$ENC_STORE/$ENC_UUID/content/thumbnails/$ENC_THUMBNAIL_TYPE${QUERY}
else
  echo "just noderefs are supported"
  exit 1
fi
