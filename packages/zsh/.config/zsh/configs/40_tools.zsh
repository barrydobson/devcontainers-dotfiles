#=============================================================================
# Tool Initialization
#=============================================================================

# starship.rs
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi

# mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# VSCode shell integration (available in devcontainers)
if [[ "$TERM_PROGRAM" == "vscode" ]] && command -v code >/dev/null 2>&1; then
  source "$(code --locate-shell-integration-path zsh)"
fi
