#!/bin/bash

# Directory to start the search
SEARCH_DIR="." # Current directory

# Output file for the Markdown table
OUTPUT_FILE="SCRIPT_TABLE.md"

# Create or clear the output file
> "$OUTPUT_FILE"

# Print the table header
echo "| Script | Description | Status |" >> "$OUTPUT_FILE"
echo "| --- | --- | --- |" >> "$OUTPUT_FILE"

# Find all .sh files in the specified directory and its subdirectories
find "$SEARCH_DIR" -type f -name "*.sh" | while read -r script; do
    if [[ -f "$script" ]]; then
        script_name=$(basename "$script")
        script_path=$(realpath --relative-to="$(pwd)" "$script")
        description="Description not set"
        status="Tested"

        # Check for a description in the script (e.g., comments at the top)
        if grep -q "^# Description:" "$script"; then
            description=$(grep "^# Description:" "$script" | sed 's/^# Description: //')
        fi

        # Check for a status in the script (e.g., comments at the top)
        if grep -q "^# Status:" "$script"; then
            status=$(grep "^# Status:" "$script" | sed 's/^# Status: //')
        fi

        # Append the script information to the table
        echo "| [${script_name}](${script_path}) | ${description} | ${status} |" >> "$OUTPUT_FILE"
    fi
done

echo "Markdown table generated in $OUTPUT_FILE."
