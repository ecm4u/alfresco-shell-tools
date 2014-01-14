#!/bin/bash
# set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh



function __show_command_options() {
  echo "  command options:"
  echo "    -d    tenant domain"
  echo "    -p    tenant admin password"
  echo "    -c    optional tenant contentstore root directory"
  echo 
}


# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfCreateTenant.sh creates a new tenant in alfresco"
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfCreateTenant.sh -d mydomain -p pw123"
  echo "     --> creates a tenant with a tenant admin admin@mydomain with password pw123"
  echo
}

ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}d:p:c:"
ALF_TENANT_DOMAIN=""
ALF_TENANT_ADMIN_PW=""
ALF_TENANT_CONTENT_ROOT=""

function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME
  in
    d)
      ALF_TENANT_DOMAIN=$OPTARG;;
    p)
      ALF_TENANT_ADMIN_PW=$OPTARG;;
    c)
      ALF_TENANT_CONTENT_ROOT=$OPTARG;;
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
  echo "  tenant domain: $ALF_TENANT_DOMAIN"
  echo "  tenant admin password: $ALF_TENANT_ADMIN_PW"
  echo "  tenant content root: $ALF_TENANT_CONTENT_ROOT"
fi

if [[ "$ALF_TENANT_DOMAIN" == "" ]]
then
  echo "an tenant domain is required"
  exit 1
fi

if [[ "$ALF_TENANT_ADMIN_PW" == "" ]]
then
  echo "a tenant admin password is required"
  exit 1
fi

ALF_JSON=`echo '{}' | $ALF_JSHON -s "$ALF_TENANT_DOMAIN" -i tenantDomain -s  "$ALF_TENANT_ADMIN_PW" -i tenantAdminPassword`

if [[ "$ALF_TENANT_CONTENT_ROOT" != "" ]]
then
  ALF_JSON=`echo $ALF_JSON | $ALF_JSHON -s "$ALF_TENANT_CONTENT_ROOT" -i tenantContentStoreRoot`
fi

#echo $ALF_JSON

echo $ALF_JSON | curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW -H 'Content-Type:application/json' -d@- -X POST $ALF_EP/service/api/tenants


#{"userName":"lodda","password":"test","firstName":"Lothar","lastName":"MÃ¤rkle","email":"lothar.maerkle@ecm4u.de","disableAccount":false,"quota":-1,"groups":[]}
#
#
#http://localhost:8080/share/proxy/alfresco/api/people

