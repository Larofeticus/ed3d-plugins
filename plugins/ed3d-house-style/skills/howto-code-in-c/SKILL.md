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

## Quick Self-Check (Use Under Pressure)

When under deadline pressure or focused on other concerns (performance, debugging, features), STOP and verify:

- [ ] Using smart pointers (unique_ptr, shared_ptr) not raw new/delete
- [ ] RAII wrappers for resources (files, locks, memory) not manual cleanup
- [ ] Not mixing malloc/free with C++ objects (use new/delete or smart pointers for C++ types)
- [ ] Checking pointer validity before dereferencing (nullptr checks)
- [ ] Using const correctness (const member functions, const references)
- [ ] No memory leaks (every allocation has corresponding deallocation or RAII wrapper)
- [ ] Avoiding undefined behavior (no buffer overflows, use-after-free, uninitialized variables)
- [ ] Error handling present (exceptions with RAII, or error codes with explicit checks)
- [ ] No raw arrays where vector/array would work (prefer STL containers)
- [ ] Move semantics used for expensive-to-copy types (std::move, rvalue references)

**Why this matters:** Under pressure, you'll default to muscle memory from other languages (manual memory management, no const, raw pointers). These checks catch the most common C/C++ violations.

## Naming and formatting

### File naming

**C files:**
- Headers: `module_name.h` (snake_case)
- Implementation: `module_name.c` (snake_case)
- Example: `http_parser.h`, `http_parser.c`

**C++ files:**
- Headers: `ModuleName.hpp` or `ModuleName.h` (PascalCase)
- Implementation: `ModuleName.cpp` (PascalCase)
- Example: `HttpParser.hpp`, `HttpParser.cpp`

**Mixed C/C++ projects:**
- Stick to one convention per project
- Use `.h` for C-compatible headers, `.hpp` for C++-only headers

### Identifier casing

| Element | C Convention | C++ Convention | Example (C++) |
|---------|-------------|----------------|------------|
| Variables | `snake_case` | `camelCase` or `snake_case` | `userId` or `user_id` |
| Functions | `snake_case` | `camelCase` or `snake_case` | `parseInput()` or `parse_input()` |
| Types/Classes | `PascalCase` or `snake_case_t` | `PascalCase` | `HttpRequest` or `http_request_t` |
| Constants | `SCREAMING_SNAKE_CASE` | `kPascalCase` or `SCREAMING_SNAKE_CASE` | `kMaxBufferSize` or `MAX_BUFFER_SIZE` |
| Macros | `SCREAMING_SNAKE_CASE` | Avoid macros; use `constexpr` | `MAX_PATH_LEN` |
| Enums | `SCREAMING_SNAKE_CASE` | `enum class` with `PascalCase` | `ErrorCode::InvalidInput` |
| Namespaces | n/a | `snake_case` | `namespace http_utils` |

**Decision framework:**
- Pure C project: Use C conventions throughout
- Pure C++ project: Choose one C++ convention and stick to it
- Mixed project: C conventions for C files, C++ conventions for C++ files
- When in doubt: Match the existing codebase style

### Code formatting

**Brace style** (Allman or K&R - pick one per project):

```cpp
// Allman style (preferred for readability)
void function()
{
    if (condition)
    {
        // code
    }
}

// K&R style (compact)
void function() {
    if (condition) {
        // code
    }
}
```

**Indentation:**
- Use 4 spaces (not tabs) for consistent display
- Indent each nested block level

**Line length:**
- Target: 80-100 characters
- Hard limit: 120 characters
- Break long function calls across lines:
  ```cpp
  auto result = some_long_function(
      first_arg,
      second_arg,
      third_arg
  );
  ```

**Whitespace:**
- Space after keywords: `if (condition)` not `if(condition)`
- Space around binary operators: `a + b` not `a+b`
- No space before function call parens: `func()` not `func ()`

## Memory management

C++ uses **RAII (Resource Acquisition Is Initialization)** to tie resource lifetime to object lifetime. Prefer smart pointers over manual new/delete. C uses manual malloc/free with explicit error checking.

### RAII principles

**Core concept:** Resources (memory, file handles, locks) acquired in constructors are automatically released in destructors via stack unwinding.

```cpp
// GOOD: RAII - automatic cleanup
void process_file(const char* filename) {
    std::ifstream file(filename);  // Resource acquired
    if (!file) throw std::runtime_error("failed to open");
    // Use file...
}  // Destructor automatically closes file

// BAD: Manual cleanup - error-prone
void process_file(const char* filename) {
    FILE* file = fopen(filename, "r");
    if (!file) return;  // No cleanup needed yet
    // Use file...
    if (error) return;  // LEAK! Forgot to close
    fclose(file);
}
```

**Why RAII matters:** Exceptions, early returns, and complex control flow can skip manual cleanup. RAII guarantees cleanup happens.

### Smart pointers (C++)

Smart pointers manage memory automatically using RAII. Always prefer smart pointers over raw new/delete.

#### unique_ptr - single owner

