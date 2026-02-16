---
name: hpc-cpp-guidelines
description: Best‑practice house style for scientific C/C++ and HPC applications (Boost, OpenMP, CUDA/cublas, MPI). Covers coding conventions, parallelism guidelines, testing, and performance profiling.
user-invocable: false
---

# HPC C/C++ House Style

## Overview
Guidelines for writing clean, performant, and maintainable C/C++ code for scientific and high‑performance computing (HPC) projects. The focus is on:
- Consistent coding style (naming, formatting, file layout)
- Safe and idiomatic use of the Boost libraries
- Correct OpenMP parallelism patterns
- CUDA programming practices, including the cuBLAS library
- MPI usage conventions for distributed computation
- Testing strategies and performance profiling for HPC code

## Coding Conventions
- **Naming**: `snake_case` for variables, `PascalCase` for types/classes, `SCREAMING_SNAKE_CASE` for macros/constants.
- **File layout**: One header (`.hpp`) and implementation (`.cpp`) per logical component. Keep platform‑specific code in `*_unix.cpp` and `*_windows.cpp` when needed.
- **Headers**: Include guards (`#pragma once` or traditional `#ifndef`). Order includes as: standard library, Boost, third‑party, project headers.
- **Modern C++**: Prefer C++17/20 features (structured bindings, `[[nodiscard]]`, `std::optional`). Use `auto` only when the type is obvious.

## Boost Library Guidelines
- Prefer Boost **header‑only** libraries where possible (e.g., `Boost::Optional`). When linking, use the same build configuration (debug/release) as the rest of the project.
- Use `Boost::filesystem` for portable path handling; avoid raw `char*` paths.
- Prefer `boost::variant`/`boost::optional` over raw unions or nullable pointers.

## OpenMP Parallelism
- Always protect shared data with appropriate `omp critical` or reduction clauses.
- Use `#pragma omp parallel for` with a **schedule(static)** unless load imbalance is evident.
- Avoid nested parallel regions unless you explicitly set `nested` to `true`.
- Respect the `OMP_NUM_THREADS` environment variable; provide a fallback default of `std::thread::hardware_concurrency()`.

## CUDA / cuBLAS Guidelines
- Write kernel signatures using **`__global__`** and **`__device__`** qualifiers; keep host‑device separation clear.
- Manage GPU memory with RAII wrappers (e.g., custom `CudaPtr<T>` that calls `cudaFree` in its destructor).
- For linear algebra, prefer **cuBLAS** calls over hand‑rolled kernels unless a custom algorithm is required.
- Check every CUDA API call for errors; wrap calls in a macro like:
  ```cpp
  #define CUDA_CHECK(expr) do { cudaError_t err = (expr); if (err != cudaSuccess) { throw std::runtime_error(cudaGetErrorString(err)); } } while(0)
  ```
- Keep kernel launch parameters (`gridDim`, `blockDim`) configurable via function arguments.

## MPI Conventions
- Use **MPI_Init_thread** with `MPI_THREAD_FUNNELED` or higher when mixing MPI with OpenMP.
- Encapsulate MPI communicators in a RAII class that calls `MPI_Comm_free` on destruction.
- Prefer collective operations (`MPI_Bcast`, `MPI_Reduce`) over point‑to‑point when possible for scalability.
- Include rank‑aware logging (e.g., `log(rank) << "message"`).

## Testing for HPC Code
- **Unit tests**: Use GoogleTest for pure C++ logic. Mock CUDA kernels with host‑only stubs when possible.
- **Integration tests**: Run on a GPU‑enabled CI runner; verify numerical accuracy within tolerance (`abs_error < 1e‑6`).
- **MPI tests**: Launch using `mpirun -n <N>` inside the test harness; assert consistency across ranks.
- **Performance tests**: Benchmark critical paths with `std::chrono` on CPU and `cudaEventRecord` for GPU timing. Record baseline results in CI artifacts.

## Performance Profiling
- Use **`perf`** (Linux) or **VTune** for CPU hotspots.
- For GPU, use **NVIDIA Nsight Systems** and **Nsight Compute** to identify kernel launch overhead and memory bandwidth issues.
- Profile MPI communication with **mpiP** or **HPCToolkit**.
- Regularly benchmark with realistic problem sizes; track regression in CI.

## Glossary
- **OpenMP** – API for multi‑threaded parallelism on shared‑memory systems.
- **CUDA** – NVIDIA’s parallel computing platform and programming model.
- **cuBLAS** – CUDA library for dense linear algebra.
- **MPI** – Message Passing Interface for distributed‑memory parallelism.
- **Boost** – Collection of peer‑reviewed portable C++ source libraries.

---

*This skill is intended for internal use; it is not user‑invocable via a slash command.*
