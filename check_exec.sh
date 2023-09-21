#!/usr/bin/env bash

# Linux formatting control sequences
TEXT_RED_FG_START="\x1B[31m"
TEXT_GREEN_FG_START="\x1B[32m"
TEXT_BOLD_START="\x1B[1m"
TEXT_RESET="\x1B[0m"
TEXT_ERASE_TO_END="\x1B[K"

# Usage: check_exec <exec_name> [<error_message>]
function check_exec {
    local execName="$1"
    local errorMessage=$(expr "$2" \| "Executable program \"$execName\" not found.")

    if [ -z "$execName" ]
    then
        echo "$TEXT_RED_FG_START$TEXT_BOLD_START[ERROR]$TEXT_RESET Executable name is empty."
        return 1
    fi

    echo -ne "Checking executable \"$execName\"...\r"

    which "$execName" >> /dev/null
    local ret="$?"

    if [ $ret -eq 0 ]
    then
        echo -e "$TEXT_GREEN_FG_START$TEXT_BOLD_START[DONE]$TEXT_RESET Executable program \"$execName\" is available.$TEXT_ERASE_TO_END"
    else
        echo -e "$TEXT_RED_FG_START$TEXT_BOLD_START[ERROR]$TEXT_RESET $errorMessage$TEXT_ERASE_TO_END" >> /dev/stderr
    fi

    return $ret
}

if [ -z "$1" ]
then
    echo -e "Usage: bash \"$0\" <exec_name> [<error_message>]"
    exit 1
fi

execName="$1"
errorMessage="$2"

check_exec "$execName" "$errorMessage"