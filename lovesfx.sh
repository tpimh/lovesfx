#!/bin/sh
#set -x
set -e

# General settings
TITLE="Particle System Playground"
PROGRESS="no"
PASSWORD=""

# Detect OS
SYSTEM="$(uname -s)"

# Download links
if [ "$SYSTEM" = "Linux" ]; then
    LINK_7z="https://7-zip.org/a/7z2407-linux-x64.tar.xz"
    LINK_magick="https://imagemagick.org/archive/binaries/magick"
    LINK_wine="https://github.com/mmtrt/WINE_AppImage/releases/download/staging-v8/wine-staging_8.21-x86_64.AppImage"
else
    LINK_7zr="https://7-zip.org/a/7zr.exe"
    LINK_7z="https://7-zip.org/a/7z2407-extra.7z"
    LINK_magick="https://imagemagick.org/archive/binaries/ImageMagick-7.1.1-35-portable-Q16-HDRI-x64.zip"
fi

LINK_love="https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip"
LINK_game="https://github.com/santoslove/particle-system-playground/archive/refs/heads/master.zip"
LINK_icon="https://upload.wikimedia.org/wikipedia/commons/6/6f/Softies-icons-star_256px.png"
LINK_rcedit="https://github.com/electron/rcedit/releases/download/v2.0.0/rcedit-x64.exe"
LINK_sfx="https://github.com/chrislake/7zsfxmm/releases/download/1.7.1.3901/7zsd_extra_171_3901.7z"

get_remote_filename() {
    curl -LsI "$1" | grep -i content-disposition | sed -n 's/.*filename=*\([^;]*\).*/\1/p' | tr -d '\r'
}

download() {
    if [ ! -f "$2" ]; then
        echo "Downloading $2"
        curl -LJ -o "$2" "$1"
    fi
}

# File paths
EXE_7zr="$(basename "$LINK_7zr")"
EXE_wine="$(basename "$LINK_wine")"
ARCHIVE_7z="$(basename "$LINK_7z")"
ARCHIVE_love="$(basename "$LINK_love")"
ARCHIVE_game="$(get_remote_filename "$LINK_game")"
ARCHIVE_sfx="$(basename "$LINK_sfx")"
FILE_icon="icon.png"
ARCHIVE_magick="$(basename "$LINK_magick")"
FILE_rcedit="$(basename "$LINK_rcedit")"

if [ "$SYSTEM" != "Linux" ]; then
    download "$LINK_7zr" "$EXE_7zr"
else
    download "$LINK_wine" "$EXE_wine"
fi
download "$LINK_7z" "$ARCHIVE_7z"
download "$LINK_love" "$ARCHIVE_love"
download "$LINK_game" "$ARCHIVE_game"
download "$LINK_sfx" "$ARCHIVE_sfx"
download "$LINK_icon" "$FILE_icon"
download "$LINK_magick" "$ARCHIVE_magick"
download "$LINK_rcedit" "$FILE_rcedit"

# Unpacked paths
DIR_7z="${ARCHIVE_7z%%.*}"
if [ "$SYSTEM" = "Linux" ]; then
    EXE_7z="$DIR_7z/7zz"
else
    EXE_7z="$DIR_7z/x64/7za.exe"
fi
DIR_love="${ARCHIVE_love%.*}"
DIR_game="${ARCHIVE_game%.*}"
DIR_sfx="${ARCHIVE_sfx%.*}"
FILE_sfx="7zsd_All_x64.sfx"
if [ "$SYSTEM" = "Linux" ]; then
    EXE_magick="$ARCHIVE_magick"
    EXE_rcedit="$EXE_wine $FILE_rcedit"
else
    DIR_magick="${ARCHIVE_magick%.*}"
    EXE_magick="$DIR_magick/magick.exe"
    EXE_rcedit="$FILE_rcedit"
fi

unpack_7z() {
    TARGETDIR="-o"
    if [ ! -f "./$EXE_7z" ]; then
        if [ "$SYSTEM" = "Linux" ]; then
            UNARCH="tar xf"
            TARGETDIR="-C"
        else
            UNARCH="./$EXE_7zr x"
        fi
    else
        UNARCH="./$EXE_7z x"
    fi

    if [ "$#" -lt 2 ]; then
        if [ ! -d "${1%.*}" ]; then
            echo "Unpacking $1"
            $UNARCH "$1"
        fi
    else
        if [ ! -d "$2" ]; then
            echo "Unpacking $1"
            mkdir -p "$2"
            $UNARCH "$1" "$TARGETDIR$2"
        fi
    fi
}

unpack_7z "$ARCHIVE_7z" "$DIR_7z"
unpack_7z "$ARCHIVE_love"
unpack_7z "$ARCHIVE_game"
unpack_7z "$ARCHIVE_sfx" "$DIR_sfx"
if [ "$SYSTEM" = "Linux" ]; then
    chmod +x "$EXE_magick"
    chmod +x "$EXE_wine"
else
    unpack_7z "$ARCHIVE_magick"
fi

# Icon settings
FILE_ico="${FILE_icon%.*}.ico"

generate_ico() {
    if [ ! -f "$FILE_ico" ]; then
        echo "Creating $FILE_ico"
        # 256, 48, 32, 24, 16: these sizes are the minimum requirement according to Microsoft
        # https://learn.microsoft.com/en-us/windows/apps/design/style/iconography/app-icon-construction#icon-scaling
        "./$EXE_magick" "$FILE_icon" -define icon:auto-resize=256,48,32,24,16 "$FILE_ico"
    fi
}

modify_sfx() {
    if [ ! -f "$FILE_sfx" ]; then
        echo "Patching $FILE_sfx"
        cp "$DIR_sfx/$FILE_sfx" .
        ./$EXE_rcedit "$FILE_sfx" --set-icon "$FILE_ico"
    fi
}

generate_ico
modify_sfx

# SFX settings
CONFIG_file="config.txt"
ARCHIVE_packed="$DIR_game.7z"
SFX_game="$DIR_game.exe"

pack_7z() {
    if [ ! -f "$ARCHIVE_packed" ]; then
        echo "Creating $ARCHIVE_packed"

        if [ ! -z "$PASSWORD" ]; then
            OPTS="$OPTS -p$PASSWORD"
        fi

        "./$EXE_7z" a $OPTS "$ARCHIVE_packed" "$DIR_love" "$DIR_game"
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
        cat "$FILE_sfx" "$CONFIG_file" "$ARCHIVE_packed" > "$SFX_game"
    fi
}

pack_7z
patch_config
create_sfx

# Clean up
#rm -f "$EXE_7zr" "$EXE_wine" "$ARCHIVE_7z" "$ARCHIVE_love" "$ARCHIVE_game" "$ARCHIVE_sfx" "$ARCHIVE_magick" "$FILE_icon" "$FILE_rcedit"
#rm -rf "$DIR_7z" "$DIR_love" "$DIR_game" "$DIR_sfx" "$DIR_magick"
#rm -f "$FILE_ico" "$FILE_sfx" "$CONFIG_file" "$ARCHIVE_packed" "$SFX_game"
