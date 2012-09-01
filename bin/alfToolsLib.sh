#
# tools library
#
# collection of shell functions useful for all commands
#
#

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

# intended to be replaced in command script by a command specific output
function __show_command_options() {
  echo "  command options:"
  echo "    no command specific options"

}

# intended to be replaced in command script
function __show_command_arguments() {
  echo "  command arguments:"
  echo "    ALFURL          pointer to an Alfesco document"
}


# intended to be replaced in command script
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
}

function help() {
  echo "usage: $0 [global options] [command specific options] arguments"
  __show_global_options
  echo
  __show_command_options
  __show_command_arguments
  echo
  __show_command_explanation
  echo
  echo "  the alfresco shell tools are created by"
  echo "    lothar.maerkle@ecm4u.de - http://www.ecm4u.de - http://www.ecm-market.de"
  echo "    anybody jumps in?"
}

#
# does url encoding, treats all parameters as a single one
#
function __encode_url_param() {
# see here for credits http://stackoverflow.com/questions/296536/urlencode-from-a-bash-script
  local string=$@
  local strlen=${#string}
  local encoded=""

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
#  echo "${encoded}"    # You can either set a return variable (FASTER) 
  ENCODED_PARAM="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

function __encode_url_path() {
# see here for credits http://stackoverflow.com/questions/296536/urlencode-from-a-bash-script
  local string=$@
  local strlen=${#string}
  local encoded=""

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [/-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
#  echo "${encoded}"    # You can either set a return variable (FASTER) 
  ENCODED_PATH="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

function __is_noderef() {
  local alfUrl=$@
  local regex="^[a-zA-Z]+://[a-zA-Z0-9]+/.*$" 

  if [[ $alfUrl =~ $regex ]]
  then
    true
  else
   false
  fi
}

function __split_noderef() {
  local nodeRef=$@

  UUID=$(echo $nodeRef | perl -pe 's|^[^:]+://[^/]+/||')
  PROTOCOL=${nodeRef%%:*}
  STORE=`echo $nodeRef | perl -pe 's|^[^:]+://([^/]+)/.*|$1|'`
}

function __process_global_options() {
  while getopts "vhE:U:P:C:" OPTNAME
  do
#  echo "OPTARG=$OPTARG OPTIND=$OPTIND OPTNAME=$OPTNAME"

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
    ?)
      help
      exit;;
  esac
  done

  # caller needs to shift away parsed arguments
}


# global options

# read environment vars
ALF_UID=$ALFTOOLS_USER
ALF_PW=$ALFTOOLS_PASSWORD
ALF_EP=$ALFTOOLS_ENDPOINT
ALF_VERBOSE=false
ALF_CURL_OPTS=$ALFTOOLS_CURL_OPTS


# init curl options. Note: -f is important to signal communication errors
if [[ "$ALF_CURL_OPTS" == "" ]]
then
  ALF_CURL_OPTS="-s -S -k -f"
fi



