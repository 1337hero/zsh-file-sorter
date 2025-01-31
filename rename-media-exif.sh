#!/bin/zsh

# Check if required tools are installed
if ! command -v exiftool &> /dev/null; then
    print "Error: exiftool is not installed. Please install it first."
    print "On macOS: brew install exiftool"
    print "On Ubuntu/Debian: sudo apt-get install libimage-exiftool-perl"
    exit 1
fi

process_file() {
    local file="$1"
    local filename=${file:t}
    
    # Skip the script itself
    if [[ "$filename" = "rename-media-exif.sh" ]]; then
        return
    fi
    
    # Get EXIF creation date
    local exif_date=$(exiftool -DateTimeOriginal -d "%Y-%m-%d_%H.%M.%S" "$file" 2>/dev/null | awk -F': ' '{print $2}')
    
    if [[ -z "$exif_date" ]]; then
        print "Warning: No EXIF date found for $filename"
        return
    fi
    
    # Generate MD5 hash of file (using first 8 characters)
    local hash=$(md5 -q "$file" | cut -c1-8)
    
    # Get file extension
    local ext=${filename:e}
    
    # Create new filename
    local new_filename="${exif_date}_${hash}.${ext}"
    
    # Rename the file
    if [[ "$filename" != "$new_filename" ]]; then
        mv "$file" "${file:h}/$new_filename"
        print "Renamed: $filename → $new_filename"
    else
        print "Skipping: $filename (already in correct format)"
    fi
}

# Main script
print "Starting EXIF-based media renaming..."

# Get target directory from first argument, default to current directory if not provided
target_dir="${1:-.}"
if [[ ! -d "$target_dir" ]]; then
    print "Error: Directory '$target_dir' does not exist"
    exit 1
fi

print "Looking in directory: $target_dir"

# Process all image files
for ext in jpg jpeg png heic HEIC JPG JPEG PNG DNG; do
    for file in "$target_dir"/*.$ext(.N); do
        if [[ -f "$file" ]]; then
            process_file "$file"
        fi
    done
done

print "Renaming complete!" 