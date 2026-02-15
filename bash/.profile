
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/.local/share/kiro-cli/shell/profile.pre.bash" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/profile.pre.bash"

. "$HOME/.cargo/env"


# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/.local/share/kiro-cli/shell/profile.post.bash" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/profile.post.bash"
