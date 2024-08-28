#!/bin/bash

# Directory to start the search
SEARCH_DIR="." # Current directory

# Output file for the Markdown table
OUTPUT_FILE="SCRIPT_TABLE.md"

# Temporary file to hold the unsorted data
TEMP_FILE=$(mktemp)

# Create or clear the output file
> "$OUTPUT_FILE"

# Print the table header to the output file
echo "| Script | Description | Status | Published By | Published On |" >> "$OUTPUT_FILE"
echo "| --- | --- | --- | --- | --- |" >> "$OUTPUT_FILE"

# Find all .sh files in the specified directory and its subdirectories
find "$SEARCH_DIR" -type f -name "*.sh" | while read -r script; do
    if [[ -f "$script" ]]; then
        # if table_generator.sh is found, skip it
        if [[ "$script" == *table_generator.sh ]]; then
            continue
        fi
        script_name=$(basename "$script")
        script_path=$(realpath --relative-to="$(pwd)" "$script")
        
        description="Description not set"
        status="Not tested"
        published_by="Unknown"
        published_on="Unknown"

        # Extract description from the script file
        description_line=$(grep -m 1 '^# ' "$script" | sed 's/^# //')
        if [[ -n "$description_line" ]]; then
            description="$description_line"
        fi

        # Extract status from the script file
        if grep -q "^# status:" "$script"; then
            status=$(grep "^# status:" "$script" | sed 's/^# status: //')
        fi

        # Extract published by from the script file
        if grep -q "^# published by:" "$script"; then
            published_by=$(grep "^# published by:" "$script" | sed 's/^# published by: //')
        fi

        # Extract published on from the script file
        if grep -q "^# published on:" "$script"; then
            published_on=$(grep "^# published on:" "$script" | sed 's/^# published on: //')
        fi

        # Append the script information to the temp file
        echo "${published_on} | [${script_name}](${script_path}) | ${description} | ${status} | ${published_by} | ${published_on} |" >> "$TEMP_FILE"
    fi
done

# Sort the temp file by date (published_on) in reverse order and append to the output file
# The sorting is done based on the first field (the date) in the temp file.
sort -r -t '|' -k1,1 "$TEMP_FILE" | cut -d '|' -f 2- >> "$OUTPUT_FILE"

# Clean up the temp file
rm "$TEMP_FILE"

echo "Markdown table generated in $OUTPUT_FILE, sorted by Published On date."
