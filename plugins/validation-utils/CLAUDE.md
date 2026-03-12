# validation-utils

Last verified: 2026-03-11

## Purpose

Provides reusable bash validation scripts so Claude avoids generating complex multi-stage bash pipelines from scratch each time it needs to validate files or verify git state.

## Contracts

- **Exposes**: 7 standalone bash scripts in `scripts/` invoked via `${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/<name>`
  - Validation: `validate-json`, `validate-yaml-frontmatter`, `validate-markdown-header`, `extract-markdown-section`
  - Git verification: `verify-commit-message`, `verify-commit-files`, `verify-commit-content`
- **Guarantees**:
  - All scripts use `set -euo pipefail`
  - All scripts support `--json` flag for structured output
  - Exit codes: 0 = success, 1 = validation failure, 2 = invalid usage
  - All scripts use getopts for argument parsing
- **Expects**: `bash`, `grep`, `sed` available; `validate-json` requires `python3` and `jq`; git scripts require `git` and a git repository

## Dependencies

- **Uses**: Standard Unix utilities, python3, jq, git
- **Used by**: Any Claude session needing file validation or git verification
- **Boundary**: Scripts are standalone; no inter-script dependencies

## Key Decisions

- Bash over Python: Scripts stay lightweight and avoid runtime dependency complexity
- `--json` flag convention: Enables programmatic consumption of validation results
- Consistent exit codes (0/1/2): Callers can distinguish success, validation failure, and usage error

## Invariants

- Scripts never modify files -- they are read-only validators
- JSON output (when `--json`) is always valid JSON, even on error paths
- Every script includes `-h` help text documenting options and examples

## Key Files

- `scripts/` - All 7 executable validation scripts
- `skills/validation-scripts/SKILL.md` - Usage guidance for validation scripts
- `skills/git-verification-scripts/SKILL.md` - Usage guidance for git scripts
- `.claude-plugin/plugin.json` - Plugin metadata (v1.0.0)
