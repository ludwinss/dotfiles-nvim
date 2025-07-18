#!/usr/bin/env bash
set -e

echo "🔍 Detectando distribución..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "No se pudo detectar la distribución. Abortando."
    exit 1
fi

install_packages() {
    echo "📦 Instalando paquetes base para $DISTRO..."
    if [[ "$DISTRO" == "debian" || "$DISTRO" == "ubuntu" ]]; then
        sudo apt update
        sudo apt install -y neovim ripgrep fd-find cmake g++ git curl unzip wget
        sudo apt install -y rcm || true
    elif [[ "$DISTRO" == "arch" || "$DISTRO" == "manjaro" ]]; then
        sudo pacman -Sy --noconfirm neovim ripgrep fd cmake gcc git curl unzip wget
        sudo pacman -Sy --noconfirm rcm || true
    else
        echo "Distribución $DISTRO no soportada automáticamente."
        exit 1
    fi
}

install_go() {
    echo "🐹 Instalando Go..."
    wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    export PATH=$PATH:/usr/local/go/bin
}

install_rust() {
    echo "🦀 Instalando Rust..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source $HOME/.cargo/env
}

install_fnm() {
    echo "🔧 Instalando fnm (Node)..."
    curl -fsSL https://fnm.vercel.app/install | bash
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env)"
    fnm install --lts
}

install_tree_sitter() {
    echo "🌲 Instalando Tree-sitter CLI..."
    cargo install tree-sitter-cli
}

clone_repo() {
    echo "📁 Clonando configuración de Neovim..."
    git clone https://github.com/ludwinss/dotfile-neovim ~/.config/nvim
}

final_setup() {
    echo "🚀 Instalando plugins de Neovim..."
    nvim --headless "+MasonInstallAll" +qall
}

install_packages
install_go
install_rust
install_fnm
install_tree_sitter
clone_repo
final_setup

echo "✅ Instalación completada. ¡Disfruta tu Neovim!"
