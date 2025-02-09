#!/bin/bash

# Function to create a new user
create_user() {
    read -p "Enter new username: " username
    
    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "Error: User '$username' already exists."
        exit 1
    fi

    # Prompt for password securely
    read -s -p "Enter password: " password
    echo

    # Create user and set password
    sudo useradd "$username"
    echo "$username:$password" | sudo chpasswd
    
    # Success message
    echo "User '$username' created successfully."
}

# Check if script is run with -c or --create
if [[ "$1" == "-c" || "$1" == "--create" ]]; then
    create_user
else
    echo "Usage: $0 -c | --create"
fi

