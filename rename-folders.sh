#!/bin/zsh

# Get month number from name
get_month_number() {
    case "${1:l}" in  # :l converts to lowercase
        *"january"* | *"jan"*) echo "01" ;;
        *"february"* | *"feb"*) echo "02" ;;
        *"march"* | *"mar"*) echo "03" ;;
        *"april"* | *"apr"*) echo "04" ;;
        *"may"*) echo "05" ;;
        *"june"* | *"jun"*) echo "06" ;;
        *"july"* | *"jul"*) echo "07" ;;
        *"august"* | *"aug"*) echo "08" ;;
        *"september"* | *"sep"*) echo "09" ;;
        *"october"* | *"oct"*) echo "10" ;;
        *"november"* | *"nov"*) echo "11" ;;
        *"december"* | *"dec"*) echo "12" ;;
        *) echo "" ;;
    esac
}

# Get month abbreviation
get_month_abbrev() {
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
    esac
}

# Main script
print "Starting folder renaming..."

# Get target directory from first argument, default to current directory if not provided
target_dir="${1:-.}"
if [[ ! -d "$target_dir" ]]; then
    print "Error: Directory '$target_dir' does not exist"
    exit 1
fi

print "Looking in directory: $target_dir"

# Process all directories
for dir in "$target_dir"/*(D/); do
    dirname=${dir:t}  # Get just the directory name
    
    # Skip if directory already matches our pattern (##_Mon format)
    if [[ $dirname =~ "^[0-9]{2}_[A-Za-z]{3}$" ]]; then
        continue
    fi
    
    # Clean the dirname (remove dashes and spaces)
    clean_name=$(echo $dirname | sed 's/^-*//; s/-*$//' | tr -d ' ')
    
    # Get month number
    month_num=$(get_month_number "$clean_name")
    
    if [[ -n "$month_num" ]]; then
        month_abbrev=$(get_month_abbrev "$month_num")
        new_name="${month_num}_${month_abbrev}"
        
        if [[ "$dirname" != "$new_name" ]]; then
            mv "$dir" "$target_dir/$new_name"
            print "Renamed: $dirname → $new_name"
        fi
    else
        print "Warning: Couldn't determine month for directory: $dirname"
    fi
done

print "Folder renaming complete!" 