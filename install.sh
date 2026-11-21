#!/usr/bin/env bash
# Install this snapshot, backing up any different files it replaces.
set -euo pipefail

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
BACKUP_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
INSTALL_SYSTEM=false
BACKUP_USED=false

case "${1:-}" in
    "") ;;
    --system) INSTALL_SYSTEM=true ;;
    -h|--help)
        printf 'Usage: %s [--system]\n' "${0##*/}"
        printf '  --system  Also install the SDDM drop-in under /etc (uses sudo).\n'
        exit 0
        ;;
    *)
        printf 'Unknown option: %s\n' "$1" >&2
        exit 2
        ;;
esac

copy_tree() {
    local source_root=$1
    local destination_root=$2
    local source relative destination mode backup destination_relative
    destination_relative=${destination_root#"$HOME"/}

    while IFS= read -r -d '' source; do
        relative=${source#./}
        source="$source_root/$relative"
        destination="$destination_root/$relative"
        if [ -e "$destination" ] && ! cmp -s "$source" "$destination"; then
            backup="$BACKUP_DIR/$destination_relative/$relative"
            mkdir -p "$(dirname "$backup")"
            cp -a "$destination" "$backup"
            BACKUP_USED=true
        fi
        mode=$(stat -c '%a' "$source")
        install -D -m "$mode" "$source" "$destination"
    done < <(cd "$source_root" && find . -type f -print0)
}

copy_tree "$REPO_DIR/.config" "$HOME/.config"
copy_tree "$REPO_DIR/.local/bin" "$HOME/.local/bin"

if [ "$INSTALL_SYSTEM" = true ]; then
    sudo install -D -m 644 \
        "$REPO_DIR/system/etc/sddm.conf.d/20-pixie.conf" \
        /etc/sddm.conf.d/20-pixie.conf
fi

printf 'Installed dotfiles from %s\n' "$REPO_DIR"
if [ "$BACKUP_USED" = true ]; then
    printf 'Previous files backed up to %s\n' "$BACKUP_DIR"
fi
printf '\nNext steps:\n'
printf '  systemctl --user enable --now matugen-waywallen.path\n'
printf '  matugen-from-waywallen  # with Waywallen running\n'
if [ "$INSTALL_SYSTEM" = true ]; then
    printf '  Install Pixie under /usr/share/sddm/themes/pixie before enabling SDDM.\n'
fi
