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
  echo "    -a ACCESS  optional, either 'PUBLIC' or 'PRIVATE'"
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
  echo "    the alfCreateSite.sh command let you create a site from the command line."
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfCreateSite.sh NewSite"
  echo "     --> creates a new site named 'NewSite' with public visibility"
  echo
  echo "  ./alfCreateSite.sh -s private-site -d 'Site Description' -a PRIVATE 'Site Title'"
  echo "     --> creates a new site named 'private-site' with private visibility"
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
ALF_SITE_TITLE=$1

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
  echo "  site title: $ALF_SITE_TITLE"
  echo "  site desc:  $ALF_SITE_DESCRIPTION"
  echo "  site visibility: $ALF_SITE_VISIBILITY"
  echo "  site preset: $ALF_SITE_PRESET"
  echo "  site short name: $ALF_SITE_SHORT_NAME"
fi

# parameter check
if [[ "$ALF_SITE_TITLE" == "" ]]
then
  echo "a site title is required"
  exit 1
fi


if [[ "$ALF_SHORT_NAME" == "" ]]
then
  # fiddle to create a somewhat nice short name
  TMP_SHORT_NAME=`echo -n "$ALF_SITE_TITLE" | perl -pe 's/[^a-z0-9]/_/gi' | tr '[:upper:]' '[:lower:]'`
  ALF_SITE_SHORT_NAME=${TMP_SHORT_NAME}
fi

# craft json body
ALF_JSON=`echo '{}' | $ALF_JSHON -s "$ALF_SITE_TITLE" -i title -s "$ALF_SITE_SHORT_NAME" -i shortName -s "$ALF_SITE_VISIBILITY" -i visibility -s "$ALF_SITE_DESCRIPTION" -i description -s "$ALF_SITE_PRESET" -i sitePreset`

echo "$ALF_JSON" | curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -H "Content-Type: application/json" -d@- -X POST $ALF_EP/service/api/sites
