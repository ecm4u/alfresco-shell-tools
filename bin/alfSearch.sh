#!/bin/bash
#set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

function __show_command_options() {
  echo "  command options:"
  echo "    -p property name    which property of each search result node should be printed to stdout."
  echo "                        Possible values are nodeRef(default), name, path, type, displayName, title,"
  echo "                        description, modifiedOn, modifiedBy, modifiedByUser, size, mimetype, path"
  echo "    -m [property|json]  output mode: 'property' (default) prints the value of the property given by -p."
  echo "                        Mode 'json' prints the whole result set as a json object."
  echo
}

# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    SEARCHTERM       an Alfresco search term"
}


# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfSearch.sh command issues a search against the Alfresco repository and prints"
  echo "    each the nodeRef of each hit."
  echo
  echo "  usage examples:"
  echo
  echo "    ./alfSearch.sh 'this is fun'"
  echo "       --> executes a full text search for 'this is fun'"
  echo "    ./alfSearch.sh 'TYPE:"myns:mydoctype"' | wc -l"
  echo "       --> prints the number of documents of type myns:mydoctype"
  echo
  echo "  side note about the Alfresco search and the implications of the various implementations"
  echo
  echo "    If Alfresco uses the LUCENE search backend, the result list will not be stable. This is due"
  echo "    to internal performance optimizations done by Alfresco and depends on cache filling levels and"
  echo "    system load. As a result the search will return more results on subsequence executions."
  echo
  echo "    If Alfresco is configured to use the SOLR search backend, the result list will be 'eventual consistent'"
  echo "    This simple means, the Alfresco content is indexed by a background job in an asynchronous manner and"
  echo "    and therefore will not contain all content at any point in time."
  echo "    However, the result list is stable, taking into account what is indexed so far." 
}


# command option defaults
ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}p:m:"
ALF_PROPERTY="nodeRef"
# output mode is either property or the full json output
ALF_OUTPUT_MODE="property"

function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME
  in
    p)
      ALF_PROPERTY=$OPTARG;;
    m)
      ALF_OUTPUT_MODE=$OPTARG;;
  esac
}

__process_options $@

# shift away parsed args
shift $((OPTIND-1))


# command arguments
ALF_SEARCHTERM=$1


if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
  echo "  property: $ALF_PROPERTY"
  echo "  output mode: $ALF_OUTPUT_MODE"
fi

if [[ "$ALF_SEARCHTERM" == "" ]]
then
  echo "missing alfresco search term"
  exit 1
fi


__encode_url_param $ALF_SEARCHTERM
ENC_TERM=$ENCODED_PARAM

__encode_url_param 'workspace://SpacesStore/company/home'
ENC_ROOT_NODE=$ENCODED_PARAM

if [[ "$ALF_OUTPUT_MODE" == "property" ]]
then
  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW "$ALF_EP/service/slingshot/search?site=&term=$ENC_TERM&repo=true&rootNode=$ENC_ROOT_NODE" | $ALF_JSHON -Q -e items -a -e $ALF_PROPERTY -u
elif [[ "$ALF_OUTPUT_MODE" == "json" ]]
then
  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW "$ALF_EP/service/slingshot/search?site=&term=$ENC_TERM&repo=true&rootNode=$ENC_ROOT_NODE"
else
  echo "invalid output mode: $ALF_OUTPUT_MODE"
  exit 1
fi

exit
GET /alfresco/s/slingshot/search?site=&term=node&tag=&maxResults=251&sort=cm%3Aname&query=&repo=true&rootNode=alfresco%3A%2F%2Fcompany%2Fhome&alf_ticket=TICKET_58b09f1c0de7c7e114dd5cf3104bf2fec8e26d5a HTTP/1.1
connection: keep-alive
x-requested-with: XMLHttpRequest
user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.82 Safari/537.1
accept: */*
referer: http://localhost:8080/share/page/search?t=node&s=cm:name&a=true&r=true
accept-encoding: gzip,deflate,sdch
accept-language: en-US,en;q=0.8
ccept-charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3
Host: localhost:8080

HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
Cache-Control: no-cache
Expires: Thu, 01 Jan 1970 00:00:00 GMT
Pragma: no-cache
Content-Type: application/json;charset=UTF-8
Transfer-Encoding: chunked
Date: Sun, 02 Sep 2012 08:41:22 GMT

2000
{
."items":
.[
..{
..."nodeRef": "workspace:\/\/SpacesStore\/373cea25-5933-405c-bf97-347e9bbb099c",
..."type": "document",
..."name": "activities-email_de.ftl",
..."displayName": "activities-email_de.ftl",
..."title": "activities-email_de.ftl",
..."description": "Email template used to generate the activities email for Alfresco Share - German version",
..."modifiedOn": "2012-08-31T09:04:10.071+02:00",
..."modifiedByUser": "System",
..."modifiedBy": "",
..."size": 8948,
..."mimetype": "text\/plain",
..."path": "\/Company Home\/Data Dictionary\/Email Templates\/activities",
..."tags": []
..},
