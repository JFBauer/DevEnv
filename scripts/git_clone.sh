#!/bin/bash

source "$HOME/JFBauer/DevEnv/scripts/env_utils.sh"

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

    if ! env_exists "GH_TOKEN_$USERNAME"; then
        read -p "No PAT found for the User: $USERNAME, Please enter one now: " TOKEN
        env_store "GH_TOKEN_$USERNAME" "$TOKEN"
    fi

    env_load

    # Check for GitHub token in environment
    GH_TOKEN_VAR="GH_TOKEN_${USERNAME}"
    GH_TOKEN=${!GH_TOKEN_VAR}

    # Clone the repository, maybe not the securest but it works
    git clone "https://$GH_TOKEN@github.com/$URL" "$DEST_DIR"
else
    echo "Invalid GitHub repository URL."
    exit 1
fi

