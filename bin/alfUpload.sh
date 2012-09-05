#!/bin/bash
# set -x
# param section

# source function library

ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

# intended to be replaced in command script by a command specific output
function __show_command_options() {
  echo "  command options:"
  echo "    -n NAME        filename to use for Alfresco"
  echo "    -m MIMETYPE    mime type of the added file"
}

# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    LOCAL_FILE      path to a local file, or - to read contents from stdin."
  echo "    ALFURL          pointer to an Alfesco document."
}

# intended to be replaced in command script
function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfUpload.sh command adds content to Alfresco. If there is already a document, its contents will be updated."
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfUpload.sh ./local/file.pdf /some/repo/path/to/space"
  echo "     --> uploads the local file at ./local/file.pdf to the space /some/repo/path/to/space"
  echo
  echo "  ./alfUpload.sh ./local/file.pdf workspace://SpacesStore/1234-1234-1234-1234"
  echo "     --> uplodas the local file at ./local/file.pdf to the space given by the nodeRef"
  echo
  echo "  cat sth.pdf | ./alfUpload.sh -n "filename.pdf" - /some/repo/path/to/space"
  echo "     --> uploads content read from stdin and saves it to a file at /some/repo/path/to/space/filename.pdf"
  
}


# command local options
ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}n:m:"
ALF_CONTENT_PROP=cm:content
ALF_FILENAME=""
ALF_CONTENT_TYPE="cm:content"
ALF_MIMETYPE=""

function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME
  in
    n)
      ALF_FILENAME=$OPTARG;;
  esac
}

__process_options $@

# shift away parsed args
shift $((OPTIND-1))

# command arguments,
ALF_LOCAL_FILE=$1
ALF_URL=$2

# parameter check
if [[ "$ALF_FILENAME" == "" && "$ALF_LOCAL_FILE" == "-" ]]
then
  echo "option -n is required if contents are read from stdin"
  exit 1
fi

# use locals file name as name in alfresco if -n option is not used
if [[ "$ALF_FILENAME" == "" ]]
then
  ALF_FILENAME=`basename "$ALF_LOCAL_FILE"`
fi

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
  echo "  local file: $ALF_LOCAL_FILE"
  echo "  alf filename: $ALF_FILENAME"
  echo "  alf url: $ALF_URL"
fi

if [[ "$ALF_URL" == "" ]]
then
  echo "missing alfresco url"
  exit 1
fi

if [[ "$ALF_MIMETYPE" != "" ]]
then
  ALF_MT_ARG=";type=$ALF_MIMETYPE"
else
  ALF_MT_ARG=""
fi

if __is_noderef $ALF_URL
then
  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW  --form "filedata=@$ALF_LOCAL_FILE;filename=${ALF_FILENAME}${ALF_MT_ARG}" --form "destination=$ALF_URL" $ALF_EP/service/api/upload | $ALF_JSHON -e nodeRef -u
else
  ALF_COMPANY_HOME_REF=`$ALFTOOLS_BIN/alfGetCompanyHomeNodeRef.sh`

  curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW  --form "filedata=@$ALF_LOCAL_FILE;filename=${ALF_FILENAME}${ALF_MT_ARG}" --form "destination=$ALF_COMPANY_HOME_REF" --form "uploaddirectory=$ALF_URL" $ALF_EP/service/api/upload | $ALF_JSHON -e nodeRef -u

fi



exit

#
#upload webscript parameter description:
#
#UPDATE
#updatenoderef: (required) used to update the contents of an existing node known by its noderef
#description: (optional) used with updatenoderef, only used if updatenoderef is set and a new version is generated. it is the check in comment. it is not the cm:description field
#majorversion: (optional, defaults to false) used with updatenoderf / used to create a new version


#CREATE in repo
#destination: (required)a noderef which becomes the parent of the newly created/updated node
#aspects: (optional) comma separeted list of aspects to add to the newly created or updated node
#contentype: (optional)set the alfresco type on new node creation
#uploaddirectory: (optional) a name path anchored from the noderef given by destination. can be used to set the parent by name path
#overwrite: (optional) replace the exiting node if any - only evaluated if the node has the cm:versionable aspect

#ALL
#filedata: (required) file contents, form field parameter 'filename' is required to set the filename, form field parameter type is optional used to set the mimetype












