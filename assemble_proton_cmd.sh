#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 STEAM_APPID" >&2
    exit 1
fi

STEAM_APPID="${1}"

protontricks_wrap() {
    if command -v protontricks > /dev/null 2>&1; then
        # Native protontricks sandboxes its wine call with bubblewrap by default,
        # which prevents it from reading Steam's compatdata prefix,
        # so --no-bwrap is required.
        protontricks --no-bwrap "$@"
    elif flatpak info com.github.Matoking.protontricks > /dev/null 2>&1; then
        flatpak run \
            --env=PROTON_VERSION="Proton Experimental" \
            com.github.Matoking.protontricks "$@"
    else
        echo "protontricks not found in PATH or flatpak installation" >&2
        exit 1
    fi
}

getWineEnv() {
    protontricks_wrap -c "wine cmd.exe /c echo %${1}%" "$STEAM_APPID" 2> /dev/null | dos2unix
}


prefix="$(getWineEnv 'WINEPREFIX')"
localappdata="$(getWineEnv 'LOCALAPPDATA' | sed 's/C:/drive_c/' | sed 's/\\/\//g')"

proton_cmd="${prefix}/${localappdata}"'/Programs/untapped-companion/Untapped.gg\ Companion.exe'

echo "PROTON_REMOTE_DEBUG_CMD=\"${proton_cmd}\" %command%"
