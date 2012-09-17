#!/bin/bash
# set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh



function __show_command_options() {
  echo "  command options:"
  echo "    -n    Alfresco user name"
  echo "    -p    Users password"
  echo "    -f    Users first name"
  echo "    -l    Users last name"
  echo "    -e    Users email"
  echo "    -g    A group name this user will become a member of. Can occur multiple times"
  echo 
}


# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfCreateUser.sh creates a local user in Alfresco. It returns a JSON dump of the newly created user object"
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfCreateUser.sh -n lothar -p pw123 -f Lothar -l Maerkle -e lothar.maerkle@ecm4u.de -g GroupA -g GroupB"
  echo "     --> creates an account for Lothar Maerkle with email lothar.maerkle@ecm4u.de. The user name will be"
  echo "         lothar with password pw123 and will become a member of the groups GroupA and GroupB."
  echo
}

ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}n:p:f:l:e:g:"
ALF_USER_NAME=""
ALF_FIRST_NAME=""
ALF_LAST_NAME=""
ALF_EMAIL=""
ALF_PASSWD=""
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
  echo "  email: $ALF_EMAIL"
fi

if [[ "$ALF_USER_NAME" == "" ]]
then
  echo "an Alfresco user name is required"
  exit 1
fi

if [[ "$ALF_FIRST_NAME" == "" ]]
then
  echo "a first name is required"
  exit 1
fi

if [[ "$ALF_LAST_NAME" == "" ]]
then
  echo "a last name is required"
  exit 1
fi

if [[ "$ALF_PASSWD" == "" ]]
then
  echo "a password is required"
  exit 1
fi

if [[ "$ALF_EMAIL" == "" ]]
then
  echo "an email is required"
  exit 1
fi

ALF_JSON=`echo '{"groups":[]}' | $ALF_JSHON -s "$ALF_LAST_NAME" -i lastName -s "$ALF_FIRST_NAME" -i firstName -s "$ALF_USER_NAME" -i userName -s "$ALF_EMAIL" -i email -s "$ALF_PASSWD" -i password -n 'false' -i disableAccount`

# set groups if any
for GRP in ${ALF_GROUPS[*]}
do
  ALF_AUTHORITY="GROUP_${GRP}"
  ALF_JSON=`echo $ALF_JSON | $ALF_JSHON -e groups -s "$ALF_AUTHORITY" -i append -p`  	
done

#echo $ALF_JSON

echo $ALF_JSON | curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -H 'Content-Type:application/json' -d@- -X POST $ALF_EP/service/api/people


#{"userName":"lodda","password":"test","firstName":"Lothar","lastName":"MÃ¤rkle","email":"lothar.maerkle@ecm4u.de","disableAccount":false,"quota":-1,"groups":[]}
#
#
#http://localhost:8080/share/proxy/alfresco/api/people

