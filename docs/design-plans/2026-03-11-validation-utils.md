# Validation Utils Plugin Design

## Summary

The `validation-utils` plugin is a collection of seven standalone bash scripts that encode common validation patterns Claude frequently needs when verifying its own work — things like checking whether a JSON file is syntactically valid, confirming that a markdown document has the expected headers, or asserting that a git commit touched specific files with specific content. Rather than having Claude hand-generate these multi-stage shell pipelines from scratch each time, the scripts provide tested, reusable building blocks invoked via a single absolute-path command. The expected outcome is a 35–45% reduction in the amount of complex bash Claude must generate inline.

The scripts are grouped into two categories — four general-purpose file-validation utilities and three git commit-verification utilities — each surfaced to Claude through a dedicated skill document (`SKILL.md`). The skills serve as lookup guides that tell Claude when to reach for a script instead of writing equivalent logic by hand, and include before/after comparisons and concrete examples drawn from prior bash-pattern analysis. The plugin follows the existing `ed3d-plugins` conventions for structure, versioning, and marketplace registration, so it integrates with the same loading and discovery machinery used by other plugins in the repository.

## Definition of Done

A `validation-utils` plugin containing **7 executable bash scripts** and **2 documentation skills** that reduce Claude's bash generation overhead by ~35-45% through reusable validation utilities.

**Specific components:**
- **4 validation scripts**: extract-markdown-section, validate-yaml-frontmatter, validate-json, validate-markdown-header
- **3 git verification scripts**: verify-commit-message, verify-commit-files, verify-commit-content
- **2 category skills**: validation-scripts skill + git-verification-scripts skill
- Scripts invoked via absolute paths: `${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/{script-name}`

**Success criteria:**
- Scripts implement the patterns from bash-pattern-extraction-analysis.md with proper error handling
- Skills provide when/how/example guidance that convinces Claude to use scripts instead of hand-rolling bash
- Plugin follows ed3d-plugins conventions (plugin.json, SKILL.md structure, marketplace registration)
- Scripts provide clear diagnostic error messages on failure

**Out of scope:**
- No hooks or event-driven behavior
- No PATH modification
- No additional git patterns (branch divergence, historical extraction deferred)

## Acceptance Criteria

### validation-utils.AC1: All 7 scripts are executable and implement documented patterns
- **validation-utils.AC1.1 Success:** extract-markdown-section extracts content between headers and applies grep filters (--count, --contains, --exclude)
- **validation-utils.AC1.2 Success:** validate-yaml-frontmatter verifies --- delimiters on lines 1 and ≤20, validates required fields
- **validation-utils.AC1.3 Success:** validate-json validates syntax with python3 -m json.tool and field constraints with jq
- **validation-utils.AC1.4 Success:** validate-markdown-header checks header existence with grep -q
- **validation-utils.AC1.5 Success:** verify-commit-message matches commit message patterns with git log + grep
- **validation-utils.AC1.6 Success:** verify-commit-files identifies changed files with git diff --stat
- **validation-utils.AC1.7 Success:** verify-commit-content verifies added content with git show + grep for '+'
- **validation-utils.AC1.8 Failure:** Scripts exit with code 1 when validation fails (e.g., header not found, invalid JSON)
- **validation-utils.AC1.9 Failure:** Scripts exit with code 2 when arguments are invalid (e.g., missing FILE, invalid flags)
- **validation-utils.AC1.10 Edge:** Scripts provide clear error messages to stderr when required tools missing (jq, git, python3)

