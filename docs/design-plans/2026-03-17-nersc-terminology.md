# NERSC Terminology Disambiguation Design

## Summary

This design creates a `nersc-support` plugin that prevents Claude from misinterpreting NERSC-specific terminology when assisting users with NERSC systems and workflows. The core challenge is semantic confusion: terms like "scratch," "archive," and "home" have generic computing meanings that differ significantly from their NERSC-specific meanings (Lustre filesystem, HPSS tape storage, and $HOME filesystem respectively). Without domain-specific context, Claude may provide incorrect guidance based on general computing knowledge rather than NERSC operational reality.

The solution embeds a compact term index (142 terms organized into 8 categories) directly in the skill document, with each term mapped to a precise 7-line glossary entry. When Claude encounters an indexed term during NERSC-related work, it extracts the corresponding glossary entry using the Read tool to obtain: (1) NERSC-specific meaning, (2) common AI confusion patterns, (3) impact of misunderstanding, and (4) research keywords. The skill auto-activates based on NERSC-specific keywords in conversation context (Perlmutter, Cori, HPSS, etc.) and tracks which terms have been consulted during the session to avoid redundant lookups. This just-in-time definition retrieval prevents semantic errors while minimizing context usage (typical session: 5-15 terms = 2-5KB of glossary data).

## Definition of Done

A `nersc-support` plugin with `nersc-terminology` skill that:
1. Auto-activates when Claude works with NERSC systems, users, or services
2. Contains embedded index of 142 terms → line number ranges
3. Extracts and reads glossary entries when terms appear (once per term per session)
4. Provides NERSC-specific meaning, common confusions, and research keywords
5. Prevents semantic confusion that would otherwise lead to incorrect guidance

## Acceptance Criteria

### nersc-terminology.AC1: Skill auto-activates on NERSC context
- **nersc-terminology.AC1.1 Success:** Skill activates when conversation mentions Perlmutter, Cori, HPSS, or other NERSC systems
- **nersc-terminology.AC1.2 Success:** Skill activates when helping NERSC users with job scheduling, storage, or system issues
- **nersc-terminology.AC1.3 Success:** Skill provides term index and glossary access in NERSC-related work
- **nersc-terminology.AC1.4 Failure:** Skill does not activate in non-NERSC context (e.g., generic HPC discussion without NERSC specifics)
- **nersc-terminology.AC1.5 Edge:** Skill handles ambiguous context (HPC terms that could be NERSC or generic) by activating conservatively

### nersc-terminology.AC2: Term index is complete and accurate
- **nersc-terminology.AC2.1 Success:** All 142 terms present in skill document term index
- **nersc-terminology.AC2.2 Success:** All 142 line ranges correctly map to their glossary entries (term name matches on line 1)
- **nersc-terminology.AC2.3 Success:** Terms organized into 8 category tables matching glossary structure
- **nersc-terminology.AC2.4 Failure:** Validation script detects and reports any missing or malformed term mappings
- **nersc-terminology.AC2.5 Edge:** Compact 3-column table format fits all 142 terms in skill document without excessive length

### nersc-terminology.AC3: Glossary extraction works correctly
- **nersc-terminology.AC3.1 Success:** First mention of indexed term triggers Read tool extraction of its 7-line glossary entry
- **nersc-terminology.AC3.2 Success:** Subsequent mentions of same term in session recall previous read (no redundant extraction)
- **nersc-terminology.AC3.3 Success:** Multiple different terms in single message all trigger appropriate extractions
- **nersc-terminology.AC3.4 Failure:** Malformed line range (extracts wrong content) handled gracefully without breaking response
- **nersc-terminology.AC3.5 Failure:** Missing glossary file results in degraded mode with notification rather than hard failure
- **nersc-terminology.AC3.6 Edge:** Case-insensitive term matching (SCRATCH, scratch, Scratch all trigger same entry)

