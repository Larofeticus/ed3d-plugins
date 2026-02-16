---
name: howto-code-in-c
description: Use when writing or reviewing C/C++ code - comprehensive house style covering memory management (RAII, smart pointers), modern C++ features (C++17/20), error handling, type safety, testing, performance, and sharp edges (UB, pointer safety, iterator invalidation)
user-invocable: false
---

# C/C++ House Style

## Overview

Provide concise, safe, and maintainable C/C++ code. Emphasize clear naming, consistent formatting, explicit memory handling, and robust error handling. Follow modern C++ (C++17 or later) practices unless a project constraint dictates otherwise.

## Naming & Formatting

- **Files**: kebab-case, e.g., `my-module.cpp`, `my-module.h`.
- **Identifiers**:
  - Variables & functions: `snake_case` for C, `camelCase` for C++.
  - Types, structs, classes, enums: `PascalCase`.
  - Constants/macros: `UPPER_CASE` with optional prefix `k` for constants.
- **Braces**: K&R style: opening brace on same line, closing brace aligned.
- **Indentation**: 4 spaces, no tabs.
- **Line length**: 100 characters max.
- **Comments**: `//` for single line, `/* ... */` for block comments. Keep comments up-to-date.

## Memory Management

- Prefer RAII: use smart pointers (`std::unique_ptr`, `std::shared_ptr`) for dynamic allocation.
- Use `std::make_unique<T>()` or `std::make_shared<T>()` instead of `new`.
- Avoid raw `new`/`delete`; if required, pair them in same scope.
- For C, allocate with `malloc`/`free` only when interfacing with C APIs; otherwise, use C++ abstractions.
- Always check allocation results; smart pointers throw `std::bad_alloc` on failure.
- Use containers (`std::vector`, `std::array`) instead of raw arrays when possible.
- Release resources promptly: close file handles, network sockets, etc., using RAII wrappers.

## Error Handling

- Use exceptions for error propagation in C++ (`throw`), catch at appropriate layer.
- Define specific exception types deriving from `std::runtime_error`.
- For C code, return error codes (`int` or `enum`) and document meaning.
- Prefer `std::optional<T>` or `std::expected<T, E>` (C++23) for functions that may fail without throwing.
- Validate function arguments: check for null pointers, out-of-range values, and report errors early.
- Log errors with context (file, line, function) using a consistent logger.
- Do not swallow exceptions; rethrow or handle them explicitly.
