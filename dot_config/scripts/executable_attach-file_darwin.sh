#!/bin/bash

# attach-file.sh
# Creates a new email in Apple Mail with a file attachment
# Usage: ./attach-file.sh <file_path>

set -e

# Check if file argument is provided
if [ $# -eq 0 ]; then
  echo "Error: No file specified"
  echo "Usage: $0 <file_path>"
  exit 1
fi

FILE_PATH="$1"

# Convert to absolute path if relative
if [[ "$FILE_PATH" != /* ]]; then
  FILE_PATH="$(cd "$(dirname "$FILE_PATH")" && pwd)/$(basename "$FILE_PATH")"
fi

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File not found: $FILE_PATH"
  exit 1
fi

# TODO: Implement account selection logic
# The getDefaultAccount function should:
# - Query Mail for all accounts
# - Find the first account containing "exchange" (case-insensitive)
# - Fall back to the first available account if no exchange account found
# - Return the account name
getDefaultAccount() {
  # PLACEHOLDER - Replace with your implementation
  echo "Exchange"
}

ACCOUNT=$(getDefaultAccount)

echo "Creating new email with attachment..."
echo "Account: $ACCOUNT"
echo "File: $FILE_PATH"

# Create email with attachment using AppleScript
osascript <<EOF
tell application "Mail"
  activate

  try
    -- Get the target account
    set targetAccount to account "$ACCOUNT"

    -- Create new message
    set newMessage to make new outgoing message with properties {visible:true}

    tell newMessage
      -- Set the account/sender
      set sender to name of targetAccount

      -- Add the attachment
      make new attachment with properties {file name:POSIX file "$FILE_PATH"} at after the last paragraph
    end tell

    -- Activate Mail and show the composition window
    activate

    return "SUCCESS: New email created with attachment"

  on error errMsg
    return "ERROR: " & errMsg
  end try
end tell
EOF

echo "Done! Mail composition window opened."
