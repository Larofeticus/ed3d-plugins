---
name: validation-scripts
description: Use when validating file formats (JSON, YAML, Markdown) or extracting markdown sections - provides tested scripts instead of hand-rolling bash pipelines
user-invocable: false
---

# Validation Scripts

A collection of battle-tested bash scripts for validating file formats and extracting structured content from markdown documents. These scripts eliminate hand-rolled validation pipelines by providing reliable, consistent exit codes and structured JSON output.

## When to Use

Use this skill when you need to:

- **Checking if JSON is valid** - `validate-json` validates syntax and optional field existence
- **Extracting content from markdown section** - `extract-markdown-section` pulls content between headers with optional filtering
- **Validating YAML frontmatter structure** - `validate-yaml-frontmatter` verifies frontmatter delimiters and required fields
- **Checking if markdown header exists** - `validate-markdown-header` confirms a specific header is present
- **Verifying file format before processing** - All scripts return consistent exit codes: 0=valid, 1=validation failure, 2=invalid arguments
- **Need structured --json output for parsing** - All scripts support `--json` flag for machine-readable output

## When NOT to Use

Don't use these scripts when you need to:

- **Custom validation logic not covered by scripts** - For complex validation beyond format checks, implement custom logic
- **File doesn't exist yet** - All scripts validate existing files; create it first
- **Need to modify content** - These scripts validate and extract only; use an editor for modifications
- **Complex conditional validation** - If your validation depends on cross-field relationships or business logic, implement separately

## Quick Reference

| Script | Purpose | Key Command | Exit Codes |
|--------|---------|-------------|------------|
| extract-markdown-section | Extract content between markdown headers with optional filtering | `${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/extract-markdown-section -s "## Usage" doc.md` | 0=found, 1=not found, 2=invalid args |
| validate-yaml-frontmatter | Verify YAML frontmatter delimiters and required fields | `${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-yaml-frontmatter -r name doc.md` | 0=valid, 1=invalid, 2=bad args |
| validate-json | Validate JSON syntax and optional field existence | `${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-json --field ".name" file.json` | 0=valid, 1=invalid, 2=bad args |
| validate-markdown-header | Check if specific markdown header exists | `${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-markdown-header -H "## Title" doc.md` | 0=found, 1=not found, 2=bad args |

---

## extract-markdown-section

### Purpose

Extracts content between markdown section headers with optional filtering by line patterns. Handles headers of different levels, strips leading/trailing blank lines, and supports both plain text and JSON output.

### Usage

```
Usage: extract-markdown-section --section "## Header" [OPTIONS] FILE

Extract content between markdown headers with optional grep filters.

OPTIONS:
  -s, --section HEADER    Markdown header to extract (required)
  -c, --contains PATTERN  Only include lines matching this pattern
  -e, --exclude PATTERN   Exclude lines matching this pattern
  --count                 Count matching lines instead of showing content
  --json                  Output JSON: {"valid": true/false, "message": "...", "content": "..."}
  -h                      Show this help

EXIT CODES:
  0 - Section found and filters matched
  1 - Section not found or filters didn't match
  2 - Invalid arguments
```

### Examples

**Basic extraction:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/extract-markdown-section -s "## Installation" README.md
```

Output:
```
npm install my-package
npm run setup
```

**Extract with content filter:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/extract-markdown-section -s "## Setup" -c "npm install" doc.md
```

Output includes only lines matching "npm install":
```
npm install --save-dev jest
npm install my-package
```

**Exclude lines matching pattern:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/extract-markdown-section -s "## Configuration" -e "deprecated" config.md
```

Removes all lines containing "deprecated" from the extracted section.

**Count matching lines:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/extract-markdown-section -s "## Usage" --count doc.md
```

Output: `8` (number of lines in section)

**JSON output with field verification:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/extract-markdown-section -s "## API" -c "function" --json api.md
```

Output:
```json
{"valid": true, "message": "Section extracted", "content": "function getData() {...}"}
```

**Real-world: validate plugin.json references in skill docs:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/extract-markdown-section -s "## Configuration" -c "plugin.json" -e "deprecated" skill.md --json
```

### Common Errors

**"Section not found"** - The header string doesn't match exactly (case-sensitive, includes hashes)
- Fix: Use exact header text, e.g., `"## Installation"` not `"Installation"`

**"No lines match contains pattern"** - Filter pattern is too restrictive or uses regex incorrectly
- Fix: Verify pattern matches at least one line; use `-e` to exclude instead if needed

