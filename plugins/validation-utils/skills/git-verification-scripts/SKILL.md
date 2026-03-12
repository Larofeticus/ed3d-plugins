---
name: git-verification-scripts
description: Use when verifying git commits against acceptance criteria (message patterns, file changes, content additions) - provides tested scripts instead of hand-rolling git pipelines
user-invocable: false
---

# Git Verification Scripts

A collection of battle-tested bash scripts for verifying git commit content against acceptance criteria. These scripts eliminate hand-rolled git verification by providing reliable, consistent exit codes and structured JSON output for CI/CD and implementation plan verification workflows.

## When to Use

Use this skill when you need to:

- **Verifying commits match acceptance criteria** - All 3 scripts support validation workflows
- **Checking if commit message contains keyword** - `verify-commit-message` searches message and body
- **Validating specific files were changed** - `verify-commit-files` confirms file paths in diff
- **Confirming code was added to commit** - `verify-commit-content` searches added lines only
- **Implementation plan verification workflows** - Use in phase completion verification scripts
- **Post-commit validation in CI/CD** - All scripts return consistent exit codes: 0=valid, 1=invalid, 2=bad args
- **Need structured --json output for parsing** - All scripts support `--json` flag for machine-readable output

## When NOT to Use

Don't use these scripts when you need to:

- **Pre-commit validation** - Use git hooks instead for validation before committing
- **Branch comparison across many commits** - Scripts verify single commits; use git log for historical analysis
- **Not in a git repository** - Scripts require git context; verify with `git rev-parse --git-dir`
- **Historical analysis across many commits** - Use `git log` directly for bulk operations
- **Comparing two branches** - These scripts work on single commits; use git diff for branch comparison

## Quick Reference

| Script | Use Case | Example Command | Exit Codes |
|--------|----------|-----------------|------------|
| verify-commit-message | Match message pattern | `${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-message -p "feat:" -c HEAD` | 0=match, 1=no match, 2=invalid args |
| verify-commit-files | Check files changed | `${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "src/" -c HEAD` | 0=changed, 1=not changed, 2=invalid args |
| verify-commit-content | Verify added content | `${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "function" -c HEAD` | 0=found, 1=not found, 2=invalid args |

---

## verify-commit-message

### Purpose

Checks if a commit message (subject and body combined) matches a grep regex pattern. Useful for validating conventional commits, ensuring keywords are present, or confirming required prefixes exist in the commit message.

### Usage

```
Usage: verify-commit-message --pattern "PATTERN" [OPTIONS]

Check if a commit message matches a pattern using grep regex.

OPTIONS:
  -p, --pattern=PATTERN  Grep pattern to match (required, can be regex)
  -c, --commit=REF       Commit reference (default: HEAD)
  --json                 Output JSON: {"valid": true/false, "message": "...", "error": "..."}
  -h                     Show this help

EXIT CODES:
  0 - Pattern matches commit message
  1 - Pattern doesn't match, commit not found, or not in git repository
  2 - Invalid arguments
```

### Examples

**Validate conventional commit format:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-message -p "^feat:\|^fix:\|^docs:" -c HEAD
```

Returns 0 if commit message starts with feat:, fix:, or docs:

**Check for required keyword:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-message -p "validation-utils" -c HEAD
```

Confirms "validation-utils" appears anywhere in commit message or body

**Verify phase reference:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-message -p "Phase 2\|phase_02" -c HEAD
```

Ensures commit message references Phase 2 implementation

**Check for AC (Acceptance Criteria) reference:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-message -p "AC[0-9]" -c HEAD~1
```

Validates that previous commit references acceptance criteria

**JSON output for CI/CD parsing:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-message -p "test:" --json -c HEAD
```

Returns structured output:
```json
{"valid": true, "message": "Pattern matches commit message", "commit": "HEAD", "subject": "test: add unit tests for validation"}
```

### Common Errors

**Error: Not in a git repository**
```
ERROR: Not in a git repository
```
Solution: Run from within a git repository directory

**Error: Commit reference does not exist**
```
ERROR: Commit reference does not exist: HEAD~5
```
Solution: Verify commit reference exists with `git log --oneline` or use shorter history

**Error: Pattern required**
```
ERROR: Pattern required (use -p or --pattern)
```
Solution: Always provide `-p PATTERN` argument

### Tips

- Pattern uses grep regex syntax - escape special characters like `|`, `(`, `)` if literal matching
- When checking multiple patterns, use regex alternation: `"^feat:\|^fix:\|^docs:"`
- The pattern searches both subject line and full body - use `^` to anchor to start
- Use `--json` for CI/CD integration to parse validation results programmatically
- For phase verification, check commit message with keywords like `"Phase [0-9]"` or `"phase_[0-9]{2}"`

---

## verify-commit-files

### Purpose

Checks which files changed in a commit and validates that specific file paths were modified. Useful for verifying that expected files were included in a commit or detecting unintended file changes.

### Usage

```
Usage: verify-commit-files --file "PATH" [OPTIONS]

