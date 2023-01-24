#!/usr/bin/bash

# Linux formatting control sequences
TEXT_RED_FG_START="\x1B[31m"
TEXT_GREEN_FG_START="\x1B[32m"
TEXT_BOLD_START="\x1B[1m"
TEXT_RESET="\x1B[0m"
TEXT_ERASE_TO_END="\x1B[K"

function check_exec {
    local execName="$1"
    local packageName="$2"

    echo -ne "Checking executable \"$execName\"...\r"

    which "$execName" >> /dev/null
    local ret="$?"

    if [ $ret -eq 0 ]
    then
        echo -e "$TEXT_GREEN_FG_START$TEXT_BOLD_START[DONE]$TEXT_RESET command \"$execName\" is available$TEXT_ERASE_TO_END"
    else
        echo -e "$TEXT_RED_FG_START$TEXT_BOLD_START[ERROR]$TEXT_RESET Please install the package \"$packageName\" to supply the command \"$execName\"$TEXT_ERASE_TO_END" >> /dev/stderr
    fi

    return $ret
}

if [ "$#" -lt 1 ]
then
    echo "Usage: bash "$0" <exec_name> [package_name]"
    echo "  - If package_name is not specified, it will be treated the same as exec_name."
    exit 1
fi

execName="$1"
packageName="$(expr "$2" "|" "$execName")"

check_exec "$execName" "$packageName"