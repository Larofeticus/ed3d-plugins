# Comprehensive C/C++ House Style Skill Design

## Summary

This design document specifies a comprehensive C/C++ house style skill that unifies guidance for both C (C11/C17) and modern C++ (C++17+) development. The skill will replace the existing 43-line basic C coding skill with a full-featured resource comparable in depth to the TypeScript house style skill (1,400-1,600 lines). The primary approach organizes content by concern (Memory Management, Error Handling, Type System, etc.) rather than by language, presenting C and C++ patterns side-by-side with explicit decision frameworks for when to use each. The skill emphasizes three pillars: safety through RAII and resource management, performance awareness without premature optimization, and type safety through modern language features. To manage complexity, HPC-specific patterns (OpenMP, MPI, CUDA) remain in a separate `hpc-cpp-guidelines` skill, allowing this skill to focus on general-purpose development. The implementation follows eight phases—from establishing core structure and foundational sections (Phases 1-2) through specialized topic sections (Phases 3-7)—and concludes with three supporting reference files providing deep dives into STL containers, memory patterns, and testing strategies (Phase 8).

## Definition of Done

**Single comprehensive general-purpose C/C++ skill** that:

- Replaces the current basic `howto-code-in-c` skill with comprehensive coverage matching the TypeScript skill's depth and format
- Provides extensive coverage of memory management, modern C++ features, STL containers, testing, performance, sharp edges, and common mistakes
- Offers unified C and C++ treatment with clear guidance on when to use C patterns (C11/C17) vs modern C++ (C++17+)
- Excludes HPC-specific content (OpenMP, MPI, CUDA, distributed computing) - those patterns remain in the separate `hpc-cpp-guidelines` skill
- Follows the established house style format: Quick Self-Check section, detailed topic sections with examples, Common Mistakes table, Red Flags list, and authoritative source references

## Acceptance Criteria

### cpp-house-style.AC1: Skill provides comprehensive coverage matching TypeScript skill's depth

