#!/bin/bash
pandoc --pdf-engine=xelatex epigrafes.md -o epigrafes.pdf

echo "pdf has been rendered"
# Input Markdown file
INPUT_FILE="epigrafes.md"
# Output README file
OUTPUT_FILE="README.md"

# Function to count words in a paragraph
count_words() {
    echo "$1" | wc -w
}
# Function to generate a Markdown anchor link from a title
generate_link() {
    local file_name=$(basename "$INPUT_FILE")
    local anchor=$(echo "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/[[:space:]]/-/g' -e 's/[^a-z0-9-]//g')
    echo "$file_name#$anchor"
}
# Initialize variables
section_number=""
section_title=""
section_content=""

# Clear the README.md file and write the table header
echo -e "# Epígrafes de historia\n" > "$OUTPUT_FILE"
echo -e "| Sección | Título | Palabras |" >> "$OUTPUT_FILE"
echo -e "|---------|-------|------------|" >> "$OUTPUT_FILE"

# Read the input file line by line
while IFS= read -r line; do
    # Detect section titles (e.g., lines starting with '#')
    if [[ "$line" =~ ^# ]]; then
        # If a new section starts, process the previous one
        if [[ -n "$section_title" ]]; then
            # Count words in the current section
            word_count=$(count_words "$section_content")
            
            # Determine color based on word count
            if [ "$word_count" -lt 150 ] || [ "$word_count" -gt 250 ]; then
                color="red"
            elif [ "$word_count" -ge 175 ] && [ "$word_count" -le 225 ]; then
                color="green"
            else
                color="yellow"
            fi
            
            # Generate the link for the section title
            link=$(generate_link "$section_title")
            linked_title="[$section_title](#$link)"
            
            # Append the section data to the README file
            echo -e "| $section_number | $linked_title | <span style=\"color:$color\">$word_count</span> |" >> "$OUTPUT_FILE"
        fi

        # Start a new section
        section_number=$(echo "$line" | grep -oP '^#*\s*\K[0-9.]+')
        section_title=$(echo "$line" | sed 's/^#*\s*[0-9.]\+\s*-*\s*//')
        section_content=""
    else
        # Accumulate content for the current section
        section_content+="$line "
    fi
done < "$INPUT_FILE"

# Process the last section after the loop ends
if [[ -n "$section_title" ]]; then
    word_count=$(count_words "$section_content")
    
    if [ "$word_count" -lt 150 ] || [ "$word_count" -gt 250 ]; then
        color="red"
    elif [ "$word_count" -ge 175 ] && [ "$word_count" -le 225 ]; then
        color="green"
    else
        color="yellow"
    fi
    
    # Generate the link for the section title
    link=$(generate_link "$section_title")
    linked_title="[$section_title]($link)"
    
    # Append the final section data to the README file
    echo -e "| $section_number | $linked_title | <span style=\"color:$color\">$word_count</span> |" >> "$OUTPUT_FILE"
fi

echo "README.md has been generated."