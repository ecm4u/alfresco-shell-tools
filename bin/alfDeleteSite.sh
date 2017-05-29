#!/bin/bash
# set -x

# Tue May 23 13:19:19 CEST 2017
# spd@daphne.cps.unizar.es
# Make it work with CSRF enabled Alfresco 5.x

# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh


# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    SITE_SHORT_NAME     the site short name"
  echo
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfDeleteSite.sh removes a site and its contents from Alfresco"
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfDeleteSite.sh oldsite"
  echo "     --> the site with the short name 'oldsite' is removed."
  echo
  
}

__process_options "$@"

# shift away parsed args
shift $((OPTIND-1))

# command arguments,
ALF_SITE_SHORT_NAME=$1

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
  echo "  site short name: $ALF_SITE_SHORT_NAME"
fi

# parameter check
if [[ "$ALF_SITE_SHORT_NAME" == "" ]]
then
  echo "a sites short name is required"
  exit 1
fi


ALF_JSON=`echo '{}' | $ALF_JSHON -s "$ALF_SITE_SHORT_NAME" -i shortName`

# get a valid share session id
__get_share_session_id
ALF_SESSIONID=$ALF_SHARE_SESSIONID

ALF_CSRF=`echo "$ALF_JSON" |\
curl $ALF_CURL_OPTS -v \
-H "Content-Type: application/json; charset=UTF-8" \
--cookie JSESSIONID="$ALF_SESSIONID" \
-d@- -X POST $ALF_SHARE_EP/service/modules/delete-site 2>&1 | \
sed -e '/Alfresco-CSRFToken/!d' -e 's/^.*Token=//' -e 's/; .*//g'`

__ALF_CSRF_DECODED=`echo "$ALF_CSRF" | __htd`

ALF_SERVER=`echo "$ALF_SHARE_EP" | sed -e 's,/share,,'`


# using the share api, all components are removed as well

echo "$ALF_JSON" |\
curl $ALF_CURL_OPTS -v \
-H "Content-Type: application/json; charset=UTF-8" \
-H "Origin: $ALF_SERVER" \
-H "Alfresco-CSRFToken: $ALF_CSRF_DECODED" \
-e $ALF_SHARE_EP/service/modules/delete-site \
--cookie JSESSIONID="${ALF_SESSIONID}; Alfresco-CSRFToken=$ALF_CSRF" \
-d@- \
-X POST \
$ALF_SHARE_EP/service/modules/delete-site?"$ALF_CSRF_DECODED"









