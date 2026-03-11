# validation-utils

Reusable bash validation scripts for file and git verification. Reduces Claude's bash generation overhead by 35-45% through tested, standalone utilities.

## The Problem

Claude frequently needs to validate its own work — checking if JSON is valid, confirming markdown headers exist, verifying git commits touched specific files with specific content. Without reusable scripts, Claude generates complex multi-stage bash pipelines from scratch each time, increasing token usage and error potential.

## The Solution

Seven standalone bash scripts that encode common validation patterns:

**Validation scripts:**
- `extract-markdown-section` - Extract content between markdown headers with grep filters
- `validate-yaml-frontmatter` - Verify YAML frontmatter structure and required fields
- `validate-json` - Validate JSON syntax and optional field constraints
- `validate-markdown-header` - Check if specific header exists

**Git verification scripts:**
- `verify-commit-message` - Check if commit message matches pattern
- `verify-commit-files` - Check which files changed in commit
- `verify-commit-content` - Verify specific content was added

All scripts:
- Use `set -euo pipefail` for robust error detection
- Support `--json` flag for structured output
- Provide clear diagnostic error messages
- Use getopts for argument parsing
- Follow consistent exit codes (0=success, 1=validation failure, 2=invalid usage)

## Usage

Scripts are invoked via absolute paths using `${CLAUDE_PLUGIN_ROOT}`:

```bash
# Validate JSON file
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-json config.json

# Extract markdown section with filters
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/extract-markdown-section \
  --section "## Installation" \
  --contains "npm install" \
  design.md

# Verify commit touched specific files
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files \
  --file "src/auth.ts" \
  --commit HEAD

# Get structured JSON output
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-json --json config.json
```

See skill documentation in `skills/` for detailed usage and examples.

## Impact

Expected 35-45% reduction in complex bash generation for validation tasks, based on analysis of recurring bash patterns Claude generates.

## License

Creative Commons Attribution-ShareAlike 4.0 International License
