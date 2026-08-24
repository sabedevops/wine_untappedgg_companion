#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 STEAM_APPID" >&2
    exit 1
fi

STEAM_APPID="${1}"

# Set PROTONTRICKS_NATIVE=1 if protontricks is installed via your distro
# package manager rather than the flatpak (e.g. `pacman -S protontricks`
# on Arch, `dnf install protontricks` on Fedora). Native protontricks
# sandboxes its wine call with bubblewrap by default, which prevents it
# from reading Steam's compatdata prefix, so --no-bwrap is required.
protontricks_wrap() {
    if [ "${PROTONTRICKS_NATIVE:-0}" = "1" ]; then
        protontricks --no-bwrap "$@"
    else
        flatpak run \
            --env=PROTON_VERSION="Proton Experimental" \
            com.github.Matoking.protontricks "$@"
    fi
}

getWineEnv() {
    protontricks_wrap -c "wine cmd.exe /c echo %${1}%" "$STEAM_APPID" 2> /dev/null | dos2unix
}


prefix="$(getWineEnv 'WINEPREFIX')"
localappdata="$(getWineEnv 'LOCALAPPDATA' | sed 's/C:/drive_c/' | sed 's/\\/\//g')"

proton_cmd="${prefix}/${localappdata}"'/Programs/untapped-companion/Untapped.gg\ Companion.exe'

echo "PROTON_REMOTE_DEBUG_CMD=\"${proton_cmd}\" %command%"
