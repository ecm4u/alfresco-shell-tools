#!/bin/bash
# alfListCalendarEntries.sh -- A script to list entries of a site calendar
# Copyright (C) 2014  Eric MSP Veith <eric.veith@wb-fernstudium.de>

# Source function library:
ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}f:u:t"
ALF_SITE_NAME=
ALF_START_DATE=
ALF_END_DATE=
OUTPUT_FILTER=cat


function __show_command_options() {
    echo "  Command Parameters:"
    echo "  "
    echo "  -f DATE     Start outputting events at DATE (must be given in ISO format)"
    echo "  -u DATE     Output events until DATE (must be given in ISO format)"
    echo "  -t          Output as table instead of tab-separated values"
}


function __show_command_explanation() {
    echo "  Usage: $0 [-f START DATE] [-u END DATE] [-t] SITE"
    echo "  "
    echo "  Lists all calendar entries of a given site, SITE."
}


function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME in
      f)
          ALF_START_DATE=$OPTARG ;;
      u)
          ALF_END_DATE=$OPTARG ;;
      t)
          OUTPUT_FILTER="column -t -s\\t" ;;
      *)
          ;;
  esac
}


__process_options "$@"


# Check for mandatory arguments:

shift $((OPTIND-1))
ALF_SITE_NAME=$1

if [ -z "$ALF_SITE_NAME" ]; then
    echo >&2 "ERROR: No site name given."
    exit 1
fi

# Get a valid share session ID:

__get_share_session_id
ALF_SESSIONID=$ALF_SHARE_SESSIONID

# Pierce together URI string:

startdate=
enddate=

if [ "$ALF_START_DATE" ]; then
    startdate="&from=${ALF_START_DATE}"
fi

if [ "$ALF_END_DATE" ]; then
    enddate="&to=${ALF_END_DATE}"
fi

uri="$ALF_SHARE_EP/proxy/alfresco/calendar/events/\
${ALF_SITE_NAME}/user?repeating=all${startdate}${enddate}"

events=$(echo $ALF_JSON | curl \
    $ALF_CURL_OPTS \
    -H "Content-Type: application/json" \
    --cookie JSESSIONID="$ALF_SESSIONID" \
    -d@- \
    -X GET \
    "$uri" | $ALF_JSHON -e events)
events_length=$(echo $events | $ALF_JSHON -l)

for ((i=0; i != events_length; ++i)); do
    event=$(echo $events | $ALF_JSHON -e $i)
    name=$(echo $event | $ALF_JSHON -e name)
    title=$(echo $event | $ALF_JSHON -e title)
    location=$(echo $event | $ALF_JSHON -e where)
    description=$(echo $event | $ALF_JSHON -e description)
    startat=$(echo $event | $ALF_JSHON -e startAt -e iso8601)
    endat=$(echo $event | $ALF_JSHON -e endAt -e iso8601)

    echo -e "$name\t$title\t$startat\t$endat\t$location\t$description"
done | $OUTPUT_FILTER
