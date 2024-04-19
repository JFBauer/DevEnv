#!/bin/bash

# Setting some useful variables.
SCRIPT_PATH="$(realpath "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# Getting all needed input from the user

# Check if user name is set in .gitconfig
git_username=$(git config --global user.name)
if [ -z "$git_username" ]; then
    read -p "Enter your the name you want to be used on GIT commits: " git_username
    git config --global user.name "$git_username"
fi

# Check if email is set in .gitconfig
git_email=$(git config --global user.email)
if [ -z "$git_email" ]; then
    read -p "Enter your the e-mail you want to be used on GIT commits: " git_email
    git config --global user.email "$git_email"
fi

echo "Git configuration set:"
echo "User name: $(git config --global user.name)"
echo "Email: $(git config --global user.email)"

# Installing applications needed by neovim (and possibly other things)
sudo apt update
sudo apt install -y unzip gcc ripgrep fd-find
# installs NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source .bashrc
# download and install Node.js
nvm install 20

# Installing gh
if ! command -v gh &> /dev/null; then
	sudo mkdir -p -m 755 /etc/apt/keyrings && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y
fi

# Authenticating through gh if not already done
if ! gh auth status 2>&1 | grep -q 'Logged in to github.com'; then
    gh auth login
fi

# Set git to use the authentication setup through gh
gh auth setup-git;

# Installing go
if ! command -v go &> /dev/null; then
	wget https://go.dev/dl/go1.22.2.linux-amd64.tar.gz
	sudo rm -rf /usr/local/go ; sudo tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz
	sudo ln -s /usr/local/go/bin/go /usr/bin/go
	sudo rm go1.22.2.linux-amd64.tar.gz
fi

# Installing neovim
if ! command -v nvim &> /dev/null; then
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	chmod u+x nvim.appimage
	./nvim.appimage --appimage-extract
	# Optional: exposing nvim globally
	sudo mv -f squashfs-root /
	sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
	sudo rm nvim.appimage
	sudo rm -R squashfs-root
fi

# Installing bitwarden cli (bw)
if ! command -v bw &> /dev/null; then
	wget "https://vault.bitwarden.com/download/?app=cli&platform=linux" -O bw.zip
	sudo unzip bw.zip
	sudo mv -f ./bw /usr/local/bw
	sudo ln -s /usr/local/bw /usr/bin/bw
	sudo rm bw.zip
fi

# Copying over NeoVim config
mkdir -p $HOME/.config
ln -s $HOME/NeoVim/.config/nvim $HOME/.config/nvim

# Running .bashrc to load changes
source .bashrc

# Confirmation message
echo "Setup has ran successful!"
