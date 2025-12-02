#=============================================================================
# Tool Initialization
#=============================================================================

# Initialize starship prompt
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

#=============================================================================
# Load Aliases
#=============================================================================

# Load all alias files
if [[ -d $ZDOTDIR/aliases ]]; then
    for alias_file in $ZDOTDIR/aliases/*.zsh; do
        [[ -f "$alias_file" ]] && source "$alias_file"
    done
fi

# VSCode shell integration (available in devcontainers)
if [[ "$TERM_PROGRAM" == "vscode" ]] && command -v code >/dev/null 2>&1; then
  source "$(code --locate-shell-integration-path zsh)"
fi