**"Invalid option"** - Wrong flag name or syntax
- Fix: Use `-s` for section (short) or `--section=` (long with equals), not `--section ` (space doesn't work)

**Empty output after --exclude** - All lines matched the exclusion pattern
- Fix: Adjust exclusion pattern or remove the filter

### Tips

- Section headers must match exactly (case-sensitive, include hashes)
- Patterns for `-c` and `-e` are grep patterns, not regex - use literal strings for safety
- Use `--count` to verify before extracting large sections
- Combine `-c` and `-e` to narrow results: first include, then exclude
- For regex patterns, escape special characters: `\(`, `\)`, `\.`
- Performance is linear in file size; works efficiently on large markdown files

---

## validate-yaml-frontmatter

### Purpose

Verifies that a markdown file has valid YAML frontmatter (opening and closing `---` delimiters) and contains all required fields. Frontmatter must be on lines 1 and within first 20 lines.

### Usage

```
Usage: validate-yaml-frontmatter [OPTIONS] FILE

Verify YAML frontmatter structure (--- delimiters on lines 1 and ≤20).

OPTIONS:
  -r, --require FIELD   Required field in frontmatter (can be used multiple times)
  --json                Output JSON: {"valid": true/false, "message": "...", "error": "..."}
  -h                    Show this help

EXIT CODES:
  0 - Valid frontmatter with all required fields
  1 - Invalid frontmatter or missing required fields
  2 - Invalid arguments
```

### Examples

**Basic validation:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-yaml-frontmatter skill.md
```

Output: `VALID`

**Require specific fields:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-yaml-frontmatter -r name -r description skill.md
```

Verifies that the YAML frontmatter contains both `name:` and `description:` fields.

**Multiple required fields:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-yaml-frontmatter -r name -r user-invocable -r description skill.md
```

Checks for all three required fields in the frontmatter.

**JSON output for scripting:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-yaml-frontmatter -r name -r description --json plugin.md
```

Output on success:
```json
{"valid": true, "message": "Valid YAML frontmatter"}
```

Output on failure (missing field):
```json
{"valid": false, "message": "Missing required field", "error": "Required field not found: author"}
```

**Real-world: validate skill manifest:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-yaml-frontmatter -r name -r description -r user-invocable ./skills/my-skill/SKILL.md
```

**Error case - missing delimiter:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-yaml-frontmatter doc.md
# Exit: 1, Error: "Missing opening delimiter: first line must be ---"
```

### Common Errors

**"Missing opening delimiter: first line must be ---"** - File doesn't start with `---`
- Fix: Add `---` as the first line of your file

**"Missing closing delimiter: second --- must appear within first 20 lines"** - No closing delimiter found
- Fix: Ensure second `---` appears on line 2-20, not beyond

**"Required field not found: X"** - Field doesn't exist or uses different casing/spelling
- Fix: Verify field name matches exactly (e.g., `name:` not `Name:`)

**"File not found"** - Path is incorrect
- Fix: Use absolute path or verify file exists

### Tips

- Field names are case-sensitive: `name:` is different from `Name:`
- Use `-r` multiple times to check multiple fields
- Frontmatter must start at line 1 (no shebang or blank line before)
- Closing delimiter must appear within first 20 lines
- Useful for validating skill manifests, plugin configs, and documentation headers
- Combine with `extract-markdown-section` to validate content structure after validating frontmatter

---

## validate-json

### Purpose

Validates JSON file syntax using Python's json parser and optionally verifies that specific fields exist using jq path expressions. Handles nested field access and provides detailed error messages.

### Usage

```
Usage: validate-json [OPTIONS] FILE

Validate JSON syntax and optional field constraints.

OPTIONS:
  -f, --field PATH      Validate field exists using jq path (e.g., ".name", ".author.email")
  --json                Output JSON: {"valid": true/false, "message": "...", "error": "..."}
  -h                    Show this help

EXIT CODES:
  0 - Valid JSON with all field constraints met
  1 - Invalid JSON or field constraint failed
  2 - Invalid arguments
```

### Examples

**Basic JSON validation:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-json config.json
```

Output: `VALID`

**Validate specific field exists:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-json --field ".version" package.json
```

Confirms the `version` field exists and is not null.

**Nested field validation:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-json --field ".author.email" --json plugin.json
```

Validates nested field path `.author.email` exists.

**Multiple field checks (script):**
```bash
# Check each required field in a loop
for field in ".name" ".version" ".description"; do
  ${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-json --field "$field" package.json || exit 1
done
```

Validates all three fields exist in sequence.

**JSON output for parsing:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-json --field ".scripts.test" --json package.json
```

Output on success:
```json
{"valid": true, "message": "Valid JSON"}
```

Output on field failure:
```json
{"valid": false, "message": "Field not found", "error": "Field path does not exist or is null: .scripts.test"}
```

**Real-world: validate plugin manifest structure:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-json --field ".name" --field ".version" plugin.json
```

### Common Errors

**"Invalid JSON syntax"** - File contains syntax errors (missing comma, quote, bracket)
- Fix: Use `python3 -m json.tool file.json` to find exact syntax error
- Fix: Check for trailing commas (not allowed in JSON)
- Fix: Verify all strings are double-quoted, not single-quoted

**"Field path does not exist or is null"** - Field doesn't exist or equals null/false/empty
- Fix: Verify field name spelling and casing
- Fix: For nested fields, ensure parent exists: use `.parent` first to debug
- Fix: If field should be optional, don't validate it

**"File not found"** - Path is incorrect
- Fix: Use absolute path or verify file exists in current directory

**Invalid jq path syntax** - Path expression is malformed
- Fix: Use simple paths like `.name`, `.author.email`
- Fix: For arrays, use `.[0].field` syntax

### Tips

- Field paths use jq syntax: `.name` for root field, `.author.email` for nested
- Check fields without validating syntax: `jq -e '.field' file.json >/dev/null`
- Use for plugin.json, package.json, and other config validation
- Null, false, and empty string values fail the field check (script treats as "missing")
- Performance: syntax validation is fast (Python parser), field checks use jq (slightly slower)
- Combine with `extract-markdown-section` to validate JSON examples in documentation

---

## validate-markdown-header

### Purpose

Checks if a specific markdown header exists in a file using fixed string matching. Prevents regex interpretation of special characters in header text, making it safe for arbitrary header strings.

### Usage

```
Usage: validate-markdown-header --header "## Title" [OPTIONS] FILE

Check if a specific markdown header exists in the file.

OPTIONS:
  -H, --header HEADER   Header to search for (required)
  --json                Output JSON: {"valid": true/false, "message": "...", "error": "..."}
  -h, --help            Show this help

EXIT CODES:
  0 - Header found
  1 - Header not found or file error
  2 - Invalid arguments
```

### Examples

**Check for header existence:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-markdown-header -H "## Installation" README.md
```

Output: `VALID` (if header exists)

**Long option syntax:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-markdown-header --header "### Configuration" doc.md
```

**JSON output:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-markdown-header -H "## Usage" --json guide.md
```

Output on success:
```json
{"valid": true, "message": "Header found"}
```

Output on failure:
```json
{"valid": false, "message": "Header not found", "error": "## Usage does not exist in guide.md"}
```

**Header with special characters (safe):**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-markdown-header -H "## FAQ (Common Questions)" doc.md
```

Special chars like `(`, `)`, `?` are matched literally, not as regex.

**Real-world: verify documentation sections:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-markdown-header -H "## Installation" README.md && \
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-markdown-header -H "## Usage" README.md && \
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-markdown-header -H "## License" README.md
```

Verifies all required sections exist.

**Script: check all required headers:**
```bash
for header in "## Overview" "## Installation" "## Usage" "## Examples"; do
  ${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-markdown-header -H "$header" README.md || {
    echo "Missing required header: $header"
    exit 1
  }
done
```

### Common Errors

**"Header not found"** - Header text doesn't match exactly (case-sensitive, exact spacing)
- Fix: Include all hashes, spaces, and formatting: `"## Title"` not `"# Title"` or `"Title"`

**"FILE argument required"** - No file specified
- Fix: Add file path as last argument

**"Header required"** - No header flag provided
- Fix: Use `-H` or `--header` with the header text

**"Unknown option"** - Invalid flag name
- Fix: Use `-H` (short) or `--header=` (long with equals), not `--header ` (space)

### Tips

- Header matching is exact and case-sensitive: `## Title` ≠ `## title`
- Whitespace matters: `##Title` (no space) won't match `## Title`
- Safe for headers with special regex characters: `[`, `]`, `(`, `)`, `?`, `*`, `.`
- Most efficient way to check for header before extracting with `extract-markdown-section`
- Use in documentation validation pipelines to ensure required sections exist
- Combine with `extract-markdown-section` for full header validation workflow

---

## Before/After Comparisons

These examples demonstrate how the validation scripts eliminate verbose, error-prone bash pipelines.

### Scenario 1: Extract markdown section with content filter

**Before (hand-rolled bash):**
```bash
sed -n '/^## Installation/,/^##/p' doc.md | grep -v '^##' | grep 'npm' || echo "not found"
```

Problems:
- Requires multiple pipes and manual header boundary detection
- Fragile if heading levels vary
- Hard to read intent
- No consistent exit codes

**After (validation-scripts):**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/extract-markdown-section -s "## Installation" -c "npm" doc.md
```

Benefits:
- Clear, readable command
- Consistent exit codes (0=found, 1=not found)
- Handles heading levels automatically
- Supports both plain and JSON output

**Reduction: 65% fewer tokens**

---

### Scenario 2: Validate JSON and check field exists

**Before (hand-rolled bash):**
```bash
python3 -c 'import json; json.load(open("file.json"))' && jq -e '.name' file.json > /dev/null || echo "invalid"
```

Problems:
- Two separate tools with different error formats
- Requires piping to /dev/null to suppress output
- No JSON output for machine parsing
- Hard to understand intent at a glance

**After (validation-scripts):**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-json --field ".name" file.json
```

Benefits:
- Single command validates both syntax and field
- Consistent exit codes
- Optional JSON output for scripting
- Clear what's being validated

**Reduction: 55% fewer tokens**

---

### Scenario 3: Validate YAML frontmatter structure

**Before (hand-rolled bash):**
```bash
head -n 1 file.md | grep -q '^---$' && \
head -n 20 file.md | tail -n +2 | grep -q '^---$' && \
head -n 20 file.md | grep -q '^name:' && \
echo "valid" || echo "invalid"
```

Problems:
- Complex nested conditions hard to understand
- Multiple `head` and `tail` invocations
- No mechanism to specify which fields are required
- Requires careful sequencing

**After (validation-scripts):**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-yaml-frontmatter -r name -r description file.md
```

Benefits:
- Single readable command
- Explicit field requirements
- Automatic validation of structure and fields
- Consistent error messages

**Reduction: 70% fewer tokens**

---

## Integration Examples

### Skill Validation Pipeline

Verify a skill file has valid YAML and contains an extraction section:

```bash
#!/bin/bash
SCRIPT_ROOT="${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts"

# Check YAML frontmatter
"$SCRIPT_ROOT/validate-yaml-frontmatter" -r name -r description "$1" || exit 1

# Verify required sections exist
"$SCRIPT_ROOT/validate-markdown-header" -H "## When to Use" "$1" || exit 1
"$SCRIPT_ROOT/validate-markdown-header" -H "## When NOT to Use" "$1" || exit 1
"$SCRIPT_ROOT/validate-markdown-header" -H "## Examples" "$1" || exit 1

echo "Skill validation passed"
```

### Plugin Manifest Validation

Verify plugin.json is valid and has required fields:

```bash
#!/bin/bash
SCRIPT_ROOT="${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts"

"$SCRIPT_ROOT/validate-json" --field ".name" plugin.json || exit 1
"$SCRIPT_ROOT/validate-json" --field ".version" plugin.json || exit 1
"$SCRIPT_ROOT/validate-json" --field ".skills" plugin.json || exit 1

echo "Plugin manifest valid"
```

### Documentation Extraction

Extract and validate content from a section:

```bash
#!/bin/bash
SCRIPT_ROOT="${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts"

# First check header exists
"$SCRIPT_ROOT/validate-markdown-header" -H "## API Reference" doc.md || {
  echo "API Reference section missing"
  exit 1
}

# Then extract it with optional filtering
"$SCRIPT_ROOT/extract-markdown-section" -s "## API Reference" --json doc.md
```

---

## Exit Codes Reference

All scripts follow consistent exit code conventions:

| Code | Meaning | When to Handle |
|------|---------|-----------------|
| 0 | Success - validation passed or content found | Continue processing |
| 1 | Validation failure - content missing or invalid | Log error, skip processing |
| 2 | Invalid arguments - missing required flags or bad syntax | Abort, fix command line |

Use exit codes for script workflows:

```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-json config.json
case $? in
  0) echo "Config valid, continuing..." ;;
  1) echo "Config invalid, aborting..." && exit 1 ;;
  2) echo "Invalid arguments" && exit 2 ;;
