#!/bin/bash

source "$HOME/JFBauer/DevEnv/scripts/env_utils.sh"

# Function to load environment and retrieve token
git_load_token() {
    local username=$1

    if ! env_exists "GH_TOKEN_$USERNAME"; then
        read -p "No PAT found for the User: $USERNAME, Please enter one now: " TOKEN
        env_store "GH_TOKEN_$USERNAME" "$TOKEN"
    fi

    # Load environment variables
    env_load

    # Check for GitHub token in environment
    local gh_token_var="GH_TOKEN_${USERNAME}"
    local gh_token=${!GH_TOKEN_VAR}

    echo "$gh_token"
}

export -f git_load_token
