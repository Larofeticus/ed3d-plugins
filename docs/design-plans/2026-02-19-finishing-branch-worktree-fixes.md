# Finishing Branch Worktree Fixes Design

## Summary

Fixes three bugs in the `finishing-a-development-branch` skill that surface when using the full `ed3d-plan-and-execute` workflow with git worktrees. The most critical bug breaks the shell entirely: after `git worktree remove` deletes the worktree directory, any subsequent command fails because the OS `getcwd()` syscall can no longer resolve the process's working directory. The fix is to navigate to the main repo root (derived via `git worktree list`) before removing the worktree. A second bug causes `git worktree remove` to fail silently with exit 128 when the worktree contains untracked planning artifacts; the fix detects this, lists the files, and asks the user to confirm `--force` before retrying. A third prose-only fix corrects an existing inconsistency where Step 6 and Step 4 implied worktree cleanup for Option 2 (Create PR), contradicting the Quick Reference table and Red Flags which correctly preserve the worktree after PR creation.

All three changes are targeted edits to a single markdown skill file — no new files, no new dependencies.

## Definition of Done

The `finishing-a-development-branch` SKILL.md is updated to:

1. Navigate to the main repo root (via `git worktree list`) before calling `git worktree remove` — preventing shell getcwd breakage when the session's CWD is inside the worktree being removed.
2. Handle exit 128 from `git worktree remove` by listing the untracked files, explaining they are likely planning artifacts, and asking the user to confirm `--force` before retrying — rather than silently failing.
3. Consistently document that worktree cleanup applies to Options 1 and 4 only (not Option 2), aligning Step 6 header and Step 4 prose with the Quick Reference table and Red Flags.

The updated skill is committed to the repository.

## Acceptance Criteria

### finishing-branch-worktree-fixes.AC1: Navigate to main repo root before worktree removal
- **finishing-branch-worktree-fixes.AC1.1 Success:** Step 6 includes a command using `git worktree list | head -1` to derive the main repo root path
- **finishing-branch-worktree-fixes.AC1.2 Success:** Step 6 includes a `cd` to that derived path
- **finishing-branch-worktree-fixes.AC1.3 Success:** The `cd` command appears before the `git worktree remove` call in Step 6

### finishing-branch-worktree-fixes.AC2: Handle exit 128 from worktree removal
- **finishing-branch-worktree-fixes.AC2.1 Success:** Step 6 instructs Claude to detect failure from `git worktree remove` (exit 128 / untracked files)
- **finishing-branch-worktree-fixes.AC2.2 Success:** Step 6 provides `git -C <path> ls-files --others --exclude-standard` to list the untracked files
- **finishing-branch-worktree-fixes.AC2.3 Success:** Step 6 explains the untracked files are likely planning artifacts from `writing-implementation-plans`
- **finishing-branch-worktree-fixes.AC2.4 Success:** Step 6 instructs Claude to confirm with the user before retrying with `--force`

### finishing-branch-worktree-fixes.AC3: Consistent Option 2 worktree behavior
- **finishing-branch-worktree-fixes.AC3.1 Success:** Step 6 header reads "For Options 1 and 4:" (not "1, 2, 4")
- **finishing-branch-worktree-fixes.AC3.2 Success:** Step 6 footer reads "For Options 2 and 3: Keep worktree"
- **finishing-branch-worktree-fixes.AC3.3 Success:** Step 4's Option 2 then-clause does not reference worktree cleanup or Step 6

## Glossary

- **git worktree:** A git feature that creates additional working directories linked to the same repository, enabling work on multiple branches simultaneously without switching.
- **getcwd():** POSIX system call that returns the process's current working directory. Fails if the directory no longer exists on disk.
- **exit 128:** The exit code returned by `git worktree remove` when the worktree contains modified or untracked files and `--force` was not specified.
- **planning artifacts:** Files created by `writing-implementation-plans` in `docs/implementation-plans/` during the planning phase. These are not committed to git and remain as untracked files in the worktree after implementation completes.
- **`ed3d-plan-and-execute` workflow:** The full pipeline of skills (design → implementation plan → execution → finishing) used to implement features in isolated git worktrees.
- **SKILL.md:** The markdown file containing process instructions for a Claude Code skill. Claude reads and follows these instructions when the skill is invoked.

## Architecture

Two bugs surface together when using the full `ed3d-plan-and-execute` workflow with git worktrees:

1. `executing-an-implementation-plan` runs from inside the worktree. When it completes, it activates `finishing-a-development-branch` — still inside the worktree.
2. The user picks Option 1 (merge locally) or Option 4 (discard). Step 6 attempts `git worktree remove`.
3. **Bug A (getcwd):** The OS process's CWD is the worktree directory. After `git worktree remove` deletes that directory, `getcwd()` fails for all subsequent shell commands — the session is unrecoverable.
4. **Bug B (exit 128):** The worktree contains untracked planning artifacts (`docs/implementation-plans/`) left by `writing-implementation-plans`. Git refuses to remove the worktree without `--force`, but the skill has no handling for this failure.

The fix is two sequential steps added to Step 6's cleanup block:

1. Derive the main repo root with `git worktree list | head -1 | awk '{print $1}'` (the first entry in `git worktree list` is always the main worktree, regardless of where the command runs).
2. `cd` to that path before calling `git worktree remove` — so the process CWD is safe after removal.
3. On exit 128, list untracked files and confirm `--force` with the user before retrying.

A third prose-only fix corrects an existing inconsistency: Step 6's header and Step 4's Option 2 text both imply worktree cleanup for Option 2, contradicting the Quick Reference table and Red Flags section which correctly say cleanup applies to Options 1 and 4 only.

## Existing Patterns

The skill file uses a consistent pattern throughout: prose instruction followed by fenced bash code blocks showing the commands to run. The exit-128 handling follows this same pattern — prose explains the condition, code block shows the diagnostic command, prose explains the cause, code block shows the retry command.

No new patterns are introduced. The `git worktree list | head -1` idiom for finding the main repo root is a standard git technique.

## Implementation Phases

<!-- START_PHASE_1 -->
### Phase 1: Apply four targeted edits to the skill file

**Goal:** Update `finishing-a-development-branch/SKILL.md` with all three fixes.

**Components:**
- `plugins/ed3d-plan-and-execute/skills/finishing-a-development-branch/SKILL.md` — four edits:
  1. Step 6 header: `For Options 1, 2, 4:` → `For Options 1 and 4:`
  2. Step 6 cleanup block: replace 2-line `git worktree remove` command with the full `cd`-first + remove + exit-128-handling block
  3. Step 6 footer: `**For Option 3:** Keep worktree` → `**For Options 2 and 3:** Keep worktree`
  4. Step 4, Option 2 then-clause: remove `, then cleanup worktree (Step 6)`

**Dependencies:** None

**Done when:** The file contains all four edits and the commit succeeds
<!-- END_PHASE_1 -->

## Additional Considerations

**Edit ordering within Phase 1:** The `cd` to main repo root must appear before `git worktree remove` in the prose. The exit-128 handling block must follow the initial remove attempt. Order within the code block matters — implement in the sequence shown in the design.

**Exit code specificity:** `git worktree remove` returns exit 128 specifically when the worktree has modified or untracked files. This is distinct from other failure modes (e.g., no such worktree). The skill does not need to handle other exit codes — they are not expected in normal workflow.
