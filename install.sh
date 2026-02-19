#!/bin/bash

# =============================================================================
# Devcontainer Dotfiles Installation Script (Ubuntu/Debian)
# =============================================================================
# Minimal installation for devcontainer environments: zsh, stow, zinit, starship

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Update package lists only (no upgrade in containers)
update_system() {
    print_status "Updating package lists..."
    if check_sudo_access; then
        sudo apt update
        print_success "Package lists updated"
    else
        print_warning "Cannot update package lists automatically"
        print_warning "Please run: sudo apt update"
    fi
}

# Install minimal packages for devcontainer
install_official_packages() {
    print_status "Installing minimal packages for devcontainer..."

    local packages=(
        "zsh"                # Z shell
        "make"               # Build tool (requested)
        "stow"               # Symlink farm manager
        "git"                # Version control
        "curl"               # HTTP client
        "unzip"              # Archive tool (for starship install)
    )

    local all_packages=("${packages[@]}")

    # Install packages
    if check_sudo_access; then
        for package in "${all_packages[@]}"; do
            if dpkg -l | grep -q "^ii  ${package} "; then
                print_status "${package} is already installed"
            else
                print_status "Installing ${package}..."
                if ! sudo apt install -y "${package}" 2>/dev/null; then
                    print_warning "Failed to install ${package}, it may not be available in repositories"
                fi
            fi
        done
    else
        print_warning "Cannot install packages automatically"
        print_warning "Please run the following commands manually:"
        for package in "${all_packages[@]}"; do
            if ! dpkg -l | grep -q "^ii  ${package} "; then
                echo "sudo apt install -y ${package}"
            fi
        done
    fi

    print_success "Official packages installation completed"
}

# Install Zinit (Zsh plugin manager)
install_zinit() {
    print_status "Installing Zinit (Zsh plugin manager)..."

    local zinit_home="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

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
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        print_success "Starship installed"
    else
        print_status "Starship is already installed"
    fi
}


# Stow dotfiles packages
stow_packages() {
    print_status "Setting up dotfiles symlinks with stow..."

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotfiles_root="${script_dir}"
    local packages_dir="${dotfiles_root}/packages"

    if [[ ! -d "${packages_dir}" ]]; then
        print_error "Packages directory not found at ${packages_dir}"
        return 1
    fi

    cd "${dotfiles_root}"

    # Stow each package
    for package in "${packages_dir}"/*; do
        if [[ -d "${package}" ]]; then
            local package_name
            package_name=$(basename "${package}")
            print_status "Stowing ${package_name}..."
            if stow -d packages -t "${HOME}" "${package_name}" 2>/dev/null; then
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
        if check_sudo_access; then
            if sudo chsh -s "${zsh_path}" 2>/dev/null; then
                print_success "Default shell changed to zsh (restart required)"
            else
                print_warning "Could not change default shell automatically (requires authentication)"
                print_warning "To change shell manually, run: chsh -s ${zsh_path}"
            fi
        else
            if chsh -s "${zsh_path}" 2>/dev/null; then
                print_success "Default shell changed to zsh (restart required)"
            else
                print_warning "Could not change default shell automatically (requires authentication)"
                print_warning "To change shell manually, run: chsh -s ${zsh_path}"
            fi
        fi
        
    else
        print_status "Default shell is already zsh"
    fi

    # Create necessary directories
    mkdir -p "${HOME}/.local/bin"
    mkdir -p "${HOME}/.local/share"
    mkdir -p "${HOME}/.config"

    print_success "Post-installation setup completed"
}

# Main execution
main() {
    print_status "Starting dotfiles dependencies installation..."

    # Check prerequisites
    check_debian_based

    # Update system
    update_system

    # Install packages
    install_official_packages

    # Install shell tools
    install_zinit
    install_starship

    # Stow dotfiles
    stow_packages

    # Post-installation setup
    post_install_setup

    print_success "All dependencies installed successfully!"
    print_success "Dotfiles are now configured and ready to use."
    print_warning "Note: Restart your terminal or log out/in for zsh to take effect."
}

# Run main function
main "$@"
