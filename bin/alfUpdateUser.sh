#!/bin/bash
# set -x
# param section

# This version: Mon Jul 17 14:13:00 CEST 2017
# spd@daphne.cps.unizar.es
# Add -o -a options

# Script to get users for a site
# Status: working against alfresco-5.1.e with CSRF protection enabled (default)

# Requires alfToolsLib.sh
# Requires jshon

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh



function __show_command_options() {
  echo "  command options:"
  echo "    -n    Alresco use id"
  echo "    -f    Users first name"
  echo "    -l    Users last name"
  echo "    -e    Users email"
  echo "    -o    Users organization"
  echo "    -a    Disable Account true|false"
  echo 
}


# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfUpdateUser.sh scripts updates the core user properties like first and last name"
  echo
  echo "  usage examples:"
  echo "    alfUpateUser.sh -n lothar -f Lodda"
  echo "        ---> Changes the first name of the user 'lothar' to 'Lodda'"
  echo 
}

ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}n:p:f:l:e:g:a:o:"
ALF_USER_NAME=""
ALF_FIRST_NAME=""
ALF_LAST_NAME=""
ALF_EMAIL=""
ALF_ORG=""
ALF_PASSWD=""
ALF_ENABLE=""
ALF_GROUPS=()

function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME
  in
    n)
      ALF_USER_NAME=$OPTARG;;
    f)
      ALF_FIRST_NAME=$OPTARG;;
    l)
      ALF_LAST_NAME=$OPTARG;;
    e)
      ALF_EMAIL=$OPTARG;;
    p)
      ALF_PASSWD=$OPTARG;;
    o)
      ALF_ORG=$OPTARG;;
    a)
      ALF_ENABLE=$OPTARG;;
    g)
      ALF_GROUPS=("${ALF_GROUPS[@]}" $OPTARG);;
  esac
}

__process_options "$@"

# shift away parsed args
shift $((OPTIND-1))

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
  echo "  user name: $ALF_USER_NAME"
  echo "  first name: $ALF_FIRST_NAME"
  echo "  last name: $ALF_LAST_NAME"
  echo "  enable: $ALF_ENABLE"
  echo "  email: $ALF_EMAIL"
fi

ALF_JSON='{}'

if [[ "$ALF_USER_NAME" == "" ]]
then
  echo "an Alfresco user name is required"
  exit 1
fi

if [[ "$ALF_FIRST_NAME" != "" ]]
then
  ALF_JSON=`echo "$ALF_JSON"| $ALF_JSHON -s "$ALF_FIRST_NAME" -i firstName`
fi

if [[ "$ALF_LAST_NAME" != "" ]]
then
  ALF_JSON=`echo "$ALF_JSON"| $ALF_JSHON -s "$ALF_LAST_NAME" -i lastName`
fi

if [[ "$ALF_EMAIL" != "" ]]
then
  ALF_JSON=`echo "$ALF_JSON"| $ALF_JSHON -s "$ALF_EMAIL" -i email`
fi

if [[ "$ALF_ENABLE" != "" ]]
then
  ALF_JSON=`echo "$ALF_JSON"| $ALF_JSHON -n "$ALF_ENABLE" -i disableAccount`
fi

if [[ "$ALF_ORG" != "" ]]
then
  ALF_JSON=`echo "$ALF_JSON"| $ALF_JSHON -n "$ALF_ORG" -i organization`
fi


if [[ "$ALF_JSON" == "{}" ]]
then
  echo "at least first name, last name or email as to be set."
  exit 1
fi

# TODO Groups

# set groups if any
for GRP in ${ALF_GROUPS[*]}
do
  ALF_AUTHORITY="GROUP_${GRP}"
  ALF_JSON=`echo $ALF_JSON | $ALF_JSHON -e groups -s "$ALF_AUTHORITY" -i append -p`  	
done

#echo $ALF_JSON

__encode_url_param $ALF_USER_NAME
ALF_ENC_UID=$ENCODED_PARAM


echo $ALF_JSON | curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -H 'Content-Type:application/json' -d@- -X PUT $ALF_EP/service/api/people/$ALF_ENC_UID


#{"userName":"lodda","password":"test","firstName":"Lothar","lastName":"MÃ¤rkle","email":"lothar.maerkle@ecm4u.de","disableAccount":false,"quota":-1,"groups":[]}
#
#
#http://localhost:8080/share/proxy/alfresco/api/people