esac
```

---

## JSON Output Format

All scripts support `--json` flag for machine-readable output:

**Success format:**
```json
{
  "valid": true,
  "message": "Status message"
}
```

**Failure format:**
```json
{
  "valid": false,
  "message": "Short description",
  "error": "Detailed error explanation"
}
```

**Extraction success:**
```json
{
  "valid": true,
  "message": "Section extracted",
  "content": "The extracted content..."
}
```

Use with `jq` for parsing:

```bash
output=$("${SCRIPT_ROOT}/validate-json" --json config.json)
if echo "$output" | jq -e '.valid' >/dev/null; then
  echo "Valid JSON"
else
  echo "Invalid: $(echo "$output" | jq -r '.error')"
fi
```

---

## Dependencies

Each script requires:

- **extract-markdown-section**: `bash`, `sed`, `grep`, `jq` (for JSON output)
- **validate-yaml-frontmatter**: `bash`, `head`, `grep`, `sed`, `jq` (for JSON output)
- **validate-json**: `bash`, `python3`, `jq` (for both field checking and JSON output)
- **validate-markdown-header**: `bash`, `grep`, `jq` (for JSON output)

Install system dependencies on most Linux systems:
```bash
# Debian/Ubuntu
sudo apt-get install -y bash coreutils grep sed python3 jq

# macOS
brew install jq python3  # bash, sed, grep are built-in
```

All scripts verify dependencies at runtime and exit with clear error messages if tools are missing.
