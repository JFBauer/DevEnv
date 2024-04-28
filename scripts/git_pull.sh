#!/bin/bash

source "$HOME/JFBauer/DevEnv/scripts/git_utils.sh"

# Get current branch name
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" == "HEAD" ]; then
    echo "You are not on any branch."
    exit 1
fi

# Get the current remote URL for the 'origin'
REMOTE_URL=$(git config --get remote.origin.url)
if [ -z "$REMOTE_URL" ]; then
    echo "No remote origin found."
    exit 1
fi

# Regular expression to extract username and repository name
REGEX="https://(.+?)@?github.com/([^/]+)/([^/]+)"

if [[ $REMOTE_URL =~ $REGEX ]]; then
    USERNAME=${BASH_REMATCH[2]}
    REPO_NAME=${BASH_REMATCH[3]}
    REPO_NAME=${REPO_NAME%.git}  # Remove possible .git suffix

    # Retrieve the GitHub token
    GH_TOKEN=$(git_load_token "$USERNAME")

    # If token is found, configure the remote URL with the token embedded
    if [ -n "$GH_TOKEN" ]; then
        git remote set-url origin "https://$GH_TOKEN@github.com/$USERNAME/$REPO_NAME.git"
        
        # Push to the repository
        git push origin "$BRANCH"

        # Optionally, reset the remote URL to avoid storing the token
        # git remote set-url origin "https://github.com/$USERNAME/$REPO_NAME.git"
    else
        echo "Failed to retrieve a valid token for $USERNAME."
        exit 1
    fi
else
    echo "Failed to parse GitHub username and repository from URL: $REMOTE_URL"
    exit 1
fi