Check if a specific file was changed in a commit using git diff --stat.

OPTIONS:
  -f, --file=PATH        File path pattern to check (required, can be glob)
  -c, --commit=REF       Commit reference (default: HEAD)
  --json                 Output JSON: {"valid": true/false, "message": "...", "files": [...]}
  -h                     Show this help

EXIT CODES:
  0 - File was changed in commit
  1 - File not changed, commit not found, or not in git repository
  2 - Invalid arguments
```

### Examples

**Verify specific file was modified:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "src/auth.ts" -c HEAD
```

Confirms src/auth.ts appears in the commit's changed files

**Check directory changes with glob pattern:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "plugins/validation-utils/" -c HEAD
```

Validates that some file in plugins/validation-utils/ was changed

**Verify script was created in Phase 2:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "plugins/validation-utils/scripts/extract-markdown-section" -c HEAD~3
```

Confirms extract-markdown-section script was added 3 commits ago (implementation plan verification)

**Verify Phase 3 scripts exist:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "scripts/verify-commit-message" -c HEAD
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "scripts/verify-commit-files" -c HEAD
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "scripts/verify-commit-content" -c HEAD
```

Implementation plan verification: confirm all 3 git verification scripts were created

**JSON output shows all matching files:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "\.md$" --json -c HEAD
```

Returns structured output with all markdown files changed:
```json
{"valid": true, "message": "File(s) changed in commit", "commit": "HEAD", "files": ["README.md", "CHANGELOG.md"]}
```

### Common Errors

**Error: File not changed in commit**
```
ERROR: File pattern did not match any changed files: src/nonexistent.ts
```
Solution: Verify file path with `git show --name-only HEAD` or use glob pattern for directory

**Error: Pattern is literal string, not glob**
```
# This won't work as expected - pattern is literal
verify-commit-files -f "src/*.ts"
```
Solution: Patterns use grep regex; use `"src/.*\.ts"` for regex or check exact path

**Error: Commit reference is invalid**
```
ERROR: Commit reference does not exist: HEAD~20
```
Solution: Use shorter history reference or specific commit SHA

### Tips

- File patterns use grep regex syntax - use `"src/.*\.ts"` to match TypeScript files in src/
- For directory matching, end path with `/` or use `"plugins/validation-utils/"` pattern
- Use `--json` to get full list of changed files for parsing in scripts
- When verifying implementation plan phases, check key files: scripts, SKILL.md, tests
- Patterns are matched as substrings in file paths; use `^` and `$` to match exact paths

---

## verify-commit-content

### Purpose

Verifies that specific content was added in a commit by searching only the added lines (with `+` prefix). Useful for confirming that functions, imports, configuration values, or other code was actually added to the repository.

### Usage

```
Usage: verify-commit-content --pattern "PATTERN" [OPTIONS]

Verify that specific content was added in a commit by checking lines with '+' prefix.

OPTIONS:
  -p, --pattern=PATTERN  Grep pattern to find in added lines (required)
  -c, --commit=REF       Commit reference (default: HEAD)
  --json                 Output JSON: {"valid": true/false, "message": "...", "matches": [...]}
  -h                     Show this help

EXIT CODES:
  0 - Pattern found in added content
  1 - Pattern not found, commit not found, or not in git repository
  2 - Invalid arguments
```

### Examples

**Confirm bash shebang in new scripts:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "#!/usr/bin/env bash" -c HEAD
```

Validates that Phase 3 scripts include the bash shebang in added lines (implementation plan verification)

**Verify function was added:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "function login" -c HEAD
```

Confirms function login() was actually added to the commit, not just modified

**Check for required import:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "import.*Auth" -c HEAD
```

Uses regex to find import statements for Auth module in newly added code

**Verify version update:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "version.*1.0.0" -c HEAD
```

Confirms version string was updated in the commit

**Verify markdown content in added lines:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "## When to Use" -c HEAD
```

For documentation commits, confirm section headers were added

**JSON output with matches:**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "test:" --json -c HEAD
```

Returns structured output with matching lines:
```json
{"valid": true, "message": "Pattern found in added content", "commit": "HEAD", "match_count": 3, "matches": ["test: add unit tests", "test: verify output"]}
```

### Common Errors

