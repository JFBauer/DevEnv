#!/bin/bash

function log () {
	echo "[$(date '+%d-%m-%y %H:%M:%S')] $1"
}

log "Started running setup script."

# Setting some useful variables.
SCRIPT_PATH="$(realpath "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# Getting all needed input from the user
	# Check if user name is set in .gitconfig
	git_username=$(git config --global user.name)
	if [ -z "$git_username" ]; then
	    read -p "Enter your the name you want to be used on GIT commits: " git_username
	    git config --global user.name "$git_username"
	    log ""
	fi

	# Check if email is set in .gitconfig
	git_email=$(git config --global user.email)
	if [ -z "$git_email" ]; then
	    read -p "Enter your the e-mail you want to be used on GIT commits: " git_email
	    git config --global user.email "$git_email"
	    log ""
	fi
 
	log "Git configuration set:"
	log "User name: $(git config --global user.name)"
	log "Email: $(git config --global user.email)"
	log ""

# Installing applications needed by neovim (and possibly other things)
log "Installing requirements for setup: unzip, gcc, ripgrep, fd-find, node"
sudo apt update
sudo apt install -y -qq unzip gcc ripgrep fd-find
# Installs NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
source .bashrc
# Download and install Node.js
nvm install 20

# Installing gh
log "Installing gh-cli"
if ! command -v gh &> /dev/null; then
	sudo mkdir -p -m 755 /etc/apt/keyrings && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y
fi

# TODO:Commented this out, we should decide on whether this should be part of the setup or something that's manually done after.
# Authenticating through gh if not already done
# if ! gh auth status 2>&1 | grep -q 'Logged in to github.com'; then
#     gh auth login
# fi

# Set git to use the authentication setup through gh
log "Telling git to use gh config for authentication"
gh auth setup-git;

# Installing go
log "Installing go"
if ! command -v go &> /dev/null; then
	wget https://go.dev/dl/go1.22.2.linux-amd64.tar.gz
	sudo rm -rf /usr/local/go ; sudo tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz
	sudo ln -s /usr/local/go/bin/go /usr/bin/go
	sudo rm go1.22.2.linux-amd64.tar.gz
fi

# Installing fish shell
log "Installing fish"
if ! command -v nvim &> /dev/null; then
	sudo apt-add-repository --yes ppa:fish-shell/release-3
	sudo apt update
	sudo apt install -y fish
	# TODO:This isn't working currently! I should see how to fix this
	chsh -s usr/bin/fish
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
log "Installing bitwarden cli (bw)"
if ! command -v bw &> /dev/null; then
	wget "https://vault.bitwarden.com/download/?app=cli&platform=linux" -O bw.zip
	sudo unzip bw.zip
	sudo mv -f ./bw /usr/local/bw
	sudo ln -s /usr/local/bw /usr/bin/bw
	sudo rm bw.zip
fi

# Creating a symlink for the NeoVim config
log "Creating a symlink for the NeoVim config"
mkdir -p $HOME/.config
ln -s $SCRIPT_DIR/.config/nvim $HOME/.config/nvim

# Copying shell commands to binary folder
sudo cp $SCRIPT_DIR/scripts/git_clone.sh /usr/local/bin/gc
sudo cp $SCRIPT_DIR/scripts/git_pull.sh /usr/local/bin/gp

# Confirmation message
log "Setup has ran successful, you should close and re-open the terminal to make sure that everything is loaded correctly!"