### validation-utils.AC2: Scripts use absolute path invocation pattern
- **validation-utils.AC2.1 Success:** Scripts work when invoked via ${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/{script-name} from any working directory
- **validation-utils.AC2.2 Success:** Skill documentation shows all examples using absolute path pattern
- **validation-utils.AC2.3 Failure:** Scripts do not assume specific working directory or rely on PATH environment variable

### validation-utils.AC3: Scripts provide consistent output interface
- **validation-utils.AC3.1 Success:** Without --json flag, scripts output "VALID" or diagnostic message to stdout
- **validation-utils.AC3.2 Success:** With --json flag, scripts output parseable JSON: {"valid": true/false, "message": "...", "error": "..."}
- **validation-utils.AC3.3 Success:** Error messages always go to stderr with "ERROR:" prefix
- **validation-utils.AC3.4 Success:** Exit codes are consistent: 0=success, 1=validation failure, 2=invalid usage
- **validation-utils.AC3.5 Edge:** JSON output is parseable by jq even when validation fails

### validation-utils.AC4: Scripts implement robust error handling
- **validation-utils.AC4.1 Success:** All scripts use set -euo pipefail for error detection
- **validation-utils.AC4.2 Success:** Scripts use getopts for argument parsing (not external getopt)
- **validation-utils.AC4.3 Success:** Scripts validate input files exist before processing
- **validation-utils.AC4.4 Failure:** Scripts exit gracefully with helpful message when required dependency missing
- **validation-utils.AC4.5 Failure:** Scripts handle malformed input without silent failures (e.g., invalid regex patterns)

### validation-utils.AC5: Skills provide comprehensive guidance
- **validation-utils.AC5.1 Success:** validation-scripts/SKILL.md documents all 4 validation scripts with usage examples
- **validation-utils.AC5.2 Success:** git-verification-scripts/SKILL.md documents all 3 git scripts with usage examples
- **validation-utils.AC5.3 Success:** Skills include "When to Use" trigger patterns that match common validation scenarios
- **validation-utils.AC5.4 Success:** Skills show before/after comparison demonstrating value over hand-rolled bash
- **validation-utils.AC5.5 Success:** Skills include 3-5 concrete examples per script from real usage patterns
- **validation-utils.AC5.6 Edge:** Skill frontmatter is valid YAML (name, description, user-invocable fields)

### validation-utils.AC6: Plugin follows ed3d-plugins conventions
- **validation-utils.AC6.1 Success:** Plugin has .claude-plugin/plugin.json with required fields (name, version, description, author)
- **validation-utils.AC6.2 Success:** Plugin registered in .claude-plugin/marketplace.json at repo root with matching version
- **validation-utils.AC6.3 Success:** CHANGELOG.md at repo root includes validation-utils 1.0.0 entry
- **validation-utils.AC6.4 Success:** Version numbers match across plugin.json, marketplace.json, and CHANGELOG.md
- **validation-utils.AC6.5 Success:** Plugin structure matches existing plugins (skills/, .claude-plugin/, LICENSE, README.md)

### validation-utils.AC7: Scripts reduce bash generation overhead
- **validation-utils.AC7.1 Success:** extract-markdown-section replaces sed -n + multi-stage grep pipelines with single command
- **validation-utils.AC7.2 Success:** validate-yaml-frontmatter replaces head + multiple grep combinations with single command
- **validation-utils.AC7.3 Success:** validate-json replaces python3 -c + jq combinations with single command
- **validation-utils.AC7.4 Success:** Git scripts replace multi-line git log/diff/show + grep pipelines with single command
- **validation-utils.AC7.5 Edge:** README.md documents expected 35-45% reduction in complex bash generation

## Glossary

- **plugin**: A self-contained directory in the `ed3d-plugins` repository that packages scripts, skills, and a manifest so Claude can discover and use them as a unit.
- **skill**: A markdown document (`SKILL.md`) with a YAML frontmatter header that Claude loads at runtime to learn when and how to use a tool or set of scripts. Skills are documentation artifacts, not executable code.
- **skill frontmatter**: The YAML block at the top of a `SKILL.md` file (delimited by `---`) that carries structured metadata such as `name`, `description`, and `user-invocable`. Required fields are validated as part of this plugin's own acceptance criteria.
- **ed3d-plugins**: The repository that houses the plugin ecosystem; it defines conventions for plugin structure, versioning, and marketplace registration that this plugin must follow.
- **marketplace.json**: A JSON registry file at the root of `ed3d-plugins` that lists every available plugin and its version. New plugins must be added here to be discoverable.
- **`${CLAUDE_PLUGIN_ROOT}`**: An environment variable that resolves to the root of the installed plugins directory. All script invocations use this variable as the base path so scripts work correctly regardless of the shell's current working directory.
- **absolute path invocation**: The pattern of calling a script by its full filesystem path (e.g., `${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/validate-json`) rather than relying on the shell `PATH`. This ensures the correct script is found from any working directory.
- **`set -euo pipefail`**: A bash directive placed at the top of a script that enables strict error detection: `-e` exits on any command failure, `-u` treats unset variables as errors, and `-o pipefail` catches failures in piped commands. Together they prevent scripts from silently continuing after an error.
- **`getopts`**: A bash builtin for parsing short command-line flags (e.g., `--json`, `--count`). The design explicitly requires `getopts` (the builtin) rather than the external `getopt` utility to avoid portability issues across Unix environments.
- **`--json` flag**: An optional flag supported by all seven scripts that switches their output from a human-readable string to a structured JSON object (`{"valid": true/false, "message": "...", "error": "..."}`), making results easier to consume programmatically or via `jq`.
- **exit code**: The integer a script returns to the calling shell upon completion. This plugin standardizes on three values: `0` (success/valid), `1` (validation failure), `2` (invalid arguments or usage error).
- **`jq`**: A command-line tool for parsing, querying, and transforming JSON. Used by `validate-json` for field-level constraint checks and expected to be available for consuming `--json` output.
- **`python3 -m json.tool`**: A Python standard-library module invoked as a command to pretty-print and syntax-check JSON files. Used by `validate-json` as the primary JSON syntax validator before `jq` applies field checks.
- **YAML frontmatter**: A YAML block delimited by `---` lines that appears at the very top of a markdown file to carry structured metadata. Used both in skill documents and validated by the `validate-yaml-frontmatter` script.
- **bash-pattern-extraction-analysis.md**: A prior analysis document in the repository that catalogued recurring multi-stage bash pipelines Claude generates. It serves as the requirements source for which patterns each script must replace.
- **`git diff --stat`**: A git subcommand that summarizes which files changed in a commit and how many lines were added or removed. Used by `verify-commit-files` to check file scope.
- **`git show`**: A git subcommand that displays the full diff and metadata for a commit. Used by `verify-commit-content` to inspect added lines (those prefixed with `+`).
- **`git log`**: A git subcommand that lists commit history. Used by `verify-commit-message` to retrieve and pattern-match commit messages.
- **hand-rolled bash**: Informal term in the document for bash pipelines generated ad hoc by Claude to satisfy a one-off validation need, as opposed to calling a pre-built, tested script.
- **`compute_layout.py`**: An existing utility in the `ed3d-plugins` codebase that lives inside a skill directory. Referenced as the prior art that this plugin deliberately diverges from by using a central `scripts/` directory instead.
- **NERSC**: The National Energy Research Scientific Computing Center; the HPC environment where this plugin is expected to run. Mentioned as the deployment target when asserting that standard Unix utilities are available.

## Architecture

The validation-utils plugin provides standalone bash scripts for common validation patterns, reducing Claude's need to generate complex multi-stage bash commands.

**Plugin structure:**
```
plugins/validation-utils/
├── .claude-plugin/
│   └── plugin.json
├── scripts/                   # Central location for all 7 utilities
│   ├── extract-markdown-section
│   ├── validate-yaml-frontmatter
│   ├── validate-json
│   ├── validate-markdown-header
│   ├── verify-commit-message
│   ├── verify-commit-files
│   └── verify-commit-content
├── skills/
│   ├── validation-scripts/
│   │   └── SKILL.md          # Documents 4 validation scripts
│   └── git-verification-scripts/
│       └── SKILL.md          # Documents 3 git scripts
├── LICENSE
└── README.md
```

**Script invocation pattern:**
All scripts called via absolute paths using `${CLAUDE_PLUGIN_ROOT}/validation-utils/scripts/{script-name}`. This ensures portability across different working directories and follows the hook pattern established in ed3d-plugins.

**Output interface:**
- Default: Human-readable messages ("VALID" or diagnostic error)
- With `--json` flag: Structured output `{"valid": true/false, "message": "...", "error": "..."}`
- Errors always to stderr with "ERROR:" prefix
- Exit codes: 0=success, 1=validation failure, 2=invalid arguments

**Error handling:**
All scripts use `set -euo pipefail` for robust error detection and `getopts` for argument parsing, following 2025 bash best practices.

## Existing Patterns

Investigation of ed3d-plugins codebase revealed **no existing validation scripts**. This plugin introduces validation utilities as a new pattern.

**Patterns followed from existing codebase:**
- **Plugin structure**: Matches ed3d-plan-and-execute, ed3d-basic-agents layout (.claude-plugin/, skills/, README.md)
- **Skill documentation**: YAML frontmatter format from existing skills (name, description, user-invocable)
- **Absolute path invocation**: Follows hook pattern using `${CLAUDE_PLUGIN_ROOT}` (from ed3d-basic-agents/hooks/session-start.sh)
- **Version synchronization**: plugin.json, marketplace.json, and CHANGELOG.md must all match (per ed3d-plugins/CLAUDE.md)

**Script organization diverges from compute_layout.py pattern:**
The existing `compute_layout.py` utility lives directly in its skill directory (`skills/doing-a-simple-two-stage-fanout/`). This plugin uses a central `scripts/` directory instead because:
- 7 scripts shared across 2 skills (not 1:1 relationship)
- Utility collection pattern (all validation-related scripts centralized)
- Easier maintenance and discoverability

**Script implementation follows modern bash conventions:**
- Shebang: `#!/usr/bin/env bash` for portability
- Error handling: `set -euo pipefail` with error_exit() function
- Argument parsing: getopts builtin (not external getopt)
- Structured output: Optional JSON mode with --json flag

## Implementation Phases

<!-- START_PHASE_1 -->
### Phase 1: Plugin Infrastructure
**Goal:** Create plugin directory structure, manifest, and registration

**Components:**
- `plugins/validation-utils/.claude-plugin/plugin.json` - Plugin manifest (v1.0.0)
- `plugins/validation-utils/scripts/` - Empty directory for scripts
- `plugins/validation-utils/skills/validation-scripts/SKILL.md` - Placeholder with frontmatter
- `plugins/validation-utils/skills/git-verification-scripts/SKILL.md` - Placeholder with frontmatter
- `plugins/validation-utils/LICENSE` - License file (copy from ed3d-plugins)
- `plugins/validation-utils/README.md` - Basic plugin description
- `.claude-plugin/marketplace.json` - Add validation-utils entry (at repo root)
- `CHANGELOG.md` - Add validation-utils 1.0.0 entry (at repo root)

**Dependencies:** None (first phase)

**Done when:** Plugin structure exists, manifests valid JSON, registered in marketplace, committed to git
<!-- END_PHASE_1 -->

<!-- START_PHASE_2 -->
### Phase 2: Validation Scripts (High-Priority)
**Goal:** Implement 4 validation scripts in priority order from bash-pattern-extraction-analysis.md

**Components:**
- `plugins/validation-utils/scripts/extract-markdown-section` - Extracts content between markdown headers (sed + grep filters)
- `plugins/validation-utils/scripts/validate-yaml-frontmatter` - Verifies YAML frontmatter structure and required fields
- `plugins/validation-utils/scripts/validate-json` - Validates JSON syntax and optional field constraints (python3 -m json.tool, jq)
- `plugins/validation-utils/scripts/validate-markdown-header` - Checks if specific header exists (grep -q)

Each script includes:
- Shebang `#!/usr/bin/env bash`, `set -euo pipefail`
- getopts argument parsing
- error_exit() function for consistent error handling
- --json flag support
- Inline usage documentation in comments

**Dependencies:** Phase 1 (plugin structure exists)

**Done when:** All 4 scripts executable, implement patterns from analysis document, exit codes correct (0/1/2), --json output valid JSON, manual testing confirms behavior matches analysis examples
<!-- END_PHASE_2 -->

<!-- START_PHASE_3 -->
### Phase 3: Git Verification Scripts
**Goal:** Implement 3 git commit verification scripts

**Components:**
- `plugins/validation-utils/scripts/verify-commit-message` - Check if commit message matches pattern (git log + grep)
- `plugins/validation-utils/scripts/verify-commit-files` - Check which files changed in commit (git diff --stat)
- `plugins/validation-utils/scripts/verify-commit-content` - Verify specific content was added (git show + grep for '+pattern')

Each script includes:
- Same error handling and argument parsing patterns as Phase 2
- --commit flag to specify non-HEAD commit reference
- --json flag support
- Clear error messages when git operations fail

**Dependencies:** Phase 2 (validation script patterns established)

**Done when:** All 3 git scripts executable, implement patterns from codebase investigation, exit codes correct, manual testing with git repositories confirms behavior
<!-- END_PHASE_3 -->

<!-- START_PHASE_4 -->
### Phase 4: Skill Documentation - Validation Scripts
**Goal:** Complete validation-scripts/SKILL.md with comprehensive documentation

**Components:**
- `plugins/validation-utils/skills/validation-scripts/SKILL.md` - Full documentation

Content sections:
- When to Use (trigger patterns: "checking if JSON is valid", "extracting markdown sections", etc.)
- When NOT to Use (custom logic needed, scripts unavailable)
- Quick Reference table (Script | Use Case | Example Command | Exit Code)
- Detailed documentation for each of 4 scripts:
  - Purpose and problem it solves
  - Full usage syntax with all flags
  - 3-5 concrete examples from bash-pattern-extraction-analysis.md
  - Common errors and troubleshooting
- Before/After comparison showing old way (complex bash) vs new way (script call)

**Dependencies:** Phase 2 (validation scripts exist to document)

**Done when:** SKILL.md complete with examples, Skill frontmatter valid YAML (name: validation-scripts, description, user-invocable: false), documentation convincingly argues for using scripts over hand-rolled bash
<!-- END_PHASE_4 -->

<!-- START_PHASE_5 -->
### Phase 5: Skill Documentation - Git Verification Scripts
**Goal:** Complete git-verification-scripts/SKILL.md with comprehensive documentation

**Components:**
- `plugins/validation-utils/skills/git-verification-scripts/SKILL.md` - Full documentation

Content sections:
- When to Use (verifying commits match acceptance criteria, checking file scope, validating content changes)
- When NOT to Use
- Quick Reference table
- Detailed documentation for each of 3 git scripts with examples
- Use cases from implementation plan verification workflows

**Dependencies:** Phase 3 (git scripts exist to document)

**Done when:** SKILL.md complete, frontmatter valid, examples demonstrate value for commit verification workflows
<!-- END_PHASE_5 -->

<!-- START_PHASE_6 -->
### Phase 6: Integration Testing and README
**Goal:** Validate scripts work in realistic scenarios and document plugin usage

**Components:**
- `plugins/validation-utils/README.md` - Complete with:
  - Plugin purpose and benefits
  - Installation instructions
  - Quick start examples for each script
  - Links to skill documentation
  - Expected impact metrics (35-45% reduction in bash generation)
- Test scenarios covering:
  - All 7 scripts invoked from different working directories
  - --json flag output parseable by jq
  - Error cases (missing files, invalid input, malformed data)
  - Real-world patterns from bash-pattern-extraction-analysis.md

**Dependencies:** Phase 4, Phase 5 (all scripts and documentation complete)

**Done when:** README.md complete, all 7 scripts tested successfully with realistic inputs, error messages clear and actionable, plugin ready for use
<!-- END_PHASE_6 -->

## Additional Considerations

**Script dependencies:**
- `validate-json` requires `python3` (for json.tool) and `jq` (for field validation)
- `extract-markdown-section` requires `sed` and `grep`
- `validate-yaml-frontmatter` requires `head` and `grep`
- Git scripts require `git` command available

All dependencies are standard unix utilities available on NERSC systems and typical development environments. Scripts should check for required tools and provide helpful error messages if missing.

**Future extensibility:**
The central scripts/ directory and skill-based documentation pattern allows adding new validation scripts without restructuring the plugin. Potential future additions could include:
- Additional git patterns (branch divergence, historical file extraction) deferred from analysis
- Result counting utilities (if extracted later)
- Other validation patterns identified through usage

However, these are explicitly out of scope for v1.0.0.
