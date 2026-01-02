#!/usr/bin/env bash

# Prompt for username
read -p "Enter username: " username

# Prompt for password (silent input)
read -s -p "Enter password: " password
echo ""  # New line after password input

# Validate inputs
if [[ -z "$username" || -z "$password" ]]; then
    echo "Error: Username and password cannot be empty" >&2
    exit 1
fi

# Encode credentials (use system base64 command)
encoded=$(echo -n "${username}:${password}" | /usr/bin/base64)

# Output result
echo ""
echo "Base64 encoded credentials:"
echo "$encoded"
