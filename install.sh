#!/bin/bash

# =============================================================================
# Devcontainer Dotfiles Installation Script (Ubuntu/Debian)
# =============================================================================
# Minimal installation for devcontainer environments: zsh, stow, zinit, starship
#
# usage:
# curl -L https://raw.githubusercontent.com/barrydobson/devcontainers-dotfiles/main/install.sh > x && chmod +x x && sudo ./x
# make sure your edit the ARCH var for your architecture

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

export ME='bd'
export X_UID=10806
export ARCH='x86' # arm, x86

# script vars
MYHOME="$HOME"
PKGARCH=$ARCH

# Helper functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

op_get() {
	f="${3:-notesPlain}"
	op item get "$2" --account "$1" --fields "$f" --format json --vault dotfiles | jq -rM '.value'
}

op_getfile() {
	f="${4:-notesPlain}"
	op --account "$1" read "op://$2/$3/$f"
}

op_account() {
	domain="${3:-my}.1password.eu"
	op account add \
		--address "$domain" \
		--email "$2" \
		--shorthand "$1"
}

_sudo() {
    if check_sudo_access; then
        sudo "$@"
    elif [[ $EUID -eq 0 ]]; then
        "$@"
    else
        print_warning "Sudo access not available, running command without sudo: $*"
        "$@"
    fi
}

# Check if we can run sudo without password
check_sudo_access() {
    if sudo -n true 2>/dev/null; then
        print_status "Sudo access available without password"
        return 0
    else
        print_warning "Sudo requires password - some operations will be skipped"
        print_warning "You may need to run some commands manually with sudo"
        return 1
    fi
}

# Check if running on a Debian-based system
check_debian_based() {
    if ! command -v apt >/dev/null 2>&1; then
        print_error "This script requires apt package manager (Debian/Ubuntu-based system)."
        exit 1
    fi

    # Warn if not Ubuntu/Debian, but don't fail
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        case "${ID}" in
            ubuntu|debian)
                print_status "Detected ${PRETTY_NAME:-${ID}}"
                ;;
            *)
                print_warning "Not Ubuntu/Debian, but apt is available. Proceeding..."
                ;;
        esac
    fi
}

add_apt_sources() {
  print_status "Adding additional APT sources for latest packages..."

  # GitHub CLI
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
	chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

  # 1Password CLI
  curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | tee /etc/apt/sources.list.d/1password.list > /dev/null
  mkdir -p /etc/debsig/policies/AC2D62742012EA22/ &&
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
  mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 &&
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
}

install_runtime_packages() {
  apt update && apt install -y git gpg bash curl gnupg
}

# Install minimal packages for devcontainer
install_official_packages() {
    print_status "Installing minimal packages for devcontainer..."

    apt update &&
	    DEBIAN_FRONTEND=noninteractive apt install -y \
        1password-cli \
        make \
        gh \
        gpg-agent \
        jq \
        stow \
        unzip \
        zsh

    print_success "Official packages installation completed"
}

# Install Zinit (Zsh plugin manager)
install_zinit() {
    print_status "Installing Zinit (Zsh plugin manager)..."

    local zinit_home="${MYHOME}/.local/share/zinit/zinit.git"

    if [[ ! -d "${zinit_home}" ]]; then
        mkdir -p "$(dirname "${zinit_home}")"
        git clone https://github.com/zdharma-continuum/zinit.git "${zinit_home}"
        print_success "Zinit installed"
    else
        print_status "Zinit is already installed"
    fi
}

install_starship() {
    print_status "Installing Starship prompt..."

    if ! command -v starship >/dev/null 2>&1; then
        print_status "$(uname -s)-$(uname -m) architecture detected, installing appropriate Starship binary..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y -a "$(uname -m)"
        print_success "Starship installed"
    else
        print_status "Starship is already installed"
    fi
}

setup_dotfiles() {
    print_status "Setting up dotfiles..."

    git clone https://github.com/barrydobson/devcontainers-dotfiles.git $MYHOME/.local/src/dotfiles &&
    cd $MYHOME/.local/src/dotfiles &&
    stow_packages $MYHOME

    print_success "Dotfiles setup completed"
}

setup_user() {

  print_status "Setting up 1Password CLI account"
  op_account bd
  eval "$(op signin --account bd)"

  print_status "setting up key keychain"
  op_get bd GH_TOKEN token | gh auth login --with-token
  mkdir -p $MYHOME/.ssh

  if [[ -d /home/root/.ssh ]]; then
    cp /root/.ssh/authorized_keys $MYHOME/.ssh/authorized_keys
  fi

  op_get bd id_ed25519_github privateKey > $MYHOME/.ssh/id_ed25519
  op_get bd id_ed25519_github publicKey > $MYHOME/.ssh/id_ed25519.pub
  ssh-keyscan -p 22 -H github.com gist.github.com > /root/.ssh/known_hosts
  ssh-keyscan -p 22 -H github.com gist.github.com > $MYHOME/.ssh/known_hosts
  chmod 700 $MYHOME/.ssh
  chmod 600 $MYHOME/.ssh/*

}


# Stow dotfiles packages
stow_packages() {
    print_status "Setting up dotfiles symlinks with stow..."

    local packages_dir="./packages"
    local target_dir="${1}"

    if [[ ! -d "${packages_dir}" ]]; then
        print_error "Packages directory not found at ${packages_dir}"
        return 1
    fi

    # Stow each package
    for package in "${packages_dir}"/*; do
        if [[ -d "${package}" ]]; then
            local package_name
            package_name=$(basename "${package}")
            print_status "Stowing ${package_name}..."
            if stow -d packages -t "${target_dir}" "${package_name}" 2>/dev/null; then
                print_success "${package_name} stowed"
            else
                print_warning "Failed to stow ${package_name} (may already be stowed)"
            fi
        fi
    done

    print_success "Dotfiles symlinks created"
}

# Post-installation setup
post_install_setup() {
    print_status "Performing post-installation setup..."

    # Change default shell to zsh if not already set
    if [[ "${SHELL}" != */zsh ]]; then
        print_status "Attempting to change default shell to zsh..."
        local zsh_path
        zsh_path=$(command -v zsh)
        if _sudo chsh -s "${zsh_path}" 2>/dev/null; then
            print_success "Default shell changed to zsh (restart required)"
        else
            print_warning "Could not change default shell automatically (requires authentication)"
            print_warning "To change shell manually, run: chsh -s ${zsh_path}"
        fi


    else
        print_status "Default shell is already zsh"
    fi

    # Create necessary directories
    mkdir -p \
      ${MYHOME}/.{config,local} \
      ${MYHOME}/.local/{bin,share}

    print_status "getting git config from 1Password CLI..."
    op_getfile bd dotfiles gitconfig > $MYHOME/.config/git/.gitconfig-local

    print_status "Cleaning up 1Password CLI account information..."
    op signout --account bd --forget

    rm $MYHOME/.profile $MYHOME/.bash*

    print_success "Post-installation setup completed"
}

# Main execution
main() {
    print_status "Starting dotfiles dependencies installation..."

    # Check prerequisites
    check_debian_based

    # Update system
    install_runtime_packages
    add_apt_sources

    # Install packages
    install_official_packages

    # Setup user and 1Password CLI
    setup_user

    # Install shell tools
    install_zinit
    install_starship

    # Stow dotfiles
    setup_dotfiles

    # Post-installation setup
    post_install_setup

    print_success "All dependencies installed successfully!"
    print_success "Dotfiles are now configured and ready to use."
    print_warning "Note: Restart your terminal or log out/in for zsh to take effect."
}

# Run main function
main "$@"