- **cpp-house-style.AC1.1 Success:** Main SKILL.md is 1,400-1,600 lines (comparable to TypeScript skill's 1,596 lines)
- **cpp-house-style.AC1.2 Success:** Skill includes 11+ core topic sections with multiple subsections each
- **cpp-house-style.AC1.3 Success:** Sharp Edges section contains 11+ subsections covering major undefined behavior and runtime hazards
- **cpp-house-style.AC1.4 Success:** Common Mistakes table contains 18+ entries with rationalization pattern (Mistake | Fix)
- **cpp-house-style.AC1.5 Success:** Three supporting reference files exist (cpp-standard-library.md, memory-patterns.md, testing-cpp.md), each 300-500 lines
- **cpp-house-style.AC1.6 Failure:** Skill is significantly shorter than 1,200 lines (indicates insufficient depth)
- **cpp-house-style.AC1.7 Failure:** Missing Quick Self-Check section (required for comprehensive skills)
- **cpp-house-style.AC1.8 Failure:** Sharp Edges section has fewer than 8 subsections (insufficient coverage of hazards)

### cpp-house-style.AC2: Memory management, modern C++, STL, testing, performance, and sharp edges extensively covered

- **cpp-house-style.AC2.1 Success:** Memory Management section covers RAII, smart pointers (unique_ptr, shared_ptr, weak_ptr), malloc/free, and resource patterns
- **cpp-house-style.AC2.2 Success:** Type System section covers C++17/20 features (auto, structured bindings, templates, concepts)
- **cpp-house-style.AC2.3 Success:** Standard Library section includes container decision framework and algorithm coverage with links to cpp-standard-library.md
- **cpp-house-style.AC2.4 Success:** Testing section covers GoogleTest, sanitizers (ASan, MSan, TSan, UBSan), and CI integration with links to testing-cpp.md
- **cpp-house-style.AC2.5 Success:** Performance section includes profiling guidance, cache efficiency, move semantics, and "when to optimize" framework
- **cpp-house-style.AC2.6 Success:** Sharp Edges covers undefined behavior, pointer arithmetic, iterator invalidation, move semantics gotchas, static initialization order, type punning, integer overflow, floating-point precision, lifetime/dangling references, concurrency hazards
- **cpp-house-style.AC2.7 Failure:** Memory Management section missing smart pointer coverage (critical omission)
- **cpp-house-style.AC2.8 Failure:** No guidance on when to use C++17 vs C++20 features
- **cpp-house-style.AC2.9 Failure:** Testing section doesn't mention sanitizers (essential for C/C++ quality)

### cpp-house-style.AC3: Unified C and C++ treatment with clear decision guidance

- **cpp-house-style.AC3.1 Success:** Each section presents both C and C++ approaches side-by-side (e.g., malloc/free vs smart pointers)
- **cpp-house-style.AC3.2 Success:** Decision frameworks exist for when to use C patterns vs C++ patterns
- **cpp-house-style.AC3.3 Success:** Error Handling section shows both error codes (C) and exceptions (C++) with when-to-use guidance
- **cpp-house-style.AC3.4 Success:** Memory Management section explains when C allocation is appropriate (C interop, placement control)
- **cpp-house-style.AC3.5 Success:** Functions section covers both C function conventions and C++ overloading/templates
- **cpp-house-style.AC3.6 Failure:** Sections present only C++ guidance without mentioning C patterns
- **cpp-house-style.AC3.7 Failure:** No decision frameworks for choosing between C and C++ approaches
- **cpp-house-style.AC3.8 Failure:** Skill treats C and C++ as separate languages rather than unified guidance

### cpp-house-style.AC4: HPC-specific content excluded

- **cpp-house-style.AC4.1 Success:** No mention of OpenMP, MPI, CUDA, or distributed computing patterns in main SKILL.md
- **cpp-house-style.AC4.2 Success:** No mention of OpenMP, MPI, CUDA in any supporting files (cpp-standard-library.md, memory-patterns.md, testing-cpp.md)
- **cpp-house-style.AC4.3 Success:** Concurrency section in Sharp Edges covers only std::atomic, data races, and general UB (not HPC-specific patterns)
- **cpp-house-style.AC4.4 Success:** No cross-reference to hpc-cpp-guidelines skill (per user decision to keep them completely separate)
- **cpp-house-style.AC4.5 Failure:** OpenMP, MPI, or CUDA mentioned anywhere in skill or supporting files
- **cpp-house-style.AC4.6 Failure:** HPC-specific libraries or patterns included (those belong in hpc-cpp-guidelines)

### cpp-house-style.AC5: Follows established house style format

- **cpp-house-style.AC5.1 Success:** YAML frontmatter includes name, description, user-invocable flag
- **cpp-house-style.AC5.2 Success:** Description follows "Use when [triggers] - [what it does]" format in third person
- **cpp-house-style.AC5.3 Success:** Quick Self-Check section exists with pressure-situation checklist (8-10 items)
- **cpp-house-style.AC5.4 Success:** Common Mistakes table follows TypeScript pattern (Mistake | Fix columns)
- **cpp-house-style.AC5.5 Success:** Red Flags list uses authority language ("NEVER", "ALWAYS", "YOU MUST")
- **cpp-house-style.AC5.6 Success:** Reference section includes links to C++ Core Guidelines, Google C++ Style Guide, cppreference.com, and supporting files
- **cpp-house-style.AC5.7 Success:** File uses valid UTF-8 encoding with ASCII arrows (->), quotes ("), apostrophes (')
- **cpp-house-style.AC5.8 Success:** Supporting files linked from main skill with relative paths (./cpp-standard-library.md pattern)
- **cpp-house-style.AC5.9 Failure:** YAML frontmatter malformed or missing required fields
- **cpp-house-style.AC5.10 Failure:** Description doesn't follow "Use when..." format
- **cpp-house-style.AC5.11 Failure:** File contains Unicode characters that break parsing (smart quotes, em dashes, Unicode arrows)
- **cpp-house-style.AC5.12 Failure:** Red Flags list uses weak language instead of authority language

### cpp-house-style.AC6: Cross-Cutting Quality Requirements

- **cpp-house-style.AC6.1 Success:** All code examples use correct C/C++ syntax with proper formatting
- **cpp-house-style.AC6.2 Success:** Examples show both "good" and "bad" patterns with clear labels
- **cpp-house-style.AC6.3 Success:** Each topic section includes 2-5 code examples demonstrating key patterns
- **cpp-house-style.AC6.4 Success:** Decision frameworks presented as tables or structured lists
- **cpp-house-style.AC6.5 Success:** Supporting files properly linked from relevant main skill sections
- **cpp-house-style.AC6.6 Failure:** Code examples contain syntax errors or compilation issues
- **cpp-house-style.AC6.7 Failure:** Examples lack "good" vs "bad" comparisons where relevant
- **cpp-house-style.AC6.8 Failure:** Broken links to supporting files

## Glossary

- **RAII (Resource Acquisition Is Initialization)**: A C++ programming pattern where resource management (memory, file handles, locks) is tied to object lifetime—resources are acquired in a constructor and automatically released in a destructor, ensuring exception-safe cleanup.

- **Smart Pointers**: C++ standard library classes (unique_ptr, shared_ptr, weak_ptr) that manage dynamic memory allocation and deallocation automatically, eliminating manual new/delete calls and preventing memory leaks.

- **undefined behavior (UB)**: Program behavior that the C/C++ standard does not define, often resulting from errors like buffer overflows, use-after-free, or uninitialized variables. UB can cause crashes, silent data corruption, or unexpected results.

- **const correctness**: A programming discipline where const is used consistently to mark data and functions that don't modify state, enabling compiler verification of intended immutability and improving code clarity.

- **STL (Standard Template Library)**: The C++ standard library's collection of generic containers (vector, map, list), algorithms (sort, find), and utilities that provide efficient, well-tested implementations for common programming tasks.

- **Exception safety**: A guarantee about what happens if an exception is thrown—strong exception safety means the operation either completes fully or has no effect, with all resources properly cleaned up.

- **move semantics**: A C++11+ feature allowing efficient transfer of ownership of resources (like dynamically allocated memory) from one object to another without expensive copying, using rvalue references.

- **Type system**: The set of rules governing which values and operations are valid for different data types, with stronger type systems (like C++'s templates and concepts) catching more errors at compile time.

- **static initialization order (fiasco)**: A C/C++ problem where global or static objects are initialized in an unpredictable order across translation units, potentially causing a global object to use another uninitialized global object.

- **Sanitizers**: Runtime analysis tools (AddressSanitizer, ThreadSanitizer, UndefinedBehaviorSanitizer) that instrument code to detect memory errors, data races, and undefined behavior during testing.

- **GoogleTest**: A popular C/C++ unit testing framework providing assertion macros, test fixtures, parameterized tests, and death test capabilities for verifying code correctness.

- **Valgrind**: A dynamic analysis tool that instruments programs to detect memory errors (leaks, invalid accesses), undefined behavior, and profiling information.

- **clang-tidy**: A static analysis tool that identifies code quality issues, performance problems, and style violations in C/C++ code, automatically suggesting fixes.

- **CMake**: A cross-platform build system that uses configuration files (CMakeLists.txt) to generate platform-specific build tools and manage compilation of C/C++ projects.

- **C++ Core Guidelines**: An authoritative set of guidelines and best practices for modern C++ programming maintained by the C++ standards committee, covering design principles, resource management, and common pitfalls.

- **iterator invalidation**: A hazard in C++ containers where operations (insertion, deletion, reallocation) can make existing iterators or references point to invalid memory, causing undefined behavior if dereferenced.

- **placement new**: A C++ feature allowing creation of objects at a pre-allocated memory location, useful for custom memory management and arena allocators but requiring manual destruction.

- **Rule of Five**: A C++ principle stating that if a class defines a custom destructor, copy constructor, copy assignment, move constructor, or move assignment, it should define all five to maintain consistency and prevent subtle bugs.

## Architecture

The comprehensive C/C++ skill follows a **unified by concern** organizational structure, mirroring the TypeScript skill's proven pattern while addressing C/C++-specific concerns. Each topic section (Memory Management, Error Handling, Type System, etc.) presents both C and C++ guidance side-by-side, showing when to use `malloc` vs smart pointers, error codes vs exceptions, and C types vs modern C++ features.

**Key components:**

**Frontmatter and Overview** - YAML metadata with skill name and description. Core principles emphasizing safety through RAII, explicit resource management, performance awareness, and type safety.

**Quick Self-Check** - Pressure-situation checklist (similar to TypeScript skill) covering critical violations: raw `new`/`delete` instead of smart pointers, missing RAII wrappers, mixing `malloc`/`free` with C++ objects, unchecked pointer dereferences, missing `const` correctness, memory leaks, undefined behavior patterns, and missing error handling.

**Core Topic Sections** (unified C and C++ guidance):
1. Naming & Formatting - File naming, identifier casing, brace styles, indentation
2. Memory Management - `malloc`/`free` vs RAII/smart pointers, resource ownership
3. Error Handling - Error codes vs exceptions, `std::optional`, `std::expected`
4. Type System - C types, C++ templates, constexpr, concepts (C++20)
5. Functions & Signatures - Parameter passing, return values, overloading
6. Classes & Structures - When to use each, encapsulation, inheritance patterns
7. Ownership & Lifetimes - Move semantics, transfer of ownership, dangling references
8. Const Correctness - const variables, const member functions, const pointers
9. Standard Library & Containers - STL containers, algorithms, when to use each
10. Performance Patterns - When to optimize, profiling, cache efficiency, move semantics
11. Testing Strategies - GoogleTest, mocking, sanitizers, CI integration

**Sharp Edges** - Runtime hazards and undefined behavior (11+ subsections): buffer overflows, dangling pointers, undefined behavior, static initialization order, move semantics gotchas, iterator invalidation, pointer arithmetic, integer overflow, floating-point precision, type punning, concurrency hazards.

**Common Mistakes** - Rationalization table with 18+ entries showing excuse vs fix.

**Red Flags** - STOP and refactor list with strong authority language.

**Tools & Libraries** - Compilers (GCC, Clang, MSVC), build systems (CMake), static analysis (clang-tidy, cppcheck), dynamic analysis (Valgrind, sanitizers), testing frameworks (GoogleTest), standard libraries (STL, Boost).

**Reference** - Links to supporting files and authoritative sources (C++ Core Guidelines, Google C++ Style Guide, cppreference.com).

**Supporting files** (comprehensive reference material):
- `cpp-standard-library.md` - STL containers, algorithms, utilities reference (~300-500 lines)
- `memory-patterns.md` - RAII patterns, smart pointer decision trees, custom deleters (~300-500 lines)
- `testing-cpp.md` - GoogleTest/GoogleMock patterns, sanitizer usage, CI integration (~300-500 lines)

Each supporting file provides deep reference material linked directly from relevant main skill sections, following the TypeScript skill's pattern (type-fest.md, typebox.md).

**Estimated total length:** Main SKILL.md approximately 1,400-1,600 lines, matching TypeScript skill's comprehensiveness.

## Existing Patterns

Investigation of the ed3d-plugins house style skills repository revealed clear structural patterns:

**Pattern: Comprehensive skills follow consistent structure**
- TypeScript skill (1,596 lines): Overview, Quick Self-Check, 11+ core topic sections, Sharp Edges (11 subsections), Common Mistakes table (18 items), Red Flags list, supporting reference files
- React skill (140 lines): Overview, workflow sections, Common Rationalizations table, Quick Reference table, supporting files
- Current basic C skill (43 lines): Brief sections on Naming, Memory, Error Handling

**This design follows the TypeScript comprehensive skill pattern:**
- Extensive Quick Self-Check section for pressure scenarios
- Deep topic sections with multiple subsections each
- Comprehensive Sharp Edges section addressing runtime hazards
- Large Common Mistakes rationalization table
- Red Flags list with authority language
- Multiple supporting reference files

**Pattern: Supporting files for deep reference**
- TypeScript has type-fest.md (comprehensive type utilities), typebox.md (validation library)
- React has react-testing.md, useEffect-deep-dive.md
- This design creates cpp-standard-library.md, memory-patterns.md, testing-cpp.md

**Pattern: Cross-skill references**
- React skill explicitly requires TypeScript skill as sub-skill
- Coding-effectively lists conditional sub-skills based on context
- This design will reference howto-functional-vs-imperative and defense-in-depth where relevant, but NO reference to hpc-cpp-guidelines per user decision

**Pattern: YAML frontmatter requirements**
- All skills have name, description
- Comprehensive foundation skills marked `user-invocable: false`
- Descriptions follow "Use when [triggers] - [what it does]" format
- This design follows same frontmatter structure

**Pattern: Content encoding constraints**
- Valid UTF-8 only, ASCII arrows/quotes/apostrophes
- No fancy Unicode characters
- Verified with `file -i SKILL.md`

**No divergence from existing patterns** - this design integrates smoothly into the established house style skills architecture.

## Implementation Phases

<!-- START_PHASE_1 -->
### Phase 1: Core Skill Structure

**Goal:** Establish main SKILL.md file with frontmatter, overview, and Quick Self-Check section

**Components:**
- `plugins/ed3d-house-style/skills/howto-code-in-c/SKILL.md` - Replace existing 43-line basic skill with new structure
- YAML frontmatter with name, description, user-invocable flag
- Overview section with core principles (safety, performance, maintainability)
- Quick Self-Check section (pressure-situation checklist covering 8-10 critical violations)

**Dependencies:** None (first phase)

**Done when:** SKILL.md exists with valid YAML frontmatter, Overview explaining core principles, Quick Self-Check checklist complete and verified for completeness against TypeScript skill pattern
<!-- END_PHASE_1 -->

<!-- START_PHASE_2 -->
### Phase 2: Foundational Sections

**Goal:** Core language fundamentals covering naming, memory, and error handling

**Components:**
- Naming & Formatting section (~80-100 lines) - File naming conventions, identifier casing rules (snake_case for C, camelCase for C++, PascalCase for types), brace styles, indentation
- Memory Management section (~200-250 lines) - RAII principles, smart pointers (unique_ptr, shared_ptr, weak_ptr), C allocation (malloc/free), resource management patterns, common memory mistakes
- Error Handling section (~150-200 lines) - C++ exceptions, C error codes, std::optional/std::expected, decision framework, validation patterns, defense in depth integration

**Dependencies:** Phase 1 (core structure exists)

**Done when:** All three sections complete with extensive code examples showing both C and C++ approaches, clear decision frameworks for when to use each pattern
<!-- END_PHASE_2 -->

<!-- START_PHASE_3 -->
### Phase 3: Type System and Functions

**Goal:** Type system coverage and function design patterns

**Components:**
- Type System section (~180-220 lines) - Fundamental types (integers, floats, characters, booleans), type safety (enum class, using aliases), modern C++ features (auto, structured bindings, templates, concepts), type qualifiers (const, volatile, mutable, static), containers and aggregates (std::array vs C arrays, structs vs classes), type system sharp edges
- Functions & Signatures section (~160-200 lines) - Declaration styles, parameter passing conventions (by value, const reference, reference, pointer), return value patterns, function overloading, special member functions (Rule of Five), const/constexpr functions, inline and linkage

**Dependencies:** Phase 2 (foundational sections provide context)

**Done when:** Both sections complete with unified C/C++ guidance, parameter passing performance table, extensive examples of modern C++ features
<!-- END_PHASE_3 -->

<!-- START_PHASE_4 -->
### Phase 4: Object-Oriented Sections

**Goal:** Classes, structures, const correctness, and ownership patterns

**Components:**
- Classes & Structures section (~90-110 lines) - Struct vs class decision framework, class design principles, inheritance patterns, special member functions, modern alternatives to inheritance
- Const Correctness section (~90-110 lines) - const promise, const member functions, const references and parameters, const and pointers (reading declarations right-to-left), const_cast usage
- Ownership & Lifetimes section (~80-100 lines) - Ownership semantics, move semantics, transfer of ownership, dangling references, lifetime management

**Dependencies:** Phase 3 (type system and functions establish foundation)

**Done when:** All three sections complete with clear decision frameworks, extensive examples of class design patterns, const correctness throughout
<!-- END_PHASE_4 -->

<!-- START_PHASE_5 -->
### Phase 5: Library and Performance Sections

**Goal:** Standard library usage and performance optimization guidance

**Components:**
- Standard Library & Containers section (~120-150 lines) - Container selection framework (vector, array, deque, list, map, set, unordered variants), string handling (std::string, std::string_view), algorithms and iterators, smart pointers and optional types, links to cpp-standard-library.md
- Performance Patterns section (~80-100 lines) - When to optimize (profile first), memory layout and cache efficiency, move semantics and copy elision, compile-time computation, common performance mistakes

**Dependencies:** Phase 4 (object-oriented concepts needed for container usage)

**Done when:** Both sections complete with container decision tree, performance optimization guidance without premature optimization, links to supporting file established
<!-- END_PHASE_5 -->

<!-- START_PHASE_6 -->
### Phase 6: Testing and Tooling Sections

**Goal:** Testing strategies and development tooling

**Components:**
- Testing Strategies section (~120-150 lines) - Framework selection (GoogleTest, Catch2), unit testing patterns, testing memory management (Valgrind, sanitizers), testing error handling, mocking and dependency injection, links to testing-cpp.md
- Tools & Libraries section (~60-80 lines) - Compilers (GCC, Clang, MSVC), build systems (CMake, Make, Ninja), static analysis (clang-tidy, cppcheck, clang-format), dynamic analysis (Valgrind, ASan, MSan, TSan, UBSan), standard libraries (STL, Boost), testing frameworks

**Dependencies:** Phase 5 (library knowledge needed for testing context)

**Done when:** Both sections complete with practical testing guidance, comprehensive tooling list, sanitizer integration examples
<!-- END_PHASE_6 -->

<!-- START_PHASE_7 -->
### Phase 7: Risk and Reference Sections

**Goal:** Sharp edges, common mistakes, red flags, and authoritative references

**Components:**
- Sharp Edges section (~250-300 lines) - 11+ subsections covering: undefined behavior, pointer arithmetic dangers, iterator invalidation, move semantics gotchas, static initialization order fiasco, type punning and aliasing, integer promotions and conversions, floating-point precision, lifetime and dangling references, concurrency hazards (note: detailed HPC concurrency in separate hpc-cpp-guidelines)
- Common Mistakes table (~18+ entries) - Rationalization table with Mistake | Fix columns
- Red Flags list (~16+ items) - STOP and refactor signals with authority language
- Reference section - Links to C++ Core Guidelines, Google C++ Style Guide, cppreference.com, and supporting files

**Dependencies:** Phase 6 (complete skill content to identify all sharp edges and mistakes)

**Done when:** Sharp Edges section covers all major UB and runtime hazards, Common Mistakes table comprehensive, Red Flags list complete, Reference section with all authoritative sources
<!-- END_PHASE_7 -->

<!-- START_PHASE_8 -->
### Phase 8: Supporting Reference Files

**Goal:** Comprehensive reference files for deep dives

**Components:**
- `plugins/ed3d-house-style/skills/howto-code-in-c/cpp-standard-library.md` (~300-500 lines) - Containers (vector, map, unordered_map, array, etc.), algorithms (sort, find, transform, accumulate), utilities (optional, variant, any, tuple), smart pointers, string handling, organized by category with when-to-use guidance
- `plugins/ed3d-house-style/skills/howto-code-in-c/memory-patterns.md` (~300-500 lines) - RAII pattern examples, smart pointer decision tree, custom deleters, circular reference prevention, placement new and arena allocation, memory alignment, stack vs heap decision framework
- `plugins/ed3d-house-style/skills/howto-code-in-c/testing-cpp.md` (~300-500 lines) - GoogleTest setup, GoogleMock patterns, testing RAII and exception safety, death tests, parameterized tests, CI integration, property-based testing with RapidCheck, numerical accuracy testing

**Dependencies:** Phase 7 (main skill complete and links to supporting files established)

**Done when:** All three supporting files complete, properly linked from main SKILL.md, following TypeScript skill's supporting file pattern
<!-- END_PHASE_8 -->

## Additional Considerations

**UTF-8 encoding validation:** Before committing, verify with `file -i SKILL.md` to ensure valid UTF-8. Common culprits: smart quotes, em dashes, Unicode arrows. Use ASCII alternatives: `->` not `→`, `"` not `"`, `'` not `'`.

**Cross-skill integration:** While this skill should not reference hpc-cpp-guidelines (per user decision), it should include conditional references to:
- `ed3d-house-style:howto-functional-vs-imperative` in relevant sections (C++ enables FCIS pattern well)
- `ed3d-house-style:defense-in-depth` in error handling and validation sections

**Skill description optimization:** Keep under 500 characters if possible. Example: "Use when writing or reviewing C/C++ code - comprehensive house style covering memory management (RAII, smart pointers), modern C++ features (C++17/20), error handling, type safety, testing, performance, and sharp edges (UB, pointer safety, iterator invalidation)"

**Relationship to existing skills:** This replaces the current basic `howto-code-in-c` skill entirely. The existing hpc-cpp-guidelines skill remains separate and unchanged, covering OpenMP, MPI, CUDA, and distributed computing patterns not included here.
