#!/bin/zsh

# Convert month name to number
get_month_number() {
    case "${1:l}" in  # :l converts to lowercase
        "jan") echo "01" ;;
        "feb") echo "02" ;;
        "mar") echo "03" ;;
        "apr") echo "04" ;;
        "may") echo "05" ;;
        "jun") echo "06" ;;
        "jul") echo "07" ;;
        "aug") echo "08" ;;
        "sep") echo "09" ;;
        "oct") echo "10" ;;
        "nov") echo "11" ;;
        "dec") echo "12" ;;
        *) echo "00" ;;
    esac
}

# Convert 12-hour time to 24-hour time
convert_to_24hr() {
    local hour=$1
    local ampm=$2
    
    if [[ ${ampm:l} == "pm" && $hour -ne 12 ]]; then
        hour=$((hour + 12))
    elif [[ ${ampm:l} == "am" && $hour -eq 12 ]]; then
        hour=0
    fi
    
    printf "%02d" $hour
}

process_file() {
    local file="$1"
    local filename=${file:t}
    
    # Skip the script itself
    if [[ "$filename" = "rename-media.sh" ]]; then
        return
    fi
    
    # Match pattern: "Photo Oct 22 2023, 3 37 27 PM.jpg"
    if [[ $filename =~ "(Photo|IMG) ([A-Za-z]+) ([0-9]{1,2}) ([0-9]{4}), ([0-9]{1,2}) ([0-9]{2}) ([0-9]{2}) (AM|PM)\.(.+)" ]]; then
        local month_name=$match[2]
        local day=$match[3]
        local year=$match[4]
        local hour=$match[5]
        local minute=$match[6]
        local second=$match[7]
        local ampm=$match[8]
        local ext=$match[9]
        
        # Convert components
        local month=$(get_month_number "$month_name")
        local hour24=$(convert_to_24hr "$hour" "$ampm")
        
        # Format the new filename
        local new_filename=$(printf "%s-%02d-%02d %02d.%02d.%02d.%s" \
            "$year" "$month" "$day" "$hour24" "$minute" "$second" "$ext")
        
        # Rename the file
        mv "$file" "${file:h}/$new_filename"
        print "Renamed: $filename → $new_filename"
    else
        print "Warning: Skipping $filename - doesn't match expected format"
    fi
}

# Main script
print "Starting media renaming..."

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