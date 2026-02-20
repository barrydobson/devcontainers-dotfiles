# regenerate ~/.zautocomp to include ~/.zsh/functions
if [[ -d "${ZDOTDIR}/functions" ]]; then
  # Expand fpath to include ~/.zsh/functions
  fpath=( "${ZDOTDIR}/functions" $fpath )

  autoload -Uz compinit
  compinit
fi

# source configs in .zsh/configs
if [[ -d "${ZDOTDIR}/configs" ]]; then
  for config in ${ZDOTDIR}/configs/*.zsh; do
    source $config
  done
fi

# source aliases in .zsh/aliases
if [[ -d "${ZDOTDIR}/aliases" ]]; then
  for alias in ${ZDOTDIR}/aliases/*.zsh; do
    source $alias
  done
fi
