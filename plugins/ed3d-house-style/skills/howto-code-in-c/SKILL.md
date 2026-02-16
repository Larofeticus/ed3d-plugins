---
name: howto-code-in-c
description: Use when writing or reviewing C/C++ code - comprehensive house style covering memory management (RAII, smart pointers), modern C++ features (C++17/20), error handling, type safety, testing, performance, and sharp edges (UB, pointer safety, iterator invalidation)
user-invocable: false
---

# C/C++ House Style

## Overview

This comprehensive guide covers both C (C11/C17) and modern C++ (C++17+) development with a unified approach. Rather than treating them as separate languages, sections present C and C++ patterns side-by-side with clear decision frameworks for when to use each.

**Core principles:**

1. **Safety through RAII and resource management** - Tie resource lifetime to object lifetime. Prefer smart pointers over manual new/delete. Use const correctness to catch errors at compile time.

2. **Performance awareness without premature optimization** - Understand memory layout and cache efficiency, but profile before optimizing. Move semantics and copy elision matter, but readability comes first.

3. **Type safety through modern language features** - Use auto for complex types, structured bindings for clarity, templates for generic code. Leverage constexpr and concepts (C++20) to catch errors at compile time.

**When to use C vs C++:**
- Use C patterns (malloc/free, error codes) for: FFI/interop with C libraries, embedded systems with size constraints, explicit memory placement control
- Use C++ patterns (RAII, exceptions, templates) for: Application code, complex data structures, generic programming, automatic resource management

**Excluded from this skill:** HPC-specific patterns (OpenMP, MPI, CUDA, distributed computing) belong in the separate `hpc-cpp-guidelines` skill.
