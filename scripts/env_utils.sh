# Path to the .env file
ENV_PATH="$HOME/.config/DevEnv/.env"

# Function to load environment variables from .env file if it exists
env_load() {
    if [ -f "$ENV_PATH" ]; then
        set -a  # Automatically export all variables
        source "$ENV_PATH"
        set +a  # Stop automatically exporting
    fi
}

# Function to check if an environment variable index exists in the .env file
env_exists() {
    local index=$1

    # Ensure the file exists before trying to check it
    if [ ! -f "$ENV_PATH" ]; then
        return 1  # Return false if no .env file exists
    fi

    # Check if the variable is defined in the .env file
    if grep -q "^${index}=" "$ENV_PATH"; then
        return 0  # Return true if the variable exists
    else
        return 1  # Return false if the variable does not exist
    fi
}

# Function to store or update an environment variable in the .env file
env_store() {
    local index=$1
    local value=$2

    # Ensure the directory and file exist
    mkdir -p "$(dirname "$ENV_PATH")"
    touch "$ENV_PATH"

    # Check if the variable already exists
    if grep -q "^${index}=" "$ENV_PATH"; then
        # Variable exists, replace it
        sed -i "s/^${index}=.*$/${index}=${value}/" "$ENV_PATH"
    else
        # Variable does not exist, append it
        echo "${index}=${value}" >> "$ENV_PATH"
    fi
}

# Export functions so they can be sourced and used in other scripts
export -f env_load
export -f env_exists
export -f env_store
