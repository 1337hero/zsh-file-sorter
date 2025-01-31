#!/bin/zsh

# Get Months
get_month_name() {
    case "$1" in
        "01") echo "Jan" ;;
        "02") echo "Feb" ;;
        "03") echo "Mar" ;;
        "04") echo "Apr" ;;
        "05") echo "May" ;;
        "06") echo "Jun" ;;
        "07") echo "Jul" ;;
        "08") echo "Aug" ;;
        "09") echo "Sep" ;;
        "10") echo "Oct" ;;
        "11") echo "Nov" ;;
        "12") echo "Dec" ;;
        *) echo "Unknown" ;;
    esac
}

process_file() {
    local file="$1"
    local filename=${file:t}
    local file_type="$2"  # New parameter to specify if it's a photo or video
    
    # Skip the script itself
    if [[ "$filename" = "sort_images.sh" ]]; then
        return
    fi
    
    # Extract date components from filename (assuming format: YYYY-MM-DD HH.MM.SS.ext)
    if [[ $filename =~ "([0-9]{4})-([0-9]{2})-([0-9]{2}).*\.([^.]+)" ]]; then
        local year=$match[1]
        local month=$match[2]
        local day=$match[3]
        local ext=$match[4]
        
        local month_name=$(get_month_name "$month")
        if [[ "$month_name" = "Unknown" ]]; then
            print "Warning: Invalid month number: $month"
            return
        fi
        
        # Create year and month directories under the appropriate media type folder
        local base_dir="${file_type}s"  # Will become "photos" or "videos"
        local target_dir="$base_dir/$year/${month}_${month_name}"
        mkdir -p "$target_dir"
        
        # Generate new filename with incremental counter
        local counter=1
        while true; do
            local new_filename=$(printf "%s-%s-%s_%04d.%s" "$year" "$month" "$day" "$counter" "$ext")
            if [[ ! -f "$target_dir/$new_filename" ]]; then
                break
            fi
            ((counter++))
        done
        
        # Move and rename the file
        mv "$file" "$target_dir/$new_filename"
        print "Moved: $filename → $target_dir/$new_filename"
    else
        print "Warning: Skipping $filename - doesn't match expected format"
    fi
}

# Main script
print "Starting media organization..."
print "Looking in current directory..."

# Process all image files
for ext in jpg jpeg png heic HEIC JPG JPEG PNG; do
    for file in ./*.$ext(.N); do
        if [[ -f "$file" ]]; then
            process_file "$file" "photo"
        fi
    done
done

# Process all video files
for ext in mov mp4 MOV MP4; do
    for file in ./*.$ext(.N); do
        if [[ -f "$file" ]]; then
            process_file "$file" "video"
        fi
    done
done

print "Organization complete!"