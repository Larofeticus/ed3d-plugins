---
name: nersc-terminology
description: Use when working with NERSC systems (Perlmutter, Cori), HPSS storage, job scheduling, or providing guidance about NERSC infrastructure - prevents semantic confusion by providing on-demand access to NERSC-specific term definitions
user-invocable: false
---

# NERSC Terminology

## Overview

Prevent semantic confusion when assisting users with NERSC systems by accessing NERSC-specific definitions for domain terminology.

**Core principle:** Many computing terms have generic meanings that differ significantly from their NERSC-specific meanings. Claude's pre-training knowledge may interpret "scratch" as temporary/disposable data rather than the Lustre parallel filesystem `$SCRATCH`, or "archive" as a compressed file rather than HPSS tape storage. This skill provides on-demand access to 142 NERSC-specific term definitions to prevent incorrect guidance.

## When to Use

This skill auto-activates when conversation context matches NERSC-related work:

- Discussing Perlmutter, Cori, or other NERSC supercomputers
- Helping users with HPSS archival storage or data management
- Troubleshooting job scheduling, Slurm queues, or QoS policies
- Explaining NERSC filesystems (scratch, home, CFS, DNA)
- Addressing NERSC services (SPIN, Superfacility API, JupyterHub)
- Guiding users on NERSC commands, tools, or infrastructure

**Symptoms this skill addresses:**
- Confusion between generic computing terms and NERSC-specific meanings
- Incorrect storage guidance (recommending compressed files instead of HPSS archival)
- Misunderstanding filesystem characteristics (scratch persistence, quota policies)
- Wrong assumptions about NERSC system architecture or services

## When NOT to Use

This skill does NOT apply to:

- Generic HPC questions without NERSC-specific context
- Non-NERSC systems (even if using similar technology stacks)
- When term is used in clearly generic context (e.g., "scratch work" meaning temporary notes)

**If ambiguous context:** Activate conservatively - better to have definitions available than to provide incorrect NERSC guidance.

## Quick Reference

| Action | How |
|--------|-----|
| Detect indexed term | Check if term appears in Term Index below (case-insensitive) |
| Check session history | Before extracting, verify term hasn't been looked up this session |
| Extract glossary entry | `Read(file_path="${CLAUDE_PLUGIN_ROOT}/nersc-support/skills/nersc-terminology/semantic_confusion_glossary.md", offset=line_start, limit=7)` |
| Incorporate definition | Use NERSC-specific meaning (line 3), awareness of confusion pattern (line 5), before responding |
| Handle missing file | Note degraded mode to user, proceed without glossary lookup |
| Handle malformed entry | Skip extraction if structure incorrect, use generic knowledge with caveat |

## Glossary Access Workflow

**When you encounter a term from the index:**

1. **Detect:** Term appears in user message or your planned response
2. **Check history:** Have you already looked up this term this session?
   - **Yes:** Reuse the definition from earlier in conversation
   - **No:** Proceed to extraction
3. **Extract:** Use Read tool with line range from index:
   ```
   Read(file_path="${CLAUDE_PLUGIN_ROOT}/nersc-support/skills/nersc-terminology/semantic_confusion_glossary.md",
        offset=line_start, limit=7)
   ```
4. **Parse entry structure:**
   - Line 1: Term name (confirmation)
   - Line 3: NERSC-specific meaning
   - Line 5: Common AI confusion pattern
   - Line 6: Impact of misunderstanding
   - Line 7: Research keywords for deeper investigation
5. **Incorporate:** Use NERSC-specific meaning in your response, noting the confusion pattern to avoid it
6. **Remember:** Track that you've consulted this term to avoid redundant lookups

**Multiple terms in one message:** Extract each unique term once, then incorporate all definitions.

**Case variations:** Treat "SCRATCH", "scratch", and "Scratch" as the same term.

## Error Handling

**Missing glossary file:**
- Skill attempts extraction but glossary file not found
- **Action:** Note to user "NERSC terminology glossary unavailable, providing general guidance"
- **Degraded mode:** Proceed without domain-specific definitions, caveat responses

**Malformed line range:**
- Extraction returns content that doesn't match 7-line structure
- **Action:** Recognize malformed entry, skip it
- **Fallback:** Use generic knowledge with caveat "This guidance may not reflect NERSC-specific behavior"

**Term not in index:**
- NERSC-specific term mentioned but not in the 142-term index
- **Action:** Use generic knowledge, note limitation if appropriate
- **Note:** Index prioritizes highest-confusion terms, not exhaustive NERSC vocabulary

