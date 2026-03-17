#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Symlink dotfiles ---
echo "==> Symlinking dotfiles..."
link_file() {
    local src="$1" dst="$2"
    if [ -f "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "${dst}.backup"
        echo "  Backed up $dst -> ${dst}.backup"
    fi
    ln -sf "$src" "$dst"
    echo "  $src -> $dst"
}

link_file "$DOTFILES_DIR/bashrc"    ~/.bashrc
link_file "$DOTFILES_DIR/gitconfig" ~/.gitconfig
link_file "$DOTFILES_DIR/profile"   ~/.profile

# --- Night Light ---
echo "==> Enabling Night Light..."
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3500

# --- APT packages ---
echo "==> Installing apt packages..."
sudo apt update
grep -v '^#' "$DOTFILES_DIR/packages.txt" | grep -v '^$' | xargs sudo apt install -y

# --- Snap packages ---
echo "==> Installing snap packages..."
sudo snap install spotify

# --- gh CLI ---
echo "==> Installing GitHub CLI..."
GH_VERSION=$(curl -sI https://github.com/cli/cli/releases/latest | grep -i location | sed 's/.*tag\/v//' | tr -d '\r')
curl -sL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" -o /tmp/gh.tar.gz
tar -xzf /tmp/gh.tar.gz -C /tmp/
mkdir -p ~/.local/bin
cp "/tmp/gh_${GH_VERSION}_linux_amd64/bin/gh" ~/.local/bin/gh
rm -rf /tmp/gh.tar.gz /tmp/gh_${GH_VERSION}_linux_amd64

# --- Git config ---
echo "==> Configuring git..."
git config --global user.name "James Scully"
git config --global user.email "Jamesjscully@gmail.com"

# --- SSH key ---
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "==> Generating SSH key..."
    ssh-keygen -t ed25519 -C "Jamesjscully@gmail.com" -f ~/.ssh/id_ed25519 -N ""
    echo "Public key:"
    cat ~/.ssh/id_ed25519.pub
fi

# --- GNOME extensions ---
echo "==> Installing PaperWM..."
if [ ! -d ~/PaperWM ]; then
    git clone https://github.com/paperwm/PaperWM.git ~/PaperWM
fi
cd ~/PaperWM && make install

echo ""
echo "==> Done! Log out and back in, then run:"
echo "    gnome-extensions enable paperwm@paperwm.github.com"
echo "    gh auth login"
