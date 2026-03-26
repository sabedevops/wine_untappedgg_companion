#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 STEAM_APPID" >&2
    exit 1
fi

STEAM_APPID="${1}"

getWineEnv() {
    flatpak run \
        --env=PROTON_VERSION="Proton Experimental" \
        com.github.Matoking.protontricks -c "wine cmd.exe /c echo %${1}%" "$STEAM_APPID" 2> /dev/null | dos2unix
}


prefix="$(getWineEnv 'WINEPREFIX')"
localappdata="$(getWineEnv 'LOCALAPPDATA' | sed 's/C:/drive_c/' | sed 's/\\/\//g')"

proton_cmd="${prefix}/${localappdata}"'/Programs/untapped-companion/Untapped.gg\ Companion.exe'

echo "PROTON_REMOTE_DEBUG_CMD=\"${proton_cmd}\" %command%"