**Error: Pattern not found in added content**
```
ERROR: Pattern not found in added content: removed_function
```
Solution: Verify pattern appears in newly added lines only (not in context). Use `git show HEAD` to see the diff.

**Error: Pattern matches but was pre-existing**
```
# Pattern exists but wasn't added in this commit
verify-commit-content -p "existing_function"
```
Solution: This script only searches added lines - the function likely existed before this commit

**Error: Regex special characters need escaping**
```
# This will fail to match
verify-commit-content -p "(function|class)" -c HEAD
```
Solution: Escape characters: `"(function|class)"` or use literal: `"function"` or `"class"`

### Tips

- Content patterns use grep regex syntax - be careful with special characters
- This script only searches added lines (prefixed with `+` in diff) - pre-existing content won't match
- Use `.` for any character and `.*` for any string: `"import.*module"` finds import statements
- Match common code patterns: `"function"`, `"class"`, `"def "`, `"const"`, `"let"`, `"var"`
- For multiline content verification, match a distinctive single line instead
- Use `--json` to extract match_count for assertions: confirm N lines were added

---

## Implementation Plan Verification Use Cases

### Verify Phase 2 Completion

When Phase 2 (validation scripts) is complete, run these checks:

```bash
# Verify commit references Phase 2
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-message -p "Phase 2\|phase_02" -c HEAD

# Verify all 4 scripts were created
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "plugins/validation-utils/scripts/extract-markdown-section" -c HEAD
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "plugins/validation-utils/scripts/validate-json" -c HEAD
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "plugins/validation-utils/scripts/validate-markdown-header" -c HEAD
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "plugins/validation-utils/scripts/validate-yaml-frontmatter" -c HEAD

# Confirm scripts have bash shebang (added content check)
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "#!/usr/bin/env bash" -c HEAD
```

All should return exit code 0.

### Verify Phase 3 Git Verification Scripts

Phase 3 implements the 3 git verification scripts. Verification workflow:

```bash
# Confirm commit message references Phase 3
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-message -p "Phase 3\|git.*verif" -c HEAD

# Verify all 3 scripts were created
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "scripts/verify-commit-message" -c HEAD
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "scripts/verify-commit-files" -c HEAD
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "scripts/verify-commit-content" -c HEAD

# Confirm all scripts have proper structure
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "#!/usr/bin/env bash" -c HEAD
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "error_exit" -c HEAD
```

### Verify AC1.1 Implementation

Acceptance Criteria 1.1 requires extract-markdown-section script. Verification:

```bash
# AC1.1: extract-markdown-section implemented
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "scripts/extract-markdown-section" -c HEAD
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "extract-markdown-section" -c HEAD
```

### Verify AC5.2 (git-verification-scripts Skill Documentation)

When Phase 5 completes skill documentation:

```bash
# Verify skill documentation exists
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "skills/git-verification-scripts/SKILL.md" -c HEAD

# Verify documentation includes all 3 scripts
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "## verify-commit-message" -c HEAD
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "## verify-commit-files" -c HEAD
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "## verify-commit-content" -c HEAD

# Verify examples are included
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "Examples" -c HEAD
```

---

## Before/After Comparisons

### Scenario 1: Check commit message contains keyword

**Before (hand-rolled bash):**
```bash
git log --format="%s" -n 1 HEAD | grep -q "feat:" && echo "VALID" || echo "INVALID"
```

**After (using verify-commit-message):**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-message -p "feat:" && echo "VALID" || echo "INVALID"
```

**Benefits:**
- 50% fewer characters
- Clearer intent
- Handles edge cases (commit not found, not in repo)
- Exit code semantics are explicit

### Scenario 2: Verify specific file changed in commit

**Before (hand-rolled bash):**
```bash
git diff --name-only HEAD^ HEAD | grep -q "src/auth.ts" && echo "VALID" || echo "INVALID"
```

**After (using verify-commit-files):**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-files -f "src/auth.ts" && echo "VALID" || echo "INVALID"
```

**Benefits:**
- 50% fewer tokens
- Handles first commit case automatically
- Pattern matching (glob regex) included
- JSON output option for CI/CD

### Scenario 3: Confirm function was added

**Before (hand-rolled bash):**
```bash
git show HEAD | grep "^+" | grep -v "^+++" | grep -q "function login" && echo "VALID" || echo "INVALID"
```

**After (using verify-commit-content):**
```bash
${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/verify-commit-content -p "function login" && echo "VALID" || echo "INVALID"
```

**Benefits:**
- 60% fewer tokens
- No need to understand diff format (^+, ^^^)
- Automatically handles added lines
- Match count available in JSON output

