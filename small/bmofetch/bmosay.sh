#!/bin/bash
# This script replaces the text in the ASCII file and the configuration file
# to make BMO say the specified string. https://github.com/Chick2D/neofetch-themes/blob/main/small/bmofetch/
# Made by https://github.com/donatienLeray


# Function to replace a string in a specific line of a file
replace_string_in_file() {
    local file_path="$1"
    local line_number="$2"
    local new_string="$3"

    # Check if the file exists
    if [ ! -f "$file_path" ]; then
        echo -e "\033[31mError: File '$file_path' not found.\033[39m"
        exit 1
    fi

    # Check if the line number is valid
    total_lines=$(wc -l < "$file_path")
    if [ "$line_number" -gt "$total_lines" ] || [ "$line_number" -lt 1 ]; then
        echo -e "\033[31mError: Line number $line_number is out of range.\033[39m"
        exit 1
    fi

    # Replace the specified line with the new string
    if ! sed -i "${line_number}s/.*/${new_string}/" "$file_path"; then
        echo -e "\033[31mError: Failed to replace line $line_number in file '$file_path'.\033[39m"
        exit 1
    fi

    echo "Successfully replaced line $line_number in $file_path with '$new_string'"
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <new_string>"
    exit 1
fi

# clean up multiple spaces
input=$(echo "$1" | tr -s ' ')

# get the length of the strinng
str_len=$((${#input}+2))

#make the top line
tline=$(printf '_%.0s' $(seq 1 $str_len))
top_line="ˏ$tlineˎ"

# make center text
center_text="\| $input \|"

# make the bottom line
bline=$(printf 'ˉ%.0s' $(seq 1 $str_len))
bottom_line="\`$bline\´"

# Path to the ASCII file and the configuration file
ascii_file="./bmo.txt"
conf_file="./bmofetch.conf"

#default case for start part of the spank bubble (empty string)
start_top_line="$top_line"
start_center_text="$center_text"
start_bottom_line="$bottom_line"
# deafault case for end part of the spank bubble
end_top_line=""
end_center_line=""
end_bottom_line=""

#if input string was not empty
if [ "$str_len" -gt 2 ]; then
    # get the 4 first chars of the lines
    start_top_line=${top_line:0:4}
    start_center_text=${center_text:0:5}
    start_bottom_line=${bottom_line:0:4}
    # get the last chars of the lines
    end_top_line=${top_line: 4}
    end_center_line=${center_text: 5}
    end_bottom_line=${bottom_line: 4}
fi

# if the text part that gets rendered though the neofetch conf (using prin) has a leading spases, let it get rendered as ascii instead
if [[ $end_center_line =~ ^[[:space:]].* ]]; then
    start_center_text="$center_text"
    end_center_line=""

fi

# make the first part of the speak bubble in the ascii file (2 chars long text)
replace_string_in_file "$ascii_file" "1" "\\\u001b[1m                  $start_top_line"
replace_string_in_file "$ascii_file" "2" "\\\033[36m     ˏ________ˎ   \\\033[39m$start_center_text"
replace_string_in_file "$ascii_file" "3" "\\\033[36m    \\/|\\\033[39m ______\\\033[36m | \\\033[39m \\/$start_bottom_line"


# make the end part of the speak bubble in the conf file (form char 3 to the end)
replace_string_in_file "$conf_file" "5" "    prin \"$end_top_line\""
replace_string_in_file "$conf_file" "6" "    prin \"$end_center_line\"" 
replace_string_in_file "$conf_file" "7" "    prin \"$end_bottom_line\""

# Success
echo -e "\033[32mSuccess:BMO now says: $input\033[39m"