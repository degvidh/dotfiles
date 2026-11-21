starship init fish | source

# Incarca culorile dinamice generate de Matugen
source ~/.config/fish/functions/matugen_colors.fish

# Pornire automata Hyprland la logarea in TTY1 (Sintaxa Fish)
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec start-hyprland
    end
end

# --- Interactive Session Configurations ---
if status is-interactive
    # Disable the default intro welcome greeting message
    set fish_greeting ""

    # Clear out standard configuration command bindings
    # (Forces your path tracking mechanics into uniform coloring)

    # --- Quality of Life Terminal Shortcuts (Aliases) ---
    # Safe system updates and package searching
    alias update="sudo pacman -Syu"
    alias install="sudo pacman -S"
    alias search="pacman -Ss"

    # Modernized list view replacements using colored output formatting
    alias ls="ls --color=auto"
    alias la="ls -A --color=auto"
    alias ll="ls -lh --color=auto"

    # Faster folder tree movements
    alias ..="cd .."
    alias ...="cd ../.."

    alias roblox="flatpak run org.vinegarhq.Sober"

end

fish_add_path /home/david/.spicetify

# Hermes Agent command
fish_add_path "$HOME/.local/bin"

# opencode
fish_add_path /home/david/.opencode/bin
