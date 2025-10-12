#!/usr/bin/env bash
set -euo pipefail

have_cmd() { command -v "$1" >/dev/null 2>&1; }

install_homebrew() {
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

ensure_homebrew() {
    if ! have_cmd brew; then
        install_homebrew
    fi

    # Add brew to PATH for current session (Linux or macOS arm/intel)
    if [[ "$(uname -s)" == "Darwin" ]]; then
        # Standard brew path locations
        for p in /opt/homebrew/bin /usr/local/bin; do
            [[ -d "$p" ]] && export PATH="$p:$PATH"
        done
    else
        # Linuxbrew typical paths
        for p in /home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin /usr/local/bin; do
            [[ -d "$p" ]] && export PATH="$p:$PATH"
        done
    fi
}

install_ansible() {
    if brew list --formula ansible >/dev/null 2>&1; then
        echo "Ansible already installed. Upgrading..."
        brew upgrade ansible || true
    else
        brew install ansible
    fi
}

main() {
    OS="$(uname -s)"
    case "$OS" in
        Darwin*|Linux*)
            ensure_homebrew
            install_ansible
            ;;
        *)
            echo "Unsupported operating system: $OS"
            exit 1
            ;;
    esac
    echo "Ansible installation complete via Homebrew."
}

main "$@"

