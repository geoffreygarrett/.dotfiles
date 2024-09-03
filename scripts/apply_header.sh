#!/bin/bash

# Define the header template file
TEMPLATE="header_template.txt"

# Function to apply header to a file
apply_header() {
    local file="$1"

    # Extract existing header if present
    # shellcheck disable=SC2155
    local existing_header=$(head -n 10 "$file")

    # Read the template and replace placeholders with actual values
    # shellcheck disable=SC2002
    # shellcheck disable=SC2155
    local header=$(cat "$TEMPLATE" | sed "s/<FILE_TITLE>/$(basename "$file")/g" \
                                     | sed "s/<FILE_DESCRIPTION>/TODO: Add description/g" \
                                     | sed "s/<AUTHOR_NAME>/Your Name/g" \
                                     | sed "s/<CREATION_DATE>/$(date +%Y-%m-%d)/g" \
                                     | sed "s/<LICENSE>/MIT License/g")

    # Check if the existing header matches the template (ignore dynamic parts like date)
    if [[ "$existing_header" != "$header" ]]; then
        echo "$header" > temp_header.txt
        cat "$file" >> temp_header.txt
        mv temp_header.txt "$file"
        echo "Applied header to $file"
    else
        echo "Header already matches in $file"
    fi
}

# Validate headers
validate_headers() {
    local file="$1"

    # Extract existing header
    # shellcheck disable=SC2155
    local existing_header=$(head -n 10 "$file")

    # Read the template and replace placeholders with actual values
    # shellcheck disable=SC2002
    # shellcheck disable=SC2155
    local header=$(cat "$TEMPLATE" | sed "s/<FILE_TITLE>/$(basename "$file")/g" \
                                     | sed "s/<FILE_DESCRIPTION>/TODO: Add description/g" \
                                     | sed "s/<AUTHOR_NAME>/Your Name/g" \
                                     | sed "s/<CREATION_DATE>/$(date +%Y-%m-%d)/g" \
                                     | sed "s/<LICENSE>/MIT License/g")

    if [[ "$existing_header" != "$header" ]]; then
        echo "Header mismatch in $file"
    else
        echo "Header valid in $file"
    fi
}

# Main script
for file in "$@"; do
    apply_header "$file"
    validate_headers "$file"
done
