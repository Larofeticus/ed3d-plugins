# nersc-support

NERSC-specific terminology and support for accurate guidance on NERSC systems, storage, and scheduling.

## Problem

When assisting users with NERSC systems, Claude may misinterpret domain-specific terms based on their generic computing meanings:

- **"scratch"** — Generic: temporary/disposable data. NERSC: Lustre parallel filesystem for high-performance I/O (`$SCRATCH`)
- **"archive"** — Generic: compressed file (tar.gz). NERSC: HPSS tape-based long-term storage system
- **"home"** — Generic: user's residence directory. NERSC: specific filesystem with quotas and backup (`$HOME`)

This semantic confusion leads to incorrect guidance: suggesting users delete "scratch" data, treating "archive" as a file format, or assuming "home" is just any directory.

## Solution

The `nersc-terminology` skill prevents confusion by providing on-demand access to NERSC-specific definitions:

1. **Auto-activation:** Skill activates when conversation mentions NERSC systems (Perlmutter, Cori, HPSS, etc.)
2. **Term index:** Embedded lookup table maps 142 NERSC terms to precise glossary entries
3. **On-demand extraction:** When Claude encounters an indexed term, extracts its 7-line glossary entry
4. **Session efficiency:** Reads each term once per session, reuses knowledge for subsequent mentions

## Features

- **142 indexed terms** across 8 categories (Filesystems, Services, Commands, QoS, Infrastructure, Concepts, Tools, Acronyms)
- **Precise definitions:** Each glossary entry contains NERSC-specific meaning, common AI confusion pattern, impact of misunderstanding, and research keywords
- **Minimal context usage:** Typical session reads 5-15 terms (2-5KB), not the full 86KB glossary
- **Case-insensitive matching:** SCRATCH, scratch, Scratch all trigger the same entry
- **Graceful degradation:** Missing glossary file results in notification, not hard failure

## Structure

```
plugins/nersc-support/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata
├── skills/
│   └── nersc-terminology/
│       ├── SKILL.md             # Auto-activated skill with term index
│       └── semantic_confusion_glossary.md  # 142-term glossary
├── CLAUDE.md                    # Project context
├── LICENSE                      # CC-BY-SA-4.0 license
└── README.md                    # This file
```

## Example Usage

**User:** "My job failed on Perlmutter - should I check scratch?"

**Without nersc-support:** Claude might interpret "scratch" as temporary/disposable data and suggest checking for corrupted temp files.

**With nersc-support:** Skill activates on "Perlmutter" keyword, extracts "scratch" glossary entry, Claude correctly advises checking `$SCRATCH` Lustre filesystem for job output or disk quota issues.

## Impact

- Prevents semantic confusion on 142 high-risk terms
- Reduces incorrect guidance on NERSC storage, scheduling, and system usage
- Enables accurate responses about Perlmutter, Cori, HPSS, and NERSC services
- Minimal overhead: glossary lookups add 2-5KB context per typical session

## License

Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)

See LICENSE file for full text.
