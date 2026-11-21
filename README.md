# David's dotfiles

A clean snapshot of my Arch Linux desktop: **Hyprland + Quickshell + Matugen + Waywallen**, with SDDM/Pixie as the login screen.

Snapshot taken on **2026-11-16**. Core package versions are recorded in [`packages/snapshot.txt`](packages/snapshot.txt).

## Included

- **Hyprland:** Lua configuration, HiDPI laptop/TV monitor setup, animations, keybindings, touchpad gestures, and Hyprlock.
- **Quickshell:** custom bar, audio/brightness OSDs, media controls, network/Bluetooth/session widgets, and wallpaper picker.
- **Matugen:** templates for Quickshell, Hyprland, Ghostty, Fish, Rofi, Strata, Fastfetch, and Neovim.
- **Waywallen integration:** automatically recolors the desktop when the wallpaper changes.
  - Still images are passed directly to Matugen.
  - Videos and animated previews use an extracted frame.
  - Wallpaper Engine web wallpapers use their preview or a custom screenshot from `.config/matugen/wallpaper-sources/`.
- **Terminal and apps:** Ghostty, Fish, Rofi, Strata, Fastfetch, and Neovim configuration.
- **SDDM:** the Pixie theme drop-in under `system/etc/sddm.conf.d/`.

## Repository layout

```text
.config/                 User configuration
.local/bin/              Wallpaper, recoloring, lock, and logout scripts
system/                  Optional system-wide configuration
packages/                Explicit Arch/AUR package lists and version snapshot
install.sh               Backup-aware installer
```

## Requirements

This snapshot targets **Arch Linux** with systemd. The full package lists reflect packages explicitly installed on my machine; they include more than the minimum required for this desktop.

```bash
# Review the lists first, then install what you need.
sudo pacman -S --needed - < packages/pacman.txt
yay -S --needed $(cat packages/aur.txt)
```

Important components include `hyprland`, `quickshell`, `matugen`, `waywallen-bin`, `ffmpeg`, `ghostty`, `fish`, `rofi`, and the listed Qt 6 modules.

## Install

```bash
git clone https://github.com/degvidh/dotfiles.git
cd dotfiles
./install.sh
systemctl --user enable --now matugen-waywallen.path
```

The installer copies files into `~/.config` and `~/.local/bin`. If it would replace a different existing file, it first saves that file under:

```text
~/.local/state/dotfiles-backup/<timestamp>/
```

Start Quickshell and Waywallen, then generate colors from the active wallpaper:

```bash
qs & waywallen --no-ui
matugen-from-waywallen
```

> **Portability note:** this is a personal snapshot. Some scripts and settings contain `/home/david`, my monitor name (`eDP-1`), and my Waywallen catalog IDs. Adjust those for another user or machine. Waywallen's database, plugins, remote libraries, and wallpaper video files are intentionally not included.

## SDDM + Pixie

The SDDM drop-in is included, but the third-party theme itself is not vendored. Install [Pixie SDDM](https://github.com/xCaptaiN09/pixie-sddm) at `/usr/share/sddm/themes/pixie`, then install the drop-in with:

```bash
./install.sh --system
```

This does **not** enable or restart SDDM. After verifying the theme with `sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/pixie`, enable SDDM through systemd as appropriate for your machine.

The snapshot used Pixie commit `1e1a863761f742e8d509d569382b17c112e29fdc`.

## Regenerate colors manually

```bash
matugen image /path/to/image --mode dark --prefer saturation
```

The Quickshell palette is watched and reloaded automatically. Matugen's configured hooks also reload Hyprland, Ghostty, and Neovim where supported.

## What is deliberately excluded

Credentials, browser data, shell history, Fish universal variables, Waywallen databases/cookies, Strata open tabs, caches, logs, backup files, and third-party wallpaper archives are not part of this repository.
