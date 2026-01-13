#!/bin/bash
# remove_lfs_dirs.sh
#
# This script finds files with extensions commonly stored in Git LFS (large binary files)
# and removes their containing directories. This is useful for making a repository
# compatible with GitHub's template repository feature, which does not support LFS content.
#
# Usage: ./scripts/remove_lfs_dirs.sh

set -e

# File extensions that are typically stored in LFS and should trigger directory removal
# Add more extensions as needed
LFS_EXTENSIONS=(
    "*.tflite"      # TensorFlow Lite models
    "*.onnx"        # ONNX models
    "*.pb"          # TensorFlow protobuf models
    "*.h5"          # Keras/HDF5 models
    "*.pkl"         # Pickle files (often large ML models)
    "*.npy"         # NumPy arrays
    "*.npz"         # Compressed NumPy arrays
    "*.bin"         # Binary files
    "*.weights"     # Model weights
    "*.caffemodel"  # Caffe models
    "*.pt"          # PyTorch models
    "*.pth"         # PyTorch models
)

echo "Searching for large/binary files typically stored in LFS..."

# Build find command with all extensions
find_args=()
first=true
for ext in "${LFS_EXTENSIONS[@]}"; do
    if [ "$first" = true ]; then
        find_args+=(-name "$ext")
        first=false
    else
        find_args+=(-o -name "$ext")
    fi
done

# Find all matching files
matching_files=$(find . -type f \( "${find_args[@]}" \) 2>/dev/null || true)

if [ -z "$matching_files" ]; then
    echo "No LFS-type files found in the repository."
    exit 0
fi

# Collect unique directories containing these files
dirs_to_remove=()
while IFS= read -r file; do
    if [ -n "$file" ]; then
        dir=$(dirname "$file")
        # Check if this directory is already in our list
        already_exists=false
        for existing_dir in "${dirs_to_remove[@]}"; do
            if [ "$dir" = "$existing_dir" ]; then
                already_exists=true
                break
            fi
        done
        if [ "$already_exists" = false ]; then
            dirs_to_remove+=("$dir")
        fi
    fi
done <<< "$matching_files"

if [ ${#dirs_to_remove[@]} -eq 0 ]; then
    echo "No directories to remove."
    exit 0
fi

echo "The following directories contain LFS-type files and will be removed:"
for dir in "${dirs_to_remove[@]}"; do
    echo "  - $dir"
done

# Remove the directories
for dir in "${dirs_to_remove[@]}"; do
    if [ -d "$dir" ]; then
        echo "Removing directory: $dir"
        rm -rf "$dir"
    else
        echo "Directory not found (may have already been removed): $dir"
    fi
done

echo "Done. Removed ${#dirs_to_remove[@]} directory(ies) containing LFS-type files."
