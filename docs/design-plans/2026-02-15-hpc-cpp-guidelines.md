# HPC C/C++ House Style Design

## Summary
This design introduces a new house‑style skill `hpc-cpp-guidelines` that provides best‑practice guidelines for scientific C/C++ development, covering general coding conventions, Boost usage, OpenMP parallelism, CUDA/cuBLAS programming, MPI conventions, testing strategies, and performance profiling.

## Definition of Done
- A new skill directory `plugins/ed3d-house-style/skills/hpc-cpp-guidelines/` containing a single `SKILL.md` file with the full guidelines.
- The `ed3d-house-style` plugin version bumped from `1.0.2` to `1.1.0` in its `.claude-plugin/plugin.json`.
- The marketplace entry for `ed3d-house-style` updated to version `1.1.0` in the root `CHANGELOG.md` and `marketplace.json`.
- A changelog entry added at the top of `CHANGELOG.md` documenting the new skill.
- All changes committed to the repository.

## Acceptance Criteria
- **AC1**: `SKILL.md` exists at `plugins/ed3d-house-style/skills/hpc-cpp-guidelines/SKILL.md` and contains sections for General C/C++ style, OpenMP, CUDA, MPI, testing, and profiling.
- **AC2**: `plugins/ed3d-house-style/.claude-plugin/plugin.json` version field is `"1.1.0"`.
- **AC3**: `CHANGELOG.md` contains a top‑most entry for version `1.1.0` describing the new skill.
- **AC4**: `marketplace.json` entry for `ed3d-house-style` version is `"1.1.0"`.
- **AC5**: All files are added and committed in a single git commit.

## Glossary
- **HPC** – High‑Performance Computing.
- **OpenMP** – API for shared‑memory parallelism.
- **CUDA** – NVIDIA's GPU programming platform.
- **cuBLAS** – CUDA library for dense linear algebra.
- **MPI** – Message Passing Interface for distributed‑memory parallelism.
