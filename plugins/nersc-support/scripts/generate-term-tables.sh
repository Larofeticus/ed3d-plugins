#!/usr/bin/env bash
# Generate markdown tables from term-index.json

JSON_FILE="plugins/nersc-support/skills/nersc-terminology/term-index.json"
OUTPUT_FILE="plugins/nersc-support/skills/nersc-terminology/term-tables.md"

# Define category line ranges from glossary metadata
declare -A categories
categories["Filesystems"]="38:100"
categories["Services and Platforms"]="108:274"
categories["Commands and Tools"]="282:472"
categories["Quality of Service"]="480:550"
categories["Infrastructure"]="558:676"
categories["System Concepts"]="684:778"
categories["Specialized Tools"]="787:913"
categories["Acronyms and Abbreviations"]="921:1215"

cat > "$OUTPUT_FILE" << 'EOF_HEADER'
## Term Index

The glossary contains 142 NERSC-specific terms across 8 categories. Each entry is exactly 7 lines:
- Line 1: Term name
- Line 2: [blank]
- Line 3: NERSC-specific meaning
- Line 4: [blank]
- Line 5: Common AI confusion pattern
- Line 6: Impact of misunderstanding
- Line 7: Research keywords

To extract a term's definition, use: `Read(file_path="${CLAUDE_PLUGIN_ROOT}/nersc-support/skills/nersc-terminology/semantic_confusion_glossary.md", offset=line_start, limit=7)`

EOF_HEADER

for category in "Filesystems" "Services and Platforms" "Commands and Tools" \
                "Quality of Service" "Infrastructure" "System Concepts" \
                "Specialized Tools" "Acronyms and Abbreviations"; do

    IFS=':' read -r range_start range_end <<< "${categories[$category]}"

    echo "" >> "$OUTPUT_FILE"
    echo "### $category" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "| Term | Lines |" >> "$OUTPUT_FILE"
    echo "|------|-------|" >> "$OUTPUT_FILE"

    # Extract terms in this line range from JSON using cat | jq (avoiding variable escaping issues)
    cat "$JSON_FILE" | jq -r --arg start "$range_start" --arg end "$range_end" \
        '.terms[] | select(.line_start >= ($start|tonumber) and .line_start <= ($end|tonumber)) | "| \(.name) | \(.line_start)-\(.line_end) |"' \
        >> "$OUTPUT_FILE"
done

echo "Term tables generated: $OUTPUT_FILE"
