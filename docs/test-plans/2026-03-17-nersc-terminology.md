# Human Test Plan: nersc-support Plugin

**Feature:** NERSC Terminology Disambiguation
**Version:** 1.0.0
**Date:** 2026-03-18
**Automated Coverage:** 13/27 criteria (48%)
**Manual Coverage:** 14/27 criteria (52%)

## Prerequisites

- nersc-support plugin installed in a Claude Code session (either via marketplace or local plugin path)
- validation-utils plugin installed (required for YAML frontmatter validation)
- All automated validation scripts pass:
  ```bash
  bash plugins/nersc-support/scripts/validate-term-index --json
  bash plugins/nersc-support/scripts/extract-glossary-terms plugins/nersc-support/skills/nersc-terminology/semantic_confusion_glossary.md --json
  ```

## Phase 1: Skill Activation (AC1.1, AC1.2, AC1.4, AC1.5)

| Step | Action | Expected |
|------|--------|----------|
| 1.1 | Start a fresh Claude Code session with nersc-support installed. Enter: "I need help with my Perlmutter job that's stuck in the queue." | nersc-terminology skill appears in active skills. Response references NERSC-specific job scheduling concepts. |
| 1.2 | In a fresh session, enter: "My Cori batch scripts need to be migrated." | nersc-terminology skill activates. Response acknowledges Cori as a NERSC system. |
| 1.3 | In a fresh session, enter: "I need to retrieve data from HPSS." | nersc-terminology skill activates. Response discusses HPSS as NERSC tape storage (not generic acronym). |
| 1.4 | In a fresh session, enter: "How do I check my NERSC storage quota?" | nersc-terminology skill activates on broader context keyword "NERSC storage." Response references NERSC filesystem quotas. |
| 1.5 | In a fresh session, enter: "My NERSC batch job failed with exit code 137." | nersc-terminology skill activates on "NERSC batch job." Response provides NERSC-specific debugging guidance. |
| 1.6 | In a fresh session (non-NERSC context), enter: "I need help optimizing my HPC job submission script." | nersc-terminology skill does NOT activate. Response is generic HPC guidance without NERSC-specific terms. |
| 1.7 | In a fresh session, enter: "I'm having trouble with my scratch filesystem performance." | Observe whether skill activates. Per design, conservative activation is preferred -- activation is acceptable here. Document observed behavior either way. |

## Phase 2: Term Extraction and Session Tracking (AC3.1, AC3.2, AC3.3, AC3.6)

| Step | Action | Expected |
|------|--------|----------|
| 2.1 | In a session with nersc-terminology active, enter: "What should I know about using scratch on Perlmutter?" | Observe Claude's tool use: should see a Read call to `semantic_confusion_glossary.md` with offset matching the scratch entry's line range (lines 86-92, so offset=85 with 0-indexed). |
| 2.2 | In the same session, send a second message also referencing scratch: "Can I store important results on scratch long-term?" | Observe that Claude does NOT issue another Read call for "scratch." Response should still use the NERSC-specific definition (Lustre filesystem with auto-purge) from the first extraction. |
| 2.3 | In a fresh NERSC-context session, enter: "How do I archive my Perlmutter results from scratch to HPSS?" | Observe that Claude issues Read calls for multiple distinct terms: "archive" (lines 38-44), "Perlmutter" (lines 212-218), "scratch" (lines 86-92), and "HPSS" (lines 606-612). All four definitions should be incorporated into the response. |
| 2.4 | In a session where "scratch" was already extracted, enter a message using "SCRATCH" (all caps): "Is SCRATCH backed up?" | Claude should recognize SCRATCH as the same term as "scratch" (case-insensitive matching) and reuse the earlier extraction rather than issuing a new Read call. |

## Phase 3: Semantic Correctness (AC4.5, AC5.1, AC5.2, AC5.3, AC5.5)

| Step | Action | Expected |
|------|--------|----------|
| 3.1 | In a NERSC-context session, ask: "What should I know about scratch on Perlmutter?" | Response describes `$SCRATCH` as the Lustre parallel filesystem with auto-purge policy after 8 weeks of inactivity and high-performance I/O characteristics. Response does NOT describe scratch as "temporary files" or "scratch work." |
| 3.2 | Ask: "How do I archive data at NERSC?" | Response discusses HPSS tape-based long-term storage and mentions `hsi` and/or `htar` commands for data transfer to HPSS. Response does NOT recommend tar/gzip compression as the "archive" method. |
| 3.3 | Ask: "Is my home directory backed up on Perlmutter?" | Response discusses `$HOME` filesystem characteristics specific to NERSC: quota limits, snapshot/backup policies. Response does NOT provide generic Linux home directory guidance. |
| 3.4 | Ask: "Can I share data with my team using CFS?" | Response discusses NERSC Community File System -- shared project storage accessible across NERSC systems. Response does NOT discuss Container File System, Common File System, or other CFS expansions. |
| 3.5 | After steps 3.1-3.4, review all responses holistically. | Guidance across storage, scheduling, and system usage topics is consistently NERSC-specific and accurate. No response falls back to generic computing definitions when NERSC-specific meanings exist. |

## Phase 4: Error Handling (AC3.4, AC3.5)

