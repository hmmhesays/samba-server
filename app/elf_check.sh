#!/bin/bash

# Add the echo_message function at the beginning
echo_message() {
    #return;
    echo "$1"
}

# Usage: ./script.sh -b <binary> -i <expected_interpreter> -r <expected_rpath> [-d]

# Initialize variables
BINARY="${BINARY:-}"  # Allow pre-set environment variables
EXPECTED_INTERPRETER="${EXPECTED_INTERPRETER:-}"
EXPECTED_RPATH="${EXPECTED_RPATH:-}"
DRY_RUN=0  # Default to no dry run

# Function to display usage
usage() {
    echo_message "Usage: $0 -b <binary> -i <expected_interpreter> -r <expected_rpath> [-d]"
    echo_message "  -b: Path to the binary file to check and update"
    echo_message "  -i: Expected interpreter path"
    echo_message "  -r: Expected RPATH"
    echo_message "  -d: Dry run (print actions without making changes)"
    echo_message "  -h: Display this help message"
    exit 0
}

# Parse arguments using getopts
while getopts "b:i:r:dh" opt; do
    case $opt in
        b) BINARY=${BINARY:-$OPTARG} ;;
        i) EXPECTED_INTERPRETER=${EXPECTED_INTERPRETER:-$OPTARG} ;;
        r) EXPECTED_RPATH=${EXPECTED_RPATH:-$OPTARG} ;;
        d) DRY_RUN=1 ;;  # Set dry run mode
        h) usage ;;
        *) usage ;;
    esac
done

# Validate arguments
if [ -z "$BINARY" ] || [ -z "$EXPECTED_INTERPRETER" ] || [ -z "$EXPECTED_RPATH" ]; then
    usage
fi

# Check if patchelf is installed
if ! command -v patchelf &>/dev/null; then
    echo_message "Error: patchelf is not installed. Please install it first."
    exit 1
fi

# Verify the binary exists
if [ ! -f "$BINARY" ]; then
    echo_message "Error: Binary '$BINARY' does not exist."
    exit 1
fi

# Get current interpreter and RPATH
CURRENT_INTERPRETER=$(patchelf --print-interpreter "$BINARY" 2>/dev/null)
CURRENT_RPATH=$(patchelf --print-rpath "$BINARY" 2>/dev/null)

# Check and update the interpreter if necessary
if [ "$CURRENT_INTERPRETER" != "$EXPECTED_INTERPRETER" ]; then
    if [ $DRY_RUN -eq 1 ]; then
        echo_message "Dry run: Would update interpreter from '$CURRENT_INTERPRETER' to '$EXPECTED_INTERPRETER'"
    else
        echo_message "Updating interpreter: '$CURRENT_INTERPRETER' -> '$EXPECTED_INTERPRETER'"
        patchelf --set-interpreter "$EXPECTED_INTERPRETER" "$BINARY"
        if [ $? -ne 0 ]; then
            echo_message "Error: Failed to update interpreter."
            exit 1
        fi
    fi
else
    echo_message "Interpreter is correct: $CURRENT_INTERPRETER"
fi

# Check and update the RPATH if necessary
if [ "$CURRENT_RPATH" != "$EXPECTED_RPATH" ]; then
    if [ $DRY_RUN -eq 1 ]; then
        echo_message "Dry run: Would update RPATH from '$CURRENT_RPATH' to '$EXPECTED_RPATH'"
    else
        echo_message "Updating RPATH: '$CURRENT_RPATH' -> '$EXPECTED_RPATH'"
        patchelf --set-rpath "$EXPECTED_RPATH" "$BINARY"
        if [ $? -ne 0 ]; then
            echo_message "Error: Failed to update RPATH."
            exit 1
        fi
    fi
else
    echo_message "RPATH is correct: $CURRENT_RPATH"
fi

if [ $DRY_RUN -eq 1 ]; then
    echo_message "Dry run complete. No changes were made to the binary."
else
    echo_message "Binary '$BINARY' is now configured with the correct interpreter and RPATH."
fi
