#!/bin/bash
# alfCreateCalendarEntry.sh -- A script to create a site calendar entry
# Copyright (C) 2014  Eric MSP Veith <eric.veith@wb-fernstudium.de>

# Source function library:
ALFTOOLS_BIN=`dirname "$0"`
. $ALFTOOLS_BIN/alfToolsLib.sh

ALF_CMD_OPTIONS="${ALF_GLOBAL_OPTIONS}f:u:s:t:d:a"
ALF_SITE_NAME=
ALF_EVENT_TITLE=
ALF_EVENT_DESCRIPTION=
ALF_EVENT_LOCATION=
ALF_EVENT_START=
ALF_EVENT_END=
ALF_EVENT_ALLDAY=0


function __show_command_options() {
    echo "  Parameters:"
    echo "  "
    echo "      -s      Site name (Shortname)"
    echo "      -t      Event title"
    echo "      -d      Event description"
    echo "      -l      Event location"
    echo "      -f      Start date and time in ISO format (From)"
    echo "      -u      End date and time in ISO format (Until)"
    echo "      -a      All-day event"
}


function __show_command_explanation() {
    echo "  Usage: $0 -f START -u END -s SITE -t TITLE [-d DESCRIPTION] [-a]"
    echo "  "
    echo "      Creates a new calendar event with given title in the designated site."
    echo "      All dates/times must be given in ISO format, i.e. %YYYY-%mm-%ddT%HH-%MMZ."
    echo "      The event can optionally be marked as an all-day event."
}


function __process_cmd_option() {
  local OPTNAME=$1
  local OPTARG=$2

  case $OPTNAME in
      s)
          ALF_SITE_NAME=$OPTARG ;;
      t)
          ALF_EVENT_TITLE=$OPTARG ;;
      d)
          ALF_EVENT_DESCRIPTION=$OPTARG ;;
      l)
          ALF_EVENT_LOCATION=$OPTARG ;;
      f)
          ALF_EVENT_START=$OPTARG ;;
      u)
          ALF_EVENT_END=$OPTARG ;;
      a)
          ALF_EVENT_ALLDAY=1 ;;
      *)
          ;;
  esac
}

__process_options "$@"

# Check for mandatory arguments:

if [ -z "$ALF_SITE_NAME" ]; then
    echo >&2 "ERROR: No site name given."
    exit 1
fi

if [ -z "$ALF_EVENT_TITLE" ]; then
    echo >&2 "ERROR: No event title given."
    exit 1
fi

if [ -z "$ALF_EVENT_START" ]; then
    echo >&2 "ERROR: No event start time."
    exit 1
fi

if [ -z "$ALF_EVENT_END" ]; then
    echo >&2 "ERROR: No event end time."
    exit 1
fi

# Get a valid share session ID:

__get_share_session_id
ALF_SESSIONID=$ALF_SHARE_SESSIONID

# Craft JSON and CURL string:

ALF_JSON=$(echo '{}' | $ALF_JSHON \
    -s "$ALF_SITE_NAME" -i site \
    -s "$ALF_EVENT_TITLE" -i what \
    -s "$ALF_EVENT_DESCRIPTION" -i desc \
    -s "$ALF_EVENT_END" -i endAt \
    -s "$ALF_EVENT_START" -i startAt \
    -s calendar -i page \
    -s "" -i docfolder \
    -s "" -i where)

if [ $ALF_EVENT_ALLDAY = 1 ]; then
    ALF_JSON=$(echo $ALF_JSON | $ALF_JSHON -s on -i allday)
fi

echo $ALF_JSON
echo $ALF_JSON | curl \
    $ALF_CURL_OPTS \
    -H "Content-Type: application/json" \
    --cookie JSESSIONID="$ALF_SESSIONID" \
    -d@- \
    -X POST \
    "$ALF_SHARE_EP/proxy/alfresco/calendar/create"
