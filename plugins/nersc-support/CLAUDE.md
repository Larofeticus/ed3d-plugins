# nersc-support

Last verified: 2026-03-17

## Purpose

Prevent semantic confusion when Claude assists users with NERSC systems by providing on-demand access to NERSC-specific term definitions.

**Problem:** Terms like "scratch," "archive," and "home" have generic computing meanings that differ significantly from their NERSC-specific meanings (Lustre filesystem, HPSS tape storage, $HOME filesystem). Without domain context, Claude may provide incorrect guidance based on general knowledge rather than NERSC operational reality.

**Solution:** The nersc-terminology skill embeds a term index (142 terms across 8 categories) and instructs Claude to extract precise 7-line glossary entries on-demand when encountering indexed terms during NERSC-related work.

## Contracts

### What nersc-support Exposes

**Skills:**
- `nersc-terminology` — Auto-activates on NERSC context (Perlmutter, Cori, HPSS keywords), provides term index and glossary access

**Data:**
- `skills/nersc-terminology/semantic_confusion_glossary.md` — 142 NERSC terms with NERSC-specific meanings, common AI confusion patterns, impact of misunderstanding, research keywords

### What nersc-support Guarantees

- Glossary file contains exactly 142 terms organized into 8 categories
- Each glossary entry is exactly 7 lines (term name, blank, meaning, blank, confusion, impact, research)
- Term index in SKILL.md maps all 142 terms to correct line ranges in glossary
- Skill auto-activates when conversation context mentions NERSC systems or services

### What nersc-support Expects

- Glossary file remains colocated with skill: `skills/nersc-terminology/semantic_confusion_glossary.md`
- Source glossary at `/global/homes/w/warndt/glossary_builder/semantic_confusion_glossary.md` is authoritative version
- If glossary is updated (new terms, line shifts), term index in SKILL.md must be regenerated

## Dependencies

**External:**
- Source glossary: `/global/homes/w/warndt/glossary_builder/semantic_confusion_glossary.md` (86KB, 142 terms)

**Internal:**
- Read tool for extracting glossary entries by line range
- Claude Code skill auto-activation system (description-based keyword matching)

## Key Decisions

**Why embed term index in skill document instead of runtime glossary parsing?**
- Minimizes context usage: only referenced terms are read (5-15 per session typical)
- Fast term lookup: no need to scan 86KB file to find term locations
- Session efficiency: guideline-based tracking avoids redundant reads

**Why 7-line fixed entry format?**
- Enables precise line range extraction: `offset=N, limit=7`
- Predictable structure: skill instructions can reference "line 3 = meaning, line 5 = confusion"
- Simple validation: term name on line 1, always 6 additional lines

**Why colocate glossary with skill?**
- Plugin self-contained: no external file dependencies beyond source copy
- Deployment simplicity: cp source to plugin structure, no path configuration
- Version binding: glossary version tied to plugin version

**Why case-insensitive term matching?**
- User input varies: "SCRATCH" vs "scratch" vs "Scratch"
- Simpler implementation: no need for exhaustive alias list
- Acceptable limitation: won't catch all variations (e.g., "archival" vs "archive")

## Invariants

- Glossary file size: 86KB (±1KB tolerance for minor formatting changes)
- Entry count: 142 terms across 8 categories
- Entry structure: term, blank, meaning, blank, confusion, impact, research (7 lines)
- Entry spacing: 8 lines between entries (7-line entry + 1 blank separator)
- Term index accuracy: 100% of terms map to correct glossary entries
- License: Creative Commons Attribution-ShareAlike 4.0 for all plugin content

## Key Files

- `.claude-plugin/plugin.json` — Plugin metadata
- `LICENSE` — CC-BY-SA-4.0 license text
- `README.md` — User-facing documentation
- `skills/nersc-terminology/SKILL.md` — Auto-activated skill with embedded term index
- `skills/nersc-terminology/semantic_confusion_glossary.md` — 142-term glossary (copied from source)
