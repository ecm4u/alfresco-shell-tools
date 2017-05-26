#!/bin/bash
# set -x

# Fri Oct  2 11:09:52 CEST 2015
# spd@daphne.cps.unizar.es
# Make it work with CSRF enabled Alfresco 5.x

# spd: fixed bug: supplied short name is ignored
# spd: visibility defaults to "private"
# spd: add some cookies (alfLogin, alfUsername3, others supplied by server)
# spd: read and use Alfresco-CSRFToken
# spd: add "Referer" and "Origin" HTTTP headers
# spd: add "isPublic" attribute to JSON
# spd: cosmetic changes in source code (split some long lines)


# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

# intended to be replaced in command script by a command specific output
function __show_command_options() {
  echo "  command options:"
  echo "    -s SHORT_NAME  optional, the sites short name"
  echo "    -d DESCRIPTION optional, the site description"
  echo "    -a ACCESS  optional, either 'public', 'moderated'  or 'private'"
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
  echo "     --> creates a new site named 'NewSite' with private visibility"
  echo
  
}


# command local options
ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}s:d:a:p:"
ALF_SITE_SHORT_NAME=""
ALF_SITE_DESCRIPTION=""
ALF_SITE_VISIBILITY="PUBLIC"
ALF_SITE_ISPUBLIC="true"
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
	  case "_$OPTARG" in
	  	"_public")
			ALF_SITE_VISIBILITY="PUBLIC"
	        ALF_SITE_ISPUBLIC="true"
			;;
	  	"_moderated")
			ALF_SITE_VISIBILITY="MODERATED"
	        ALF_SITE_ISPUBLIC="true"
			;;
		*)
			ALF_SITE_VISIBILITY="PRIVATE"
	        ALF_SITE_ISPUBLIC="false"
		    ;;
	  esac
	  ;;
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
  echo "  site isPublic: $ALF_SITE_ISPUBLIC"
  echo "  site preset: $ALF_SITE_PRESET"
  echo "  site short name: $ALF_SITE_SHORT_NAME"
fi

# parameter check
if [ "_$ALF_SITE_TITLE" = "_" ]
then
  echo "a site title is required"
  exit 1
fi


if [ "_$ALF_SITE_SHORT_NAME" = "_" ]
then
  # fiddle to create a somewhat nice short name
  TMP_SHORT_NAME=`echo -n "$ALF_SITE_TITLE" | perl -pe 's/[^a-z0-9]/_/gi' | tr '[:upper:]' '[:lower:]'`
  ALF_SITE_SHORT_NAME=${TMP_SHORT_NAME}
fi

# craft json body
ALF_JSON=`echo '{}' |\
$ALF_JSHON \
-s "$ALF_SITE_TITLE" -i title \
-s "$ALF_SITE_SHORT_NAME" -i shortName \
-s "$ALF_SITE_DESCRIPTION" -i description \
-s "$ALF_SITE_PRESET" -i sitePreset \
-s "$ALF_SITE_VISIBILITY" -i visibility \
-n "$ALF_SITE_ISPUBLIC" -i isPublic`


# get a valid share session id
__get_share_session_id
ALF_SESSIONID="$ALF_SHARE_SESSIONID"


ALF_CSRF=`echo "$ALF_JSON" |\
curl $ALF_CURL_OPTS -v \
-H "Content-Type: application/json; charset=UTF-8" \
--cookie JSESSIONID="$ALF_SESSIONID" \
-d@- -X POST $ALF_SHARE_EP/service/modules/create-site 2>&1 | \
sed -e '/Alfresco-CSRFToken/!d' -e 's/^.*Token=//' -e 's/; .*//g'`

ALF_CSRF_DECODED=`echo "$ALF_CSRF" | __htd`

ALF_SERVER=`echo "$ALF_SHARE_EP" | sed -e 's,/share,,'`

echo "$ALF_JSON" |\
curl $ALF_CURL_OPTS -v \
-H "Content-Type: application/json; charset=UTF-8" \
-H "Origin: $ALF_SERVER" \
-H "Alfresco-CSRFToken: $ALF_CSRF_DECODED" \
-e $ALF_SHARE_EP/service/modules/create-site \
--cookie JSESSIONID="${ALF_SESSIONID}; Alfresco-CSRFToken=$ALF_CSRF" \
-d@- \
-X POST \
$ALF_SHARE_EP/service/modules/create-site?"$ALF_CSRF_DECODED"


#
#{"visibility":"PUBLIC","title":"OtherSite","shortName":"othersite","description":"other site descrpiption","sitePreset":"site-dashboard"}#upload webscript parameter description:







