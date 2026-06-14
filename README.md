About:
======

This repo hosts a simple [winetricks verb](https://github.com/Winetricks/winetricks?tab=readme-ov-file#custom-verb-files) that installs the [Untapped.gg Companion](https://mtga.untapped.gg/companion) app inside a WINE prefix. It can be used for any game supported by the Untapped.gg Companion app operating through the WINE compatibility layer.

Our example uses [Magic: The Gathering Arena](https://magic.wizards.com/en/mtgarena). Other supported games should function similarly.

Our example shows the following scenario:
* [Steam](https://flathub.org/apps/com.valvesoftware.Steam) installed via flatpak.
* [Proton](https://github.com/ValveSoftware/Proton) running a game installed via Steam store
* [protontricks](https://flathub.org/apps/com.github.Matoking.protontricks) installed via flatpak

For other installation scenarios and other issues, please see the wiki: [Installation Help](https://github.com/sabedevops/wine_untappedgg_companion/wiki/Installation-Help)

Install Instructions:
=====================

1. Install protontricks. I recommend using the flatpak.


```bash
# Install the protontricks flatpak
flatpak install --user flathub com.github.Matoking.protontricks

# Smoke test by listing steam apps.
# '--env' flag required here only if running game under Proton Experimental 
flatpak run --env=PROTON_VERSION='Proton Experimental' com.github.Matoking.protontricks -l
```

2. Gather the `AppID` of the game you're interested in:

```bash
# Replace with different game name if necessary
GAME_NAME='Magic: The Gathering Arena'

# Gather AppID of the game
STEAM_APPID="$(
    flatpak run \
      --env=PROTON_VERSION='Proton Experimental' \
      com.github.Matoking.protontricks -s "$GAME_NAME" |
      grep "$GAME_NAME" |
      sed -n 's/.*(\([0-9]*\)).*/\1/p'
)"
echo "STEAM_APPID=$STEAM_APPID"
```

3. Clone this repo, `cd` into it, and install verb
```bash
git clone https://github.com/sabedevops/wine_untappedgg_companion.git
cd wine_untappedgg_comanion

flatpak run \
  --env=PROTON_VERSION='Proton Experimental' \
  --file-forwarding \
  com.github.Matoking.protontricks -v "${STEAM_APPID}" @@ untappedgg_companion.verb @@
```

4. IMPORTANT: Exit the Untapped.gg Companion client. You will *NOT* be able to login until you run it within Steam.


5. Gather `PROTON_REMOTE_DEBUG_CMD` using the `assemble_proton_cmd.sh` helper script:

```bash
./assemble_proton_cmd.sh "$STEAM_APPID"
```

6. Modify the game client's Launch Options on Steam as described [here](https://help.steampowered.com/en/faqs/view/0188-6BB7-D467-08E1). Paste the script output, it should look something like this for this example:

`PROTON_REMOTE_DEBUG_CMD="/home/${USERNAME}/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/compatdata/${STEAM_APPID}/pfx/drive_c/users/steamuser/AppData/Local/Programs/untapped-companion/Untapped.gg\ Companion.exe" %command%`

7. Set the Compatibility mode to `Proton Experimental`.

8. Launch the game, and login to the Untapped.gg Companion.

NOTE: After performing login for the first time, you may need to restart the game for the Untapped.gg Companion to work correctly.

Alternative: Native protontricks (non-flatpak)
==============================================

If you have `protontricks` from your distro's package manager (e.g.
`pacman -S protontricks` on Arch, `dnf install protontricks` on
Fedora) instead of the flatpak, the install steps above need two
adjustments:

* Replace `flatpak run --env=PROTON_VERSION='Proton Experimental' com.github.Matoking.protontricks` with just `protontricks`.
* Pass `--no-bwrap` for the verb install. Native protontricks sandboxes its wine call with bubblewrap by default, which prevents wine from reading Steam's compatdata prefix.

So step 3 (verb install) becomes:

```bash
cd wine_untappedgg_companion
protontricks "${STEAM_APPID}" --no-bwrap -q untappedgg_companion.verb
```

And step 5 (assemble the launch option) takes a `PROTONTRICKS_NATIVE=1` env var:

```bash
PROTONTRICKS_NATIVE=1 ./assemble_proton_cmd.sh "${STEAM_APPID}"
```

The path it prints will be under `~/.local/share/Steam/...` (not the
flatpak's `~/.var/app/com.valvesoftware.Steam/...`), since native
protontricks talks to the regular Steam install.

Additional Information:
=======================

NOTE: On Wine/XWayland the Untapped.gg Companion overlay can render solid-black because Electron's GPU-accelerated compositor doesn't produce alpha-correct output that Wine can hand to the X server with alpha intact. Appending `--disable-gpu --disable-gpu-compositing` to the launch command falls back to Chromium's CPU compositor, which fixes overlay transparency. Confirmed working on Hyprland (Arch / Omarchy) with Proton Experimental:

```
PROTON_REMOTE_DEBUG_CMD="<...>/Untapped.gg\ Companion.exe --disable-gpu --disable-gpu-compositing" %command%
```

If the overlay still doesn't work for you (or you'd rather not pay the CPU-compositor cost), you can disable the overlay in the companion settings and use pop-out (Player Deck / Opponent Deck) windows instead — those are regular floating windows and don't need the flags.

Hyprland users: see [`examples/hyprland-windows.conf`](./examples/hyprland-windows.conf) for starter window rules.

For more information, see here:

* [Known Overlay Issues](https://github.com/sabedevops/wine_untappedgg_companion/wiki/Known-Overlay-Issues)

If you're curious about what's happening internally, see here:

* [Relevant Files and Directories](https://github.com/sabedevops/wine_untappedgg_companion/wiki/Relevant-Files-and-Directories)