### nersc-terminology.AC4: Glossary entries provide complete information
- **nersc-terminology.AC4.1 Success:** Each glossary entry contains NERSC-specific meaning (line 3)
- **nersc-terminology.AC4.2 Success:** Each entry documents common AI confusion pattern (line 5)
- **nersc-terminology.AC4.3 Success:** Each entry explains impact of misunderstanding (line 6)
- **nersc-terminology.AC4.4 Success:** Each entry provides research keywords for deeper investigation (line 7)
- **nersc-terminology.AC4.5 Success:** Claude incorporates NERSC-specific definition into response before answering user

### nersc-terminology.AC5: Semantic confusion prevented
- **nersc-terminology.AC5.1 Success:** Claude uses NERSC meaning of "scratch" (Lustre filesystem) not generic meaning (discard data)
- **nersc-terminology.AC5.2 Success:** Claude uses NERSC meaning of "archive" (HPSS tape storage) not generic meaning (compressed file)
- **nersc-terminology.AC5.3 Success:** Claude uses NERSC meaning of "home" ($HOME filesystem) not generic meaning (residence)
- **nersc-terminology.AC5.4 Success:** User receives accurate guidance about NERSC storage, scheduling, and system usage
- **nersc-terminology.AC5.5 Edge:** Ambiguous terms like "CFS" resolved to NERSC Community File System not unrelated acronyms

### nersc-terminology.AC6: Cross-Cutting Behaviors
- **nersc-terminology.AC6.1:** Validation script confirms 100% accuracy before plugin release (all 142 terms extract correctly)
- **nersc-terminology.AC6.2:** Plugin follows ed3d-plugins conventions (YAML frontmatter, standard sections, marketplace sync)
- **nersc-terminology.AC6.3:** Glossary file integrity verified during Phase 2 (86KB size, correct structure, line ranges match metadata)

## Glossary

- **NERSC**: National Energy Research Scientific Computing Center, a high-performance computing facility operated by Lawrence Berkeley National Laboratory for the Department of Energy's Office of Science
- **Perlmutter**: NERSC's primary production supercomputer (HPE Cray EX system), referenced in skill auto-activation keywords
- **Cori**: NERSC's previous-generation supercomputer (decommissioned), still mentioned in documentation and historical context
- **HPSS**: High Performance Storage System, NERSC's tape-based archival storage backend (commonly confused with generic "archive" meaning compressed files)
- **Lustre**: High-performance parallel distributed filesystem used for NERSC scratch storage (not "Luster" - common typo)
- **QoS**: Quality of Service, Slurm job scheduling feature used at NERSC to manage resource allocation and priority queues
- **Slurm**: Workload manager used for job scheduling on NERSC systems
- **Auto-activation**: Claude Code skill discovery mechanism where skill descriptions containing specific keywords trigger automatic skill inclusion when conversation context matches
- **Skill frontmatter**: YAML metadata block at the beginning of skill documents defining name, description, user-invocable status, and other properties
- **Semantic confusion**: Situation where terms have different meanings in specific domain contexts vs. general usage, leading AI models to provide incorrect interpretations based on pre-training knowledge
- **CLAUDE_PLUGIN_ROOT**: Environment variable pattern used in ed3d-plugins for referencing files within plugin directory structures
- **Line range extraction**: Using Read tool's offset and limit parameters to extract specific contiguous lines from a file (this design uses fixed 7-line entries with 8-line spacing)
- **Session tracking**: Maintaining awareness of which terms have been looked up during current conversation to avoid redundant file reads (implemented via guideline-based memory rather than explicit state)
- **Creative Commons Attribution-ShareAlike 4.0**: License used for ed3d-plugins content requiring attribution and derivative works to use the same license

## Architecture

The nersc-terminology skill prevents semantic confusion by providing on-demand access to NERSC-specific term definitions during support interactions. The architecture consists of three layers:

**Auto-Activation Layer:** Skill description contains NERSC-specific keywords (Perlmutter, Cori, HPSS, storage, scheduling) that trigger Claude's skill discovery system when conversation context matches. Setting `user-invocable: false` ensures automatic activation based on context rather than explicit user invocation.