**Ambiguous term:**
- Term like "home" could be generic or NERSC-specific (`$HOME` filesystem)
- **Heuristic:** If conversation context is NERSC-related, consult index
- **When unsure:** Briefly mention both meanings: "In NERSC context, 'home' refers to $HOME filesystem..."

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


### Filesystems

| Term | Lines |
|------|-------|
| archive | 38-44 |
| CFS / Community-File-System | 46-52 |
| DNA / DnA | 54-60 |
| garchive | 62-68 |
| home / Home / $HOME | 70-76 |
| NGF | 78-84 |
| scratch / Scratch / $SCRATCH | 86-92 |
| tape | 94-100 |

### Services and Platforms

| Term | Lines |
|------|-------|
| Apprentice2 | 108-114 |
| Cassini | 116-122 |
| cori / Cori | 124-130 |
| E4S | 132-138 |
| Edison | 140-146 |
| Gateway | 148-154 |
| Globus | 156-162 |
| Harbor | 164-170 |
| IRIS / Iris / iris | 172-178 |
| Jupyter | 180-186 |
| nersc-dl-wandb | 188-194 |
| nersc_chatbot_deploy | 196-202 |
| nersc_tensorboard_helper | 204-210 |
| Perlmutter | 212-218 |
| portal | 220-226 |
| Rancher | 228-234 |
| Shifter / shifter | 236-242 |
| SPIN / Spin / spin | 244-250 |
| SpinUp / spinup | 252-258 |
| sshproxy | 260-266 |
| ThinLinc | 268-274 |

### Commands and Tools

| Term | Lines |
|------|-------|
| bind / binding | 282-288 |
| cce | 290-296 |
| CPE | 298-304 |
| cpe-cuda | 306-312 |
| cray-libsci / LibSci | 314-320 |
| cray-mpich | 322-328 |
| craype | 330-336 |
| craype-accel-host | 338-344 |
| craype-accel-nvidia80 | 346-352 |
| cudatoolkit | 354-360 |
| Forge | 362-368 |
| gdb4hpc | 370-376 |
| intro_libsci | 378-384 |
| intro_mpi | 386-392 |
| intro_pgas | 394-400 |
| link / linking | 402-408 |
| module / modules | 410-416 |
| nccl-plugin | 418-424 |
| PrgEnv | 426-432 |
| purge / purging | 434-440 |
| Reveal | 442-448 |
| stdpar | 450-456 |
| upcc | 458-464 |
| upcrun | 466-472 |

### Quality of Service

| Term | Lines |
|------|-------|
| debug | 480-486 |
| InvalidQOS | 488-494 |
| overrun | 496-502 |
| preempt | 504-510 |
| premium | 512-518 |
| realtime | 520-526 |
| regular / premium / shared / interactive | 528-534 |
| shared | 536-542 |
| xfer | 544-550 |

### Infrastructure

| Term | Lines |
|------|-------|
| Ampere | 558-564 |
| datatran | 566-572 |
| DTN | 574-580 |
| DVS | 582-588 |
| Frontier / Frontier-Cache | 590-596 |
| Haswell | 598-604 |
| HPSS | 606-612 |
| KNL | 614-620 |
| Milan | 622-628 |
| node / nodes | 630-636 |
| NUMA | 638-644 |
| NVLink | 646-652 |
| Shasta | 654-660 |
| Slingshot | 662-668 |
| XPMEM | 670-676 |

### System Concepts

| Term | Lines |
|------|-------|
| account | 684-690 |
| affinity | 692-698 |
| allocation / allocations | 700-706 |
| binding | 708-714 |
| CDT | 716-722 |
| cron | 724-730 |
| environment / environments | 732-738 |
| give / take | 740-746 |
| project / Project | 749-755 |
| quota / quotas | 757-763 |
| repo / repos | 765-771 |
| workflow | 773-779 |

### Specialized Tools

| Term | Lines |
|------|-------|
| APA | 787-793 |
| ATP | 795-801 |
| CCDB | 803-809 |
| DMTCP | 811-817 |
| Drishti | 819-825 |
| Fireworks / FireWorks / fireworks / FireWork | 827-833 |
| GTL | 835-841 |
| HYPPO | 843-849 |
| MAP | 851-857 |
| MDS | 859-865 |
| NPS | 867-873 |
| perf-report | 875-881 |
| perftools-lite | 883-889 |
| profile / profiling | 891-897 |
| STAT | 899-905 |
| trace / tracing | 907-913 |

