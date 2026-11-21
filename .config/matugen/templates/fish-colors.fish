# Temă completă Fish generată automat de Matugen
set -g fish_color_normal {{colors.on_surface.default.hex}}
set -g fish_color_command {{colors.primary.default.hex}} --bold
set -g fish_color_keyword {{colors.tertiary.default.hex}}
set -g fish_color_quote {{colors.secondary.default.hex}}
set -g fish_color_redirection {{colors.secondary.default.hex}}
set -g fish_color_end {{colors.outline.default.hex}}

# Aici fortam vizibilitatea erorilor: Text ingrosat si fundal colorat intens (Background Block)
set -g fish_color_error {{colors.error.default.hex}} --bold --background={{colors.error_container.default.hex}}

set -g fish_color_param {{colors.on_surface_variant.default.hex}}
set -g fish_color_comment {{colors.outline.default.hex}}
set -g fish_color_selection --background={{colors.surface_container_highest.default.hex}}
set -g fish_color_search_match --background={{colors.surface_container_highest.default.hex}}
set -g fish_color_operator {{colors.primary.default.hex}}
set -g fish_color_escape {{colors.inverse_primary.default.hex}}
set -g fish_color_autosuggestion {{colors.outline.default.hex}}
set -g fish_color_cancel {{colors.error_container.default.hex}}