**Term Index Layer:** Skill document embeds a compact lookup table mapping 142 NERSC terms to their line number ranges in the glossary file. Terms organized into 8 category tables (Filesystems, Services, Commands, QoS, Infrastructure, Concepts, Tools, Acronyms) enable quick scanning and provide category context. Each term maps to a precise 7-line range in the glossary using the formula: `base_line + (N-1) * 8` to `base_line + (N-1) * 8 + 6`.

**Glossary Access Layer:** When Claude encounters a listed term during NERSC work, the skill instructs extraction of the specific 7-line entry using the Read tool. Each entry provides: (1) NERSC-specific meaning, (2) common AI confusion pattern, (3) impact of misunderstanding, and (4) research keywords. Session efficiency managed through guideline-based tracking: "Before extracting, check conversation history. If already read this session, reuse that knowledge."

**Data Flow:**
1. User mentions NERSC system/service → Skill auto-activates
2. Claude detects term from embedded index (e.g., "scratch")
3. Check session history: already consulted this term?
4. If not: Read tool extracts lines 86-92 from glossary file
5. Incorporate definition before generating response
6. Subsequent mentions of "scratch" recall previous read (no re-extraction)

**File Organization:**
- Plugin structure: `plugins/nersc-support/`
- Skill location: `skills/nersc-terminology/SKILL.md`
- Glossary location: `skills/nersc-terminology/semantic_confusion_glossary.md` (colocated with skill)
- Source glossary: `/global/homes/w/warndt/glossary_builder/semantic_confusion_glossary.md` (copied during implementation)

## Existing Patterns

Investigation of ed3d-plugins marketplace revealed several patterns this design follows:

**Skill Structure (from validation-utils, ed3d-extending-claude):**
- YAML frontmatter with `name`, `description`, `user-invocable` fields
- Description-based auto-activation: keywords in description trigger skill discovery
- Standard sections: Overview, When to Use, When NOT to Use, Quick Reference, Examples
- `user-invocable: false` for auto-activated workflow/discipline skills

**File References (from validation-utils):**
- Skills reference external files using `${CLAUDE_PLUGIN_ROOT}/[plugin-name]/[path]` pattern
- validation-utils colocates scripts with skills: `plugins/validation-utils/scripts/` and `plugins/validation-utils/skills/`
- This design follows same pattern: glossary colocated at `skills/nersc-terminology/semantic_confusion_glossary.md`

**Marketplace Versioning (from CLAUDE.md conventions):**
- Three-file sync required: `plugin.json`, `.claude-plugin/marketplace.json`, `CHANGELOG.md`
- All three must have matching version numbers
- Changelog entry format: `## [plugin-name] version` with New/Changed/Fixed sections

**No divergence from existing patterns.** This design introduces a new plugin using established conventions. The term index approach (embedding 142 terms with line ranges in skill text) is novel to this marketplace but follows the general pattern of skills referencing external data files.

## Implementation Phases

<!-- START_PHASE_1 -->
### Phase 1: Plugin Infrastructure Setup

**Goal:** Create plugin directory structure and foundational metadata files

**Components:**
- `plugins/nersc-support/.claude-plugin/plugin.json` — plugin metadata (name, version, author, keywords)
- `plugins/nersc-support/CLAUDE.md` — project context documenting purpose, contracts, dependencies
- `plugins/nersc-support/README.md` — user-facing documentation explaining semantic confusion prevention
- `plugins/nersc-support/LICENSE` — Creative Commons Attribution-ShareAlike 4.0 license file

**Dependencies:** None (first phase)

**Done when:** Directory structure exists, all metadata files created with correct content, `plugin.json` validates as proper JSON
<!-- END_PHASE_1 -->

<!-- START_PHASE_2 -->
### Phase 2: Glossary File Integration

**Goal:** Copy and verify glossary file in plugin structure

**Components:**
- `plugins/nersc-support/skills/nersc-terminology/` directory created
- `semantic_confusion_glossary.md` copied from `/global/homes/w/warndt/glossary_builder/semantic_confusion_glossary.md`
- File integrity verified (86KB size, 142 terms, 8 categories, line ranges match metadata)

**Dependencies:** Phase 1 (plugin structure exists)

**Done when:** Glossary file exists at correct location, file size matches source (86KB), spot-check of 3-5 terms confirms line ranges extract correct content
<!-- END_PHASE_2 -->

