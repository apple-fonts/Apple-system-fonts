#!/usr/bin/bash

ERROR_ARGS=1
ERROR_RW=-1

if [ $# -lt 2 ]
then
    echo "Usage: $(which bash) \"$0\" \"<path_to_dmg>\"" "\"<extract_dir>\"" >&2
    exit $ERROR_ARGS
fi

dmgFile="$1"
extractDir="$2"

# Convert .dmg to .img
function extract_dmg_to_img {
    local dmgFile="$1"
    local imgFile="$2"
    dmg2img "$dmgFile" "$imgFile"
}

# Extract fonts from .img
function extract_fonts_from_img {
    local imgFile="$1"
    local extractDir="$2"

    # 1. extract .img to temporary directory
    local tempDir="$(mktemp -d)"
    7z x "$imgFile" -O"$tempDir"

    # 2. extract the .pkg file in the temporary directory
    find "$tempDir" -name "*.pkg" -exec 7z x -O"$tempDir" {} ";"

    # 3. extract the "Payload~" file
    find "$tempDir" -name "Payload~" -exec 7z x -O"$tempDir" {} ";"

    # 4. move all .otf and .ttf files to target directory
    find "$tempDir" -name "*.[ot]tf" -exec mv -v {} "$extractDir" ";"

    rm -rf "$tempDir"
}

# extract fonts from a .dmg file
# Usage: extract_fonts "$dmgFile" "$extractDir"
function extract_fonts {
    local dmgFile="$1"
    local extractDir="$2"

    # 1. create extract directory for fonts
    mkdir -pv "$extractDir"
    if [[ $? -ne 0 ]]; then
        exit $ERROR_RW
    fi

    # 2. create temporary directory to extract files
    local tempDir="$(mktemp -d)"

    # 3. convert .dmg to .img, and put int in temporary directory
    local dmgBaseName="$(basename "${dmgFile%.*}")"
    local imgFile="$tempDir/$dmgBaseName.img"
    extract_dmg_to_img "$dmgFile" "$imgFile"

    # 4. extract fonts from the .img file
    extract_fonts_from_img "$imgFile" "$extractDir"

    # 5. clean up temporary directory
    rm -rf "$tempDir"
}

extract_fonts "$dmgFile" "$extractDir"