| Step | Action | Expected |
|------|--------|----------|
| 4.1 | (Optional destructive test) Temporarily corrupt one line range in SKILL.md -- for example, change "38-44" to "38-45" for the "archive" term. Start a session and mention "archive" in NERSC context. | Claude recognizes the extracted content does not match the expected 7-line structure. Claude either falls back gracefully with a caveat or still provides useful guidance. Claude does NOT produce nonsensical output from the malformed extraction. Restore SKILL.md after test. |
| 4.2 | (Optional destructive test) Temporarily rename `semantic_confusion_glossary.md` to a different name. Start a session mentioning a NERSC term like "scratch." | Claude reports that the glossary is unavailable and proceeds with general guidance rather than failing silently. Response includes a note about degraded mode. Restore the file after test. |

## End-to-End: Full NERSC Consultation Scenario

**Purpose:** Validates the complete workflow from skill activation through multi-term extraction to accurate NERSC-specific guidance across a multi-turn conversation.

**Steps:**

1. Start a fresh Claude Code session with nersc-support installed.
2. Enter: "I'm a new NERSC user. I just got my allocation on Perlmutter. Where should I store my simulation input data, intermediate results, and final outputs for long-term preservation?"
3. Verify nersc-terminology skill activates.
4. Verify Claude extracts glossary entries for relevant terms (at minimum: "Perlmutter," "scratch," "home," "archive," and possibly "CFS" or "HPSS").
5. Verify the response provides a coherent NERSC storage strategy:
   - Input data: `$HOME` or CFS for small/shared files
   - Intermediate results: `$SCRATCH` for high-performance I/O during computation
   - Long-term preservation: HPSS archive via `hsi`/`htar`
6. Follow up with: "What happens if I forget to move results off scratch?"
7. Verify Claude reuses previously extracted "scratch" definition (no re-read) and correctly describes the auto-purge policy.
8. Follow up with: "How do I set up a cron job to automatically archive results?"
9. Verify Claude extracts "cron" (lines 724-730) on first mention, providing NERSC-specific cron guidance (scrontab on Perlmutter, not generic crontab).

## Traceability

### Automated Tests (13 criteria)

| Criterion | Test Command | Pass Condition |
|-----------|--------------|----------------|
| AC1.3 | `grep "^### " SKILL.md \| wc -l` | Returns 8 (category count) |
| AC2.1 | `validate-term-index --json \| jq '.found_terms'` | Returns 142 |
| AC2.2 | `validate-term-index --json \| jq '.validated_terms'` | Returns 142, failed_terms = 0 |
| AC2.3 | `grep "^### " SKILL.md` | 8 headings match required categories |
| AC2.4 | Test with deliberate error | Returns exit 1, identifies malformed term |
| AC2.5 | `wc -l SKILL.md` | 361 lines (under 500 threshold) |
| AC4.1 | `validate-term-index` | Checks line 3 non-empty (142/142) |
| AC4.2 | `validate-term-index` | Checks line 5 non-empty (142/142) |
| AC4.3 | `validate-term-index` | Checks line 6 non-empty (142/142) |
| AC4.4 | `validate-term-index` | Checks line 7 non-empty (142/142) |
| AC6.1 | `validate-term-index --json \| jq '.valid'` | Returns true |
| AC6.2 | Version consistency + JSON/YAML validation | All pass |
| AC6.3 | `extract-glossary-terms --json` | Returns valid: true, 142 terms, 8 categories |

### Manual Tests (14 criteria)

| Criterion | Manual Step | Why Manual |
|-----------|-------------|-----------|
| AC1.1 | Phase 1, Steps 1.1-1.3 | Runtime skill activation observation |
| AC1.2 | Phase 1, Steps 1.4-1.5 | Semantic keyword matching |
| AC1.4 | Phase 1, Step 1.6 | Negative test (non-activation) |
| AC1.5 | Phase 1, Step 1.7 | Ambiguous context judgment |
| AC3.1 | Phase 2, Step 2.1 | Read tool invocation observation |
| AC3.2 | Phase 2, Step 2.2 | Session tracking observation |
| AC3.3 | Phase 2, Step 2.3 | Batch extraction pattern |
| AC3.4 | Phase 4, Step 4.1 | Error handling behavior |
| AC3.5 | Phase 4, Step 4.2 | Degraded mode behavior |
| AC3.6 | Phase 2, Step 2.4 | Case-insensitive matching |
| AC4.5 | Phase 3, Steps 3.1-3.4 | Response quality judgment |
| AC5.1 | Phase 3, Step 3.1 | Semantic correctness (scratch) |
| AC5.2 | Phase 3, Step 3.2 | Semantic correctness (archive) |
| AC5.3 | Phase 3, Step 3.3 | Semantic correctness (home) |
| AC5.5 | Phase 3, Step 3.4 | Semantic correctness (CFS) |

## Notes

- Phase 4 tests (4.1, 4.2) are marked optional because they require temporarily corrupting the plugin to test error paths
- End-to-End scenario provides holistic validation of AC5.4 (accurate NERSC guidance)
- All automated tests pass prior to this manual testing phase (100% validation: 142/142 terms)
