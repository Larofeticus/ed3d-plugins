# Human Test Plan: Finishing Branch Worktree Fixes

**Implementation plan:** `docs/implementation-plans/2026-02-19-finishing-branch-worktree-fixes/`
**File under test:** `plugins/ed3d-plan-and-execute/skills/finishing-a-development-branch/SKILL.md`
**Date:** 2026-02-19

---

## Automated Test Results

All automated string-presence checks passed:

| AC | Check | Result |
|----|-------|--------|
| AC1.1 | `git worktree list \| head -1` present | PASS (count: 1) |
| AC1.2 | `cd "$REPO_ROOT"` present | PASS (count: 1) |
| AC1.3 | `cd` line (184) < first `git worktree remove` line (190) | PASS |
| AC2.1 | exit code 128 mentioned | PASS (count: 1) |
| AC2.2 | `ls-files --others --exclude-standard` present | PASS (count: 1) |
| AC2.3 | "planning artifacts" and `writing-implementation-plans` present | PASS |
| AC2.4 | User confirmation required before `--force` | PASS (count: 1) |
| AC3.1 | Step 6 header: "For Options 1 and 4:" | PASS (count: 1, old string: 0) |
| AC3.2 | Step 6 footer: "For Options 2 and 3: Keep worktree" | PASS (count: 1) |
| AC3.3 | Option 2 then-clause has no Step 6 reference | PASS |

---

## Human Verification Required

### Test 1: Prose Coherence — Step 6 Worktree Cleanup

**Purpose:** Verify the expanded Step 6 prose is unambiguous and a Claude agent would follow it correctly.

**Steps:**
1. Open `plugins/ed3d-plan-and-execute/skills/finishing-a-development-branch/SKILL.md`
2. Navigate to **Step 6: Cleanup Worktree** (currently around line 169)
3. Mentally simulate the **Options 1 and 4** path:
   - Confirm the section opens with `**For Options 1 and 4:**`
   - Confirm a `git worktree list` check appears to detect if you're in a worktree
   - Confirm the "If yes:" block begins with navigating to the main repo root:
     - `REPO_ROOT=$(git worktree list | head -1 | awk '{print $1}')`
     - `cd "$REPO_ROOT"`
   - Confirm `cd "$REPO_ROOT"` appears **before** `git worktree remove <worktree-path>`
   - Confirm the exit-128 block then explains:
     - How to list untracked files with `git -C <worktree-path> ls-files --others --exclude-standard`
     - That these files are likely planning artifacts from `writing-implementation-plans`
     - That the user must confirm before running `git worktree remove --force <worktree-path>`
4. Mentally simulate the **Options 2 and 3** path:
   - Confirm the section ends with `**For Options 2 and 3:** Keep worktree.`
   - Confirm no ambiguity — Options 2 and 3 are explicitly told to keep the worktree

**Pass criteria:**
- The prose flows logically (cd → remove → if-fail: list → explain → confirm → force)
- The `--force` step is clearly gated behind user confirmation
- Options 2 and 3 routing is unambiguous

---

### Test 2: Option 2 Step 4 Text Review

**Purpose:** Verify the Option 2 then-clause reads cleanly after removing the worktree cleanup reference.

**Steps:**
1. Open `plugins/ed3d-plan-and-execute/skills/finishing-a-development-branch/SKILL.md`
2. Navigate to **Step 4** and find **Option 2: Push and Create PR**
3. Read the full Option 2 section including the `gh pr create` command block
4. Find the then-clause after the code block (currently around line 107)
5. Confirm it reads: `Then: Update project context (Step 5)`
6. Confirm **no other text in the Option 2 block** references worktree cleanup or Step 6
7. Confirm the surrounding Option 1 (merge) and Option 3 (keep as-is) sections were not accidentally modified

**Pass criteria:**
- Option 2 then-clause ends cleanly at `Then: Update project context (Step 5)`
- No surrounding text was accidentally changed

---

### Test 3: Option 4 Discard Path Still Works

**Purpose:** Verify that Option 4 (Discard) still correctly routes to worktree cleanup.

**Steps:**
1. Navigate to **Step 4, Option 4: Discard**
2. Confirm it still says `Then: Cleanup worktree (Step 6)` after the discard confirmation block
3. Navigate to Step 6 and confirm the `**For Options 1 and 4:**` header confirms Option 4 is included

**Pass criteria:**
- Option 4 still references Step 6 for worktree cleanup
- Step 6 header includes Option 4

---

## Notes

- All tests operate on the static SKILL.md file — no runtime execution required
- The primary risk area is prose coherence in the exit-128 handling block (Test 1), which automated checks cannot verify
