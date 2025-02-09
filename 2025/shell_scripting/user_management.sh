#!/bin/bash

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

# Part 1: Account Creation
create_user() {
    read -p "Enter new username: " username
    if id "$username" &> /dev/null ; then
        echo "Error: Username '$username' already exists."
        return 1
    fi

    read -sp "Enter password: " password
    echo

    useradd -m "$username" && echo "$username:$password" | chpasswd
    if [ $? -eq 0 ]; then
        echo "Success: User '$username' created."
    else
        echo "Error: Failed to create user '$username'."
    fi
}

# Part 2: Account Deletion
delete_user() {
    read -p "Enter username to delete: " username
    if ! id "$username" &> /dev/null ; then
        echo "Error: Username '$username' does not exist."
        return 1
    fi

    read -p "Delete home directory? [Y/n] " choice
    if [[ -z "$choice" ]] || [[ "$choice" =~ ^[yY] ]]; then
        userdel -r "$username" && echo "Success: User '$username' and home directory deleted."
    else
        userdel "$username" && echo "Success: User '$username' deleted (home directory preserved)."
    fi
}

# Part 3: Password Reset
reset_password() {
    read -p "Enter username: " username
    if ! id "$username" &> /dev/null ; then
        echo "Error: Username '$username' does not exist."
        return 1
    fi

    read -sp "Enter new password: " password
    echo
    echo "$username:$password" | chpasswd
    echo "Success: Password for '$username' reset."
}

# Part 4: List User Accounts
list_users() {
    echo "User accounts:"
    echo "------------------"
    echo -e "UID\t Username"
    awk -F: '{ if ($3 >= 1000 && $3 != 65534) printf "%-8s %s\n", $3, $1 }' /etc/passwd
}

# Part 5: Help and Usage Information
show_usage() {
    echo
    echo "User Account Management Script"
    echo "Usage: $0 [OPTION]"
    echo
    echo "Options:"
    echo "  -c, --create              Create new user account"
    echo "  -d, --delete              Delete existing user account"
    echo "  -r, --reset               Reset user password"
    echo "  -l, --list                List all user accounts"
    echo "  -h, --help                Show this help message"
    echo
}

# ---------------------- Main Execution ---------------------- #
case "$1" in
    -c|--create) create_user ;;
    -d|--delete) delete_user ;;
    -r|--reset) reset_password ;;
    -l|--list) list_users ;;
    -h|--help) show_usage ;;
    *) echo "Error: Invalid option. Use -h for help."; exit 1 ;;
esac

exit 0


