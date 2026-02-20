
# System
alias update="sudo apt update && sudo apt upgrade -y"
alias myip="curl -s https://ipinfo.io/ip"
alias mem="free -h"
alias disk="df -h"

# Utility
alias path="echo $PATH | tr ':' '\n'"       # Print PATH in readable format
alias ports="lsof -i -P -n | grep LISTEN"   # Show listening ports

alias la="ls -la"                 # List all files with details
