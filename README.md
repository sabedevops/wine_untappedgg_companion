About:
======

This repo hosts a simple [winetricks verb](https://github.com/Winetricks/winetricks?tab=readme-ov-file#custom-verb-files) that installs the [Untapped.gg Companion](https://mtga.untapped.gg/companion) app inside a wine prefix. It can be used for any game supported by the companion app operating through the Wine compatibility layer, but our purpose here was to enable it for [Magic: The Gathering Arena](https://magic.wizards.com/en/mtgarena) running through [Valve's flatpak-based runtime for Steam](https://flathub.org/apps/com.valvesoftware.Steam).

In this context, Steam runs the MTGA client via [Proton](https://github.com/ValveSoftware/Proton), which is analogous to Flatpak for running sandboxed Wine prefix installations inside of Linux namespaces. We use the [protontricks flatpak](https://flathub.org/apps/com.github.Matoking.protontricks) to install this custom verb inside of the MTGA prefix.

These instructions assume you've already got Steam installed via Flatpak and the MTGA client running via proton but the general process should be easy to extrapolate in the case you're running Steam directly on your Linux distribution (hint: you do everything the same without flatpak equivalents of commands).

NOTE: At this time, the overlay UI causes significant weirdness. It will run - but not well. For now, disable the overlay and instead enable the decks to pop out to individual windows. That works on my system but YMMV based on your matrix of software versions, drivers, and hardware.

Instructions:
=============

1. Install protontricks and test.
```bash
# Install the flatpak
flatpak install --user flathub com.github.Matoking.protontricks

# List steam apps. 
# '--env' flag required here only if running game under Proton Experimental 
flatpak run --env=PROTON_VERSION="Proton Experimental" com.github.Matoking.protontricks -l
```

2. Clone this repo and install verb
```bash
flatpak run --env=PROTON_VERSION="Proton Experimental" --file-forwarding com.github.Matoking.protontricks -v 2141910 @@ untappedgg_companion.verb @@
```

3. Modify the MTGA client's Launch Options on Steam as described [here](https://help.steampowered.com/en/faqs/view/0188-6BB7-D467-08E1) and set to the following string replacing `[username]` with your own:

`PROTON_REMOTE_DEBUG_CMD="/home/[username]/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/compatdata/2141910/pfx/drive_c/users/steamuser/AppData/Local/Programs/untapped-companion/Untapped.gg\ Companion.exe" %command%`

That's it! When you next launch MTGA, the Untapped.gg Companion app should be launched also. When you first launch it, you'll login and disable the overlay (for now). Your game data will now be shipped to the Untapped.gg site and should be accessible for streaming through the Twitch extension.

Other Information:
==================

`C:\users\steamuser\AppData\Local\Programs\untapped-companion` contains the `Untapped.gg Companion.exe` binary.

`C:\users\steamuser\AppData\Local\untapped-companion-updater\package.7z` is automatically extracted by the client during installation.

`C:\users\steamuser\AppData\Roaming\untapped-companion\log.log` is the application's log file.

The root directory of all of these can be accessed via the host through `~/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/compatdata/2141910/pfx/drive_c/users/steamuser/AppData/`

After logging in, the client installs a number of registry keys. Some interesting ones are:

* `Software\\HearthSim\\Common`
* `Software\\Wine\\Credential Manager\\Generic: Untapped Companion`

Discovery of the MTGA `Player.log` is done through the following minified logic in the companion source:
```
if("win32"===process.platform)
    return k.a.join(d.app.getPath("home"),"AppData/LocalLow/Wizards Of The Coast/MTGA/Player.log");
if("darwin"===process.platform)
    return k.a.join(d.app.getPath("home"),"/Library/Logs/Wizards Of The Coast/MTGA/Player.log");
```

The `AppID` will be `2141910` in the case of MTGA, but for other supported companion apps you can gather it like this:
```bash
flatpak run --env=PROTON_VERSION="Proton Experimental" com.github.Matoking.protontricks -l | grep 'Magic: The Gathering Arena' | sed -n 's/.*(\([0-9]*\)).*/\1/p'
```