**When to use:** Default choice for dynamic allocation. One owner, transfer via move.

```cpp
// GOOD: Automatic cleanup
std::unique_ptr<Widget> widget = std::make_unique<Widget>();
// Use widget...
// Automatically deleted when widget goes out of scope

// GOOD: Transfer ownership
std::unique_ptr<Widget> create_widget() {
    return std::make_unique<Widget>();  // Transfers ownership to caller
}

// GOOD: Polymorphism with unique_ptr
std::unique_ptr<Base> ptr = std::make_unique<Derived>();
// Requires virtual destructor in Base

// BAD: Manual new/delete
Widget* widget = new Widget();
// Use widget...
delete widget;  // Easy to forget, exception-unsafe
```

**Always use make_unique:**
```cpp
// GOOD: Exception-safe
auto ptr = std::make_unique<Widget>();

// BAD: Not exception-safe
std::unique_ptr<Widget> ptr(new Widget());
// If Widget() throws, memory leaked
```

#### shared_ptr - shared ownership

**When to use:** Multiple owners need to keep object alive. Use sparingly - prefer unique_ptr when possible.

```cpp
// GOOD: Multiple owners
std::shared_ptr<Resource> resource = std::make_shared<Resource>();
std::shared_ptr<Resource> copy = resource;  // Both share ownership
// Resource deleted when last shared_ptr destroyed

// GOOD: make_shared for efficiency
auto ptr = std::make_shared<Resource>();  // Single allocation

// BAD: Constructor with new
std::shared_ptr<Resource> ptr(new Resource());  // Two allocations
```

**Reference counting:**
```cpp
std::shared_ptr<int> p1 = std::make_shared<int>(42);
std::shared_ptr<int> p2 = p1;  // p1.use_count() == 2
p2.reset();  // p1.use_count() == 1
// Object deleted when use_count reaches 0
```

#### weak_ptr - non-owning reference

**When to use:** Break circular references between shared_ptr. Observer pattern where you don't want to extend lifetime.

```cpp
// GOOD: Breaking circular references
struct Node {
    std::shared_ptr<Node> next;    // Child pointer
    std::weak_ptr<Node> prev;      // Parent pointer (break cycle)
};

// Usage: Must lock before use
std::weak_ptr<int> weak = shared_ptr;
if (auto sptr = weak.lock()) {
    // Object still exists, use sptr
} else {
    // Object was deleted
}
```

**Without weak_ptr - memory leak:**
```cpp
// BAD: Circular reference
struct Node {
    std::shared_ptr<Node> next;
    std::shared_ptr<Node> prev;  // Both keep each other alive!
};
auto parent = std::make_shared<Node>();
auto child = std::make_shared<Node>();
parent->next = child;
child->prev = parent;  // Memory leak - neither can be deleted
```

### Smart pointer decision framework

| Scenario | Use | Rationale |
|----------|-----|-----------|
| Single owner, exclusive access | `unique_ptr` | Default choice, move-only semantics |
| Multiple owners sharing object | `shared_ptr` | Reference counting manages lifetime |
| Non-owning reference that might outlive object | `weak_ptr` | Prevents use-after-delete, breaks cycles |
| Array of objects | `std::vector<T>` or `unique_ptr<T[]>` | Vector preferred for most cases |
| Polymorphic base class | `unique_ptr<Base>` or `shared_ptr<Base>` | Requires virtual destructor |

### C allocation (malloc/free)

**When C allocation is appropriate:**
- C interop: Calling C libraries that return malloc'd memory
- Explicit control: Placement new for arena allocators
- Performance-critical: Measured benefit of manual management (rare)

**Never mix malloc/free with C++ objects:**
```cpp
// BAD: malloc doesn't call constructors
MyClass* obj = (MyClass*)malloc(sizeof(MyClass));  // No constructor!
obj->method();  // Undefined behavior

// BAD: Mixing new/free or malloc/delete
MyClass* obj = new MyClass();
free(obj);  // Undefined behavior

// GOOD: Wrap C allocation in RAII
std::unique_ptr<void, decltype(&free)> c_mem(malloc(size), &free);
```

**C allocation patterns:**
```c
// C: Manual error checking required
int* array = (int*)malloc(count * sizeof(int));
if (!array) {
    return ERROR_OUT_OF_MEMORY;
}
// Use array...
free(array);
```

### Memory management decision framework

| Question | Use | Example |
|----------|-----|---------|
| C++ dynamic object? | `unique_ptr` | `auto p = std::make_unique<Widget>();` |
| Multiple owners? | `shared_ptr` | `auto p = std::make_shared<Resource>();` |
| Circular reference risk? | Add `weak_ptr` | Parent has `shared_ptr`, child has `weak_ptr` |
| C library returns malloc'd memory? | Wrap in `unique_ptr` with custom deleter | `unique_ptr<T, decltype(&free)> p(c_lib(), &free);` |
| C codebase, no C++ features? | `malloc`/`free` | `int* p = malloc(n * sizeof(int)); free(p);` |
