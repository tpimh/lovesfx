#!/bin/sh
#set -x

# General settings
TITLE="Particle System Playground"
PROGRESS="no"

# Download links
LINK_7zr="https://7-zip.org/a/7zr.exe"
LINK_7z="https://7-zip.org/a/7z2407-extra.7z"

LINK_love="https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip"
LINK_game="https://github.com/santoslove/particle-system-playground/archive/refs/heads/master.zip"
LINK_sfx="https://github.com/chrislake/7zsfxmm/releases/download/1.7.1.3901/7zsd_extra_171_3901.7z"

get_remote_filename() {
    curl -LsI "$1" | grep -i content-disposition | sed -n 's/.*filename=*\([^;]*\).*/\1/p'
}

download() {
    if [ ! -f "$2" ]; then
        echo "Downloading $2"
        curl -LJ -o "$2" "$1"
    fi
}

# File paths
EXE_7zr="$(basename "$LINK_7zr")"
ARCHIVE_7z="$(basename "$LINK_7z")"
ARCHIVE_love="$(basename "$LINK_love")"
ARCHIVE_game="$(get_remote_filename "$LINK_game")"
ARCHIVE_sfx="$(basename "$LINK_sfx")"

download "$LINK_7zr" "$EXE_7zr"
download "$LINK_7z" "$ARCHIVE_7z"
download "$LINK_love" "$ARCHIVE_love"
download "$LINK_game" "$ARCHIVE_game"
download "$LINK_sfx" "$ARCHIVE_sfx"

# Unpacked paths
DIR_7z="${ARCHIVE_7z%.*}"
EXE_7z="$DIR_7z/x64/7za.exe"
DIR_love="${ARCHIVE_love%.*}"
DIR_game="${ARCHIVE_game%.*}"
DIR_sfx="${ARCHIVE_sfx%.*}"
FILE_sfx="7zsd_All_x64.sfx"

unpack_7z() {
    if [ ! -f "./$EXE_7z" ]; then
        UNARCH="./$EXE_7zr"
    else
        UNARCH="./$EXE_7z"
    fi

    if [ "$#" -lt 2 ]; then
        if [ ! -d "${1%.*}" ]; then
            echo "Unpacking $1"
            $UNARCH x "$1"
        fi
    else
        if [ ! -d "$2" ]; then
            echo "Unpacking $1"
            $UNARCH x "$1" -o"$2"
        fi
    fi
}

unpack_7z "$ARCHIVE_7z" "$DIR_7z"
unpack_7z "$ARCHIVE_love"
unpack_7z "$ARCHIVE_game"
unpack_7z "$ARCHIVE_sfx" "$DIR_sfx"

# SFX settings
CONFIG_file="config.txt"
ARCHIVE_packed="$DIR_game.7z"
SFX_game="$DIR_game.exe"

pack_7z() {
    if [ ! -f "$ARCHIVE_packed" ]; then
        echo "Creating $ARCHIVE_packed"
        "./$EXE_7z" a "$ARCHIVE_packed" "$DIR_love" "$DIR_game"
    fi
}

patch_config() {
    if [ ! -f "$CONFIG_file" ]; then
        echo "Creating "$CONFIG_file""
        sed -e "s|@TITLE@|$TITLE|g" \
            -e "s|@PROGRESS@|$PROGRESS|g" \
            -e "s|@LOVE@|$DIR_love|g" \
            -e "s|@GAME@|$DIR_game|g" \
            "$CONFIG_file.in" > "$CONFIG_file"
    fi
}

create_sfx() {
    if [ ! -f "$SFX_game" ]; then
        echo "Creating $SFX_game"
        cat "$DIR_sfx/$FILE_sfx" "$CONFIG_file" "$ARCHIVE_packed" > "$SFX_game"
    fi
}

pack_7z
patch_config
create_sfx

# Clean up
#rm "$EXE_7zr" "$ARCHIVE_7z" "$ARCHIVE_love" "$ARCHIVE_game" "$ARCHIVE_sfx"
#rm -rf "$DIR_7z" "$DIR_love" "$DIR_game" "$DIR_sfx"
#rm "$CONFIG_file" "$ARCHIVE_packed" "$SFX_game"