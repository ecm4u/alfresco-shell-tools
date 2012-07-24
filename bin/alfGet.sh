#!/bin/bash
set -x
# param section

function __show_global_options() {
  echo "  global options:"
  echo "    -h   help       shows this help screen"
  echo "    -v   verbose    displays information while executing"
  echo 
  echo "    -E   endpoint   Alfresco endpoint"
  echo "    -U   user       Alfresco user id used in authentication"
  echo "    -P   password   password used for authenticaiton"
  echo
  echo "    -C   curl opts  any additional options pass to curl"
}

function __show_command_options() {
  echo "  command options:"
  echo "    no command specific options"
  echo "    -p   property   set the content property, defaults to cm:content"

}

function __show_command_arguments() {
  echo "  command arguments:"
  echo "    ALFURL          pointer to an Alfesco document"
}


function __show_command_explanation() {
  echo "  command explanation:"
  echo "    the alfGet.sh command downloads a file from Alfresco and prints its contents to stdout"
  echo
  echo "  usage examples:"
  echo
  echo "  ./alfGet.sh some/path/goto.pdf > goto.pdf"
  echo "     --> downloads the file goto.pdf and saves it to the local disk."
  echo "  ./alfGet.sh workspace://SpacesStore/1234-1234-123-1234 > myfile.docx"
  echo "     --> downloads the content given with the given noderef and cm:content property and saves it contents to the local file myfile.docx"
  echo "  ./alfGet.sh -p my:contentProp workspace://SpacesStore/1234-1234-1234-1234 > mycontent.pdf"
  echo "     --> downloads the content from the d:content property my:contentProp instead of cm:content"
}

function help() {
  echo "usage: $0 [global options] [command specific options] arguments"
  __show_global_options
  echo
  __show_command_options
  __show_command_arguments
  echo
  __show_command_explanation
}

# global options
ALF_UID=$ALFTOOLS_USER
ALF_PW=$ALFTOOLS_PASSWORD
ALF_EP=$ALFTOOLS_ENDPOINT
ALF_VERBOSE=false
ALF_CURL_OPTS=$ALFTOOLS_CURL_OPTS

# command local options
ALF_CONTENT_PROP=cm:content

if [[ "$ALF_CURL_OPTS" == "" ]]
then
  ALF_CURL_OPTS="-s -S -k -f"
fi

while getopts "vhE:U:P:C:" OPTNAME
do
  echo "OPTARG=$OPTARG OPTIND=$OPTIND OPTNAME=$OPTNAME"

  case $OPTNAME
  in
    h)
      help
      exit;;
    U)
      ALF_UID=$OPTARG;;
    P)
      ALF_PW=$OPTARG;;
    E)
      ALF_EP=$OPTARG;;
    C)
      ALF_CURL_OPTS=$OPTARG;;
    v)
      ALF_VERBOSE=true;;
    p)
      ALF_CONTENT_PROP=$OPTARG;;
    ?)
      help
      exit;;
  esac
done

# shift away parsed args
shift $((OPTIND-1))

# command arguments
ALF_URL=$1

if $ALF_VERBOSE
then
  ALF_CURL_OPTS="$ALF_CURL_OPTS -v"
  echo "connection params:"
  echo "  user: $ALF_UID"
  echo "  endpoint: $ALF_EP"
  echo "  curl opts: $ALF_CURL_OPTS"
fi


curl $ALF_CURL_OPTS -u $ALF_UID:$ALF_PW $ALF_EP/s/node/path/$ALF_URL






