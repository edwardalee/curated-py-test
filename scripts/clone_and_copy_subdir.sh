#!/bin/bash

# Script to clone a repository and copy a specific subdirectory
# Usage: ./clone_and_copy_subdir.sh <repo_url> <subdir_path> <destination_dir>

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to display usage
usage() {
    cat << EOF
Usage: $0 <repo_url> <subdir_path> <destination_dir>

Arguments:
    repo_url        URL of the Git repository to clone
    subdir_path     Path to the subdirectory within the repository
    destination_dir Directory where the subdirectory should be copied

Example:
    $0 https://github.com/user/repo.git path/to/subdir ./my_destination

EOF
    exit 1
}

# Check if correct number of arguments provided
if [ $# -ne 3 ]; then
    print_error "Invalid number of arguments"
    usage
fi

REPO_URL="$1"
SUBDIR_PATH="$2"
DEST_DIR="$3"

# Validate inputs
if [ -z "$REPO_URL" ]; then
    print_error "Repository URL cannot be empty"
    exit 1
fi

if [ -z "$SUBDIR_PATH" ]; then
    print_error "Subdirectory path cannot be empty"
    exit 1
fi

if [ -z "$DEST_DIR" ]; then
    print_error "Destination directory cannot be empty"
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
print_info "Created temporary directory: $TEMP_DIR"

# Cleanup function
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        print_info "Cleaning up temporary directory..."
        rm -rf "$TEMP_DIR"
        print_info "Cleanup complete"
    fi
}

# Ensure cleanup happens on exit
trap cleanup EXIT

# Clone the repository
print_info "Cloning repository: $REPO_URL"
if git clone "$REPO_URL" "$TEMP_DIR/repo" 2>&1; then
    print_info "Repository cloned successfully"
else
    print_error "Failed to clone repository"
    exit 1
fi

# Check if subdirectory exists
SUBDIR_FULL_PATH="$TEMP_DIR/repo/$SUBDIR_PATH"
if [ ! -d "$SUBDIR_FULL_PATH" ]; then
    print_error "Subdirectory '$SUBDIR_PATH' does not exist in the repository"
    exit 1
fi

# Delete destination directory if it exists
if [ -d "$DEST_DIR" ]; then
    print_info "Removing existing destination directory: $DEST_DIR"
    rm -rf "$DEST_DIR"
fi

# Create destination directory
print_info "Creating destination directory: $DEST_DIR"
mkdir -p "$DEST_DIR"

# Copy subdirectory to destination
print_info "Copying subdirectory '$SUBDIR_PATH' to '$DEST_DIR'"
if cp -R "$SUBDIR_FULL_PATH/"* "$DEST_DIR/" 2>/dev/null; then
    print_info "Copy completed successfully"
else
    # Try alternative approach if directory is empty or has hidden files
    if cp -R "$SUBDIR_FULL_PATH/." "$DEST_DIR/" 2>/dev/null; then
        print_info "Copy completed successfully"
    else
        print_warning "Directory may be empty or copy may have failed"
    fi
fi

print_info "Operation completed successfully!"
print_info "Contents copied to: $DEST_DIR"

