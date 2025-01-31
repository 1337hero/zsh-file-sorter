#!/bin/zsh

print "Starting macOS system file cleanup..."

# Get target directory from first argument, default to current directory if not provided
target_dir="${1:-.}"
if [[ ! -d "$target_dir" ]]; then
    print "Error: Directory '$target_dir' does not exist"
    exit 1
fi

print "Looking in directory: $target_dir"

# Remove ._* files
print "Removing '._*' files..."
find "$target_dir" -path "*/timeshift/*" -prune -o -name '._*' -type f -exec rm {} + -print

# Remove .DS_Store files
print "Removing '.DS_Store' files..."
find "$target_dir" -path "*/timeshift/*" -prune -o -name '.DS_Store' -type f -exec rm {} + -print

# Remove .Spotlight-V100 directories
print "Removing '.Spotlight-V100' directories..."
find "$target_dir" -path "*/timeshift/*" -prune -o -name '.Spotlight-V100' -type d -exec rm -rf {} + -print

# Remove .Trashes directories
print "Removing '.Trashes' directories..."
find "$target_dir" -path "*/timeshift/*" -prune -o -name '.Trashes' -type d -exec rm -rf {} + -print

# Remove .hazellock files
print "Removing '.hazellock' files..."
find "$target_dir" -path "*/timeshift/*" -prune -o -name '.hazellock' -type f -exec rm {} + -print

print "Cleanup complete!" 