### Acronyms and Abbreviations

| Term | Lines |
|------|-------|
| batch | 921-927 |
| bbcp | 929-935 |
| BLACS | 937-943 |
| BUPC | 945-951 |
| ERCAP | 953-959 |
| ERT | 961-967 |
| ESnet | 969-975 |
| FWP | 977-983 |
| GASNet | 985-991 |
| hsi | 993-999 |
| htar | 1001-1007 |
| IRB | 1009-1015 |
| IRI | 1017-1023 |
| IRT | 1025-1031 |
| ITAR | 1033-1039 |
| JAMO | 1041-1047 |
| kernel | 1049-1055 |
| LDRD | 1057-1063 |
| LMOD_CMD | 1065-1071 |
| MANA | 1073-1079 |
| NCL | 1082-1088 |
| NERSC_HOST | 1090-1096 |
| NUG | 1098-1104 |
| OSS | 1106-1112 |
| OST | 1114-1120 |
| OTP | 1122-1128 |
| PAMS | 1130-1136 |
| PGAS | 1138-1144 |
| podman-hpc / Podman-hpc | 1146-1152 |
| pSTL | 1154-1160 |
| Saul | 1162-1168 |
| scrontab | 1170-1176 |
| slurm-ray-cluster | 1178-1184 |
| spack-config | 1186-1192 |
| Superfacility | 1194-1200 |
| WAN | 1202-1208 |
| wrapper / wrappers | 1210-1216 |


## Usage Examples

**Example 1: User asks about scratch storage**

User: "I need to clean up my scratch space on Perlmutter"

**Before consulting skill:**
- Might interpret "scratch" as temporary data to delete
- Could suggest removing "scratch files" without understanding `$SCRATCH` filesystem

**After consulting term index:**
1. Detect "scratch" and "Perlmutter" (both in index)
2. Extract "scratch" entry (lines 86-92)
3. Learn: Scratch is Lustre parallel filesystem, not temporary data; auto-purged after 8 weeks; high-performance storage
4. Respond with accurate NERSC guidance: "`$SCRATCH` on Perlmutter is the Lustre parallel filesystem for high-performance I/O. Files are automatically purged after 8 weeks of inactivity. Check quota with `myquota` and consider moving long-term data to HPSS archive."

**Example 2: Multiple terms in question**

User: "How do I archive my Perlmutter results to HPSS?"

**Terms detected:** "archive", "Perlmutter", "HPSS"
1. Extract "archive" (lines 38-44): HPSS tape storage, not compressed file
2. Extract "Perlmutter" (lines 212-218): HPE Cray EX supercomputer
3. Extract "HPSS" (lines 606-612): High Performance Storage System
4. Combine definitions: "To archive your Perlmutter results to HPSS (tape-based long-term storage), use `hsi` or `htar` commands. HPSS provides archival storage distinct from scratch or project filesystems..."

## Session Efficiency

**Track consulted terms mentally:**
- First mention of "scratch": Extract and read full entry
- Second mention of "scratch": Recall definition from earlier extraction, no re-read
- Typical session: 5-15 unique terms = 35-105 lines read (~2-5KB context)

**Don't extract every term:**
- Focus on terms central to user's question
- Skip terms used in clearly generic context
- Prioritize highest-confusion terms (scratch, archive, home) over unambiguous terms

## Common Patterns

**Storage confusion (archive, scratch, home):**
- These are the most frequently confused terms
- Always consult index when discussed in NERSC context
- Key distinctions: scratch=performance, archive=long-term tape, home=quota/backup

**System names (Perlmutter, Cori, NERSC):**
- Extract to understand system architecture and capabilities
- Prevents treating system names as unrelated proper nouns

**Commands and tools (sqs, shifter, hsi):**
- NERSC-specific implementations may differ from generic versions
- Consult for correct usage patterns and options

**QoS terms (debug, regular, premium):**
- Specific meanings within NERSC Slurm configuration
- Extract to provide accurate queue and resource guidance

## Tips

- **Conservative activation:** If conversation mentions NERSC even tangentially, have term index ready
- **Batch extraction:** Multiple terms in one question? Extract all before answering
- **Research keywords (line 7):** Use for deeper investigation when user's question requires detail beyond glossary entry
- **Confusion awareness:** Line 5 tells you what to avoid - if glossary says "AI agents confuse X with Y", don't make that error
- **Context over keywords:** If user says "scratch that idea" in non-NERSC discussion, don't extract the "scratch" term entry
