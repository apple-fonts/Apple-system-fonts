#!/usr/bin/env bash

# Linux formatting control sequences
TEXT_RED_FG_START="\x1B[31m"
TEXT_BOLD_START="\x1B[1m"
TEXT_RESET="\x1B[0m"

# Message status
STATUS_ERROR="$TEXT_RED_FG_START$TEXT_BOLD_START[ERROR]$TEXT_RESET"

if [ \( -z "$1" \) -o \( -z "$2" \) ]
then
    echo "Usage: $(which bash) \"$0\" \"<path_to_dmg>\"" "\"<extract_dir>\"" >&2
    exit 1
fi

dmgFile="$1"
extractDir="$2"

# Extract fonts from .dmg
function extract_fonts_from_dmg {
    local dmgFile="$1"
    local extractDir="$2"

    # Pre-check extraction
    if ! [ -f "$dmgFile" ] # check dmg file for extraction
    then
        echo -e "$STATUS_ERROR \"$dmgFile\" is not a valid .dmg file for extraction." >&2
        exit 1
    elif ! mkdir -p "$extractDir" # create extract directory if not exists
    then
        echo -e "$STATUS_ERROR Failed to create the extract directory \"$extractDir\"." >&2
        exit 1
    fi

    # 1. Extract .dmg to a temporary directory
    local tempDir="$(mktemp -d)"
    7z x "$dmgFile" -O"$tempDir"

    # 2. Extract the .pkg file in the temporary directory
    find "$tempDir" -name "*.pkg" -exec 7z x -O"$tempDir" {} ";"

    # 3. Extract the "Payload~" file
    find "$tempDir" -name "Payload~" -exec 7z x -O"$tempDir" {} ";"

    # 4. Move all .otf and .ttf files to target directory
    find "$tempDir" -name "*.[ot]tf" -exec mv -v {} "$extractDir" ";"

    # 5. Clean up
    rm -rf "$tempDir"
}

extract_fonts_from_dmg "$dmgFile" "$extractDir"