<!-- START_PHASE_3 -->
### Phase 3: Term Index Extraction

**Goal:** Build complete term-to-line-range mapping for all 142 terms

**Components:**
- Term extraction script (temporary, can be bash/python/node)
- Term index data structure: 8 category tables mapping term → line range
- Validation: verify each line range extracts correct 7-line entry

**Dependencies:** Phase 2 (glossary file exists)

**Done when:** All 142 terms mapped to line ranges, validation confirms 100% accuracy (each range extracts correct term name on line 1), term index ready for embedding in skill document
<!-- END_PHASE_3 -->

<!-- START_PHASE_4 -->
### Phase 4: Skill Document Creation

**Goal:** Write complete SKILL.md with embedded term index and access instructions

**Components:**
- `plugins/nersc-support/skills/nersc-terminology/SKILL.md` with:
  - YAML frontmatter (name, description, user-invocable: false)
  - Overview and core principle
  - When to Use / When NOT to Use sections
  - Embedded term index (8 category tables in compact 3-column format)
  - Glossary access instructions (detection → extraction → application workflow)
  - Session efficiency guidelines (read once per term per session)
  - Error handling guidance (missing file, malformed entries, case variations)
  - Usage examples demonstrating typical scenarios

**Dependencies:** Phase 3 (term index built and validated)

**Done when:** SKILL.md exists with all sections complete, embedded term index contains all 142 terms, YAML frontmatter valid, document follows ed3d-plugins skill structure conventions
<!-- END_PHASE_4 -->

<!-- START_PHASE_5 -->
### Phase 5: Marketplace Registration

**Goal:** Register plugin in marketplace and document release

**Components:**
- `.claude-plugin/marketplace.json` — add nersc-support entry with version 1.0.0
- `CHANGELOG.md` — add release entry at top with New features section
- Version consistency verification across all three files

**Dependencies:** Phase 4 (plugin fully functional)

**Done when:** nersc-support entry exists in marketplace.json, changelog entry added with proper format, version numbers consistent across `plugin.json`, `marketplace.json`, and `CHANGELOG.md`
<!-- END_PHASE_5 -->

<!-- START_PHASE_6 -->
### Phase 6: Validation & Testing

**Goal:** Verify all 142 terms work correctly and skill activates properly

**Components:**
- Validation script that:
  - Reads term index from SKILL.md
  - For each term, extracts its line range from glossary
  - Verifies line 1 matches term name
  - Verifies 7-line structure (term, blank, meaning, blank, confusion, impact, research)
  - Reports any mismatches or malformed entries
- Manual test scenarios:
  - NERSC context prompt (verify skill activates)
  - Non-NERSC context (verify skill doesn't activate)
  - Multiple term mentions in same session (verify only first read)

**Dependencies:** Phase 5 (marketplace registration complete)

**Done when:** Validation script reports 100% success (all 142 terms extract correctly), manual testing confirms auto-activation works, skill provides correct NERSC-specific definitions in test scenarios
<!-- END_PHASE_6 -->

## Additional Considerations

**Error Handling:**

Glossary file missing: Skill instructs Claude to proceed without glossary lookup and note the issue. Degrades gracefully rather than failing hard.

Malformed line ranges: If Read tool extracts content that doesn't match expected 7-line format, Claude recognizes malformed entry and skips it. Prevention: Phase 6 validation ensures all 142 ranges are correct before deployment.

Case variations: Skill instructs case-insensitive matching for term detection (e.g., "SCRATCH" triggers same as "scratch"). Limitation: won't catch all variations like "archival" vs "archive" — acceptable trade-off for simplicity.

**Glossary Maintenance:**

Glossary updates (new terms, line number shifts) require manual skill update to rebuild term index. Future consideration: add version number matching between skill and glossary to detect mismatches.

**Performance:**

Average session uses 5-15 unique terms → 35-105 lines read total (~2-5KB context usage). Term detection overhead is minimal (simple string scanning against 142-term list). Session tracking via guideline prevents redundant reads of frequently-used terms (home, scratch, archive).
