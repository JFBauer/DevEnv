#!/bin/bash

source "$HOME/JFBauer/DevEnv/scripts/git_utils.sh"

# Check if a URL is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 {User}/{Repo}"
    exit 1
fi

# The GitHub URL
URL=$1

# Regular expression to extract username and repository name
REGEX="([^/]+)/([^/]+)(\.git)?"

if [[ $URL =~ $REGEX ]]; then
    USERNAME=${BASH_REMATCH[1]}
    REPO_NAME=${BASH_REMATCH[2]}
    # Remove possible .git suffix
    REPO_NAME=${REPO_NAME%.git}

    # Destination directory
    DEST_DIR="$HOME/$USERNAME/$REPO_NAME"

    GH_TOKEN=$(git_load_token "$USERNAME")

    # Clone the repository, maybe not the securest but it works
    git clone "https://$GH_TOKEN@github.com/$URL" "$DEST_DIR"
else
    echo "Invalid GitHub repository URL."
    exit 1
fi

