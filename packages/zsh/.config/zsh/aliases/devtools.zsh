#=============================================================================
# Git Shortcuts
#=============================================================================

alias g="git"
alias lg="lazygit"
alias gs="git status"
alias gp="git pull"
alias gps="git push"
alias gc="git commit"
alias gca="git commit --amend"
alias gco="git checkout"
alias gb="git branch"
alias gl="git log --oneline --graph"

#=============================================================================
# Docker & Docker Compose
#=============================================================================

alias d="docker"
alias dc="docker compose"
alias dps="docker ps"
alias di="docker images"
alias dex="docker exec -it"
alias dprune="docker system prune -af"
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'

#=============================================================================
# Kubernetes
#=============================================================================

alias k="kubectl"
alias kc="kubectx"
alias kn="kubens"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias kgn="kubectl get nodes"

#=============================================================================
# Infrastructure
#=============================================================================

alias tf="terraform"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfd="terraform destroy"
alias tg="terragrunt"
