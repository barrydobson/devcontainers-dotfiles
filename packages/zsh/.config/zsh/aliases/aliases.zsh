#=============================================================================
# Shell Navigation & Safety
#=============================================================================

# Quick navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"                 # Go to previous directory

# Safety nets
alias rm="rm -i"                 # Confirm before removing
alias cp="cp -i"                 # Confirm before overwriting
alias mv="mv -i"                 # Confirm before overwriting
alias ln="ln -i"                 # Confirm before overwriting

#=============================================================================
# System & Utilities
#=============================================================================

# System
alias update="sudo apt update && sudo apt upgrade -y"
alias myip="curl -s https://ipinfo.io/ip"
alias mem="free -h"
alias disk="df -h"

# Utility
alias path="echo $PATH | tr ':' '\n'"       # Print PATH in readable format
alias ports="lsof -i -P -n | grep LISTEN"   # Show listening ports

#=============================================================================
# Package Managers
#=============================================================================

# npm
alias ni="npm install"
alias nid="npm install --save-dev"
alias nig="npm install -g"
alias nr="npm run"

# pip
alias pi="pip install"
alias pig="pip install -g"

# cargo
alias ci="cargo install"

alias la="ls -la"                 # List all files with details
