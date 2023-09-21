#!/usr/bin/env bash

CURDIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
CHECK_EXEC="$CURDIR/check_exec.sh"

# Set all prerequisites to check, along with error messages
declare -A PREREQUISITES # exec -> nessage

PREREQUISITES["7z"]="Command \"7z\" is not available. Please install p7zip-full from https://p7zip.sourceforge.net/."

function check_all_prerequisites {
    local ret=0

    (
        local IFS="\n"

        for execName in ${!PREREQUISITES[@]}
        do
            local errorMessage="${PREREQUISITES["$execName"]}"

            bash "$CHECK_EXEC" "$execName" "$errorMessage"
            ret=$(expr $ret \| $?)
        done

        return $ret
    )

    ret=$?
    return $ret
}

check_all_prerequisites