#!/bin/bash

# Script to clone the lf-lang.github.io repository, build static Python docs,
# and copy the results to the lfdocs directory.
# Usage: ./build_lf_docs.sh

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/lf-lang/lf-lang.github.io.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEST_DIR="$PROJECT_ROOT/lfdocs"

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
Usage: $0

This script clones the lf-lang.github.io repository, runs the static C docs
build, and copies the resulting build directory to the lfdocs directory.

The following subdirectories are excluded from the copy:
  - build/docs/0.*.*  (versioned documentation)
  - build/docs/next
  - build/docs/tutorial-videos
  - build/docs/videos

EOF
    exit 0
}

# Check for help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed."
    print_error ""
    print_error "Please install Node.js and npm before running this script."
    print_error "You can install Node.js from: https://nodejs.org/"
    print_error ""
    print_error "On macOS with Homebrew:    brew install node"
    print_error "On Ubuntu/Debian:          sudo apt install nodejs npm"
    print_error "On Fedora/RHEL:            sudo dnf install nodejs npm"
    exit 1
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "git is not installed."
    print_error "Please install git before running this script."
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
if git clone --depth 1 "$REPO_URL" "$TEMP_DIR/repo" 2>&1; then
    print_info "Repository cloned successfully"
else
    print_error "Failed to clone repository"
    exit 1
fi

# Change to the cloned repository directory
cd "$TEMP_DIR/repo"

# Install npm dependencies
print_info "Installing npm dependencies..."
if npm install 2>&1; then
    print_info "Dependencies installed successfully"
else
    print_error "Failed to install npm dependencies"
    exit 1
fi

# Run the static C docs build
print_info "Building static Python documentation..."
if npm run build:static:py 2>&1; then
    print_info "Build completed successfully"
else
    print_error "Failed to build documentation"
    exit 1
fi

# Check if build directory exists
BUILD_DIR="$TEMP_DIR/repo/build"
if [ ! -d "$BUILD_DIR" ]; then
    print_error "Build directory does not exist: $BUILD_DIR"
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

# Copy build directory to destination, excluding specified subdirectories
print_info "Copying build directory to '$DEST_DIR' (excluding versioned docs, next, tutorial-videos, videos)..."

# Use rsync for selective copying with exclusions
if command -v rsync &> /dev/null; then
    rsync -a \
        --exclude='docs/0.*.*' \
        --exclude='docs/next' \
        --exclude='docs/tutorial-videos' \
        --exclude='docs/videos' \
        "$BUILD_DIR/" "$DEST_DIR/"
    print_info "Copy completed successfully using rsync"
else
    # Fallback to manual copy if rsync is not available
    print_warning "rsync not available, using manual copy method..."
    
    # First, copy everything
    cp -R "$BUILD_DIR/"* "$DEST_DIR/" 2>/dev/null || cp -R "$BUILD_DIR/." "$DEST_DIR/"
    
    # Then remove excluded directories
    print_info "Removing excluded directories..."
    
    # Remove docs/0.*.* versioned directories
    if [ -d "$DEST_DIR/docs" ]; then
        for dir in "$DEST_DIR/docs"/0.*.*; do
            if [ -d "$dir" ]; then
                print_info "  Removing: $dir"
                rm -rf "$dir"
            fi
        done
    fi
    
    # Remove docs/next
    if [ -d "$DEST_DIR/docs/next" ]; then
        print_info "  Removing: $DEST_DIR/docs/next"
        rm -rf "$DEST_DIR/docs/next"
    fi
    
    # Remove docs/tutorial-videos
    if [ -d "$DEST_DIR/docs/tutorial-videos" ]; then
        print_info "  Removing: $DEST_DIR/docs/tutorial-videos"
        rm -rf "$DEST_DIR/docs/tutorial-videos"
    fi
    
    # Remove docs/videos
    if [ -d "$DEST_DIR/docs/videos" ]; then
        print_info "  Removing: $DEST_DIR/docs/videos"
        rm -rf "$DEST_DIR/docs/videos"
    fi
    
    print_info "Copy completed successfully"
fi

print_info "Operation completed successfully!"
print_info "Documentation copied to: $DEST_DIR"
