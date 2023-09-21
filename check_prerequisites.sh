#!/usr/bin/env bash

# Linux formatting control sequences
TEXT_RED_FG_START="\x1B[31m"
TEXT_GREEN_FG_START="\x1B[32m"
TEXT_BOLD_START="\x1B[1m"
TEXT_RESET="\x1B[0m"

# Message status
STATUS_ERROR="$TEXT_RED_FG_START$TEXT_BOLD_START[ERROR]$TEXT_RESET"
STATUS_OK="$TEXT_GREEN_FG_START$TEXT_BOLD_START[OK]$TEXT_RESET"

# Usage: check_prerequisite <command> [message]
function check_prerequisite {
    local COMMAND=$1
    local MESSAGE=$2

    if [ -z "$COMMAND" ]
    then
        echo -e "$STATUS_ERROR Command name is empty." >> /dev/stderr
        return 1
    fi

    if [ -z "$MESSAGE" ]
    then
        MESSAGE="Command \`$COMMAND\` is not available."
    fi

    if ! which "$COMMAND" >> /dev/null
    then
        echo -e "$STATUS_ERROR $COMMAND: $MESSAGE" >> /dev/stderr
        return 1
    else
        echo -e "$STATUS_OK $COMMAND" >> /dev/stderr
    fi
}

function check_all_prerequisites {
    local RET=0

    echo -e "Checking prerequisites..." >> /dev/stderr

    check_prerequisite "7z" \
        "Please install \`p7zip\` from https://p7zip.sourceforge.net/."
    RET=$(expr $RET \| $?)

    echo -e "Prerequisite checking completed." >> /dev/stderr

    return $RET
}

check_all_prerequisites
exit $?