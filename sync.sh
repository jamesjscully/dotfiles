#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
cd "$DOTFILES_DIR"

# Copy latest configs into repo
cp ~/.bashrc "$DOTFILES_DIR/bashrc"
cp ~/.gitconfig "$DOTFILES_DIR/gitconfig"
cp ~/.profile "$DOTFILES_DIR/profile"

# Commit and push if there are changes
if ! git diff --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
    git add -A
    git commit -m "auto-sync $(date +%Y-%m-%d)"
    git push
fi
