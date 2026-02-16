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

## Error handling

Modern C++ prefers exceptions for truly exceptional conditions, with std::optional and std::expected for expected failures. C uses error codes with explicit checking.

### C++ exceptions

**When to use exceptions:**
- Truly unexpected/exceptional situations
- Error handling separated from detection by multiple calls
- Constructor failures (no return value)
- RAII ensures exception safety

```cpp
// GOOD: Exception with RAII
void process_data(const std::string& filename) {
    std::ifstream file(filename);
    if (!file) {
        throw std::runtime_error("failed to open: " + filename);
    }
    // RAII ensures file closed even if exception thrown below
    parse_contents(file);
}

// Catch specific exceptions
try {
    process_data("config.json");
} catch (const std::runtime_error& e) {
    std::cerr << "Error: " << e.what() << std::endl;
} catch (const std::exception& e) {
    std::cerr << "Unexpected: " << e.what() << std::endl;
}
```

**Exception safety guarantees:**
- **Strong guarantee:** Operation succeeds completely or has no effect
- **Basic guarantee:** Program remains in valid state (no leaks)
- **No-throw guarantee:** Operation cannot fail (destructors, swap)

**RAII enables exception safety:**
```cpp
// GOOD: Strong exception safety with RAII
void transfer(Account& from, Account& to, double amount) {
    std::lock_guard<std::mutex> lock1(from.mutex);
    std::lock_guard<std::mutex> lock2(to.mutex);

    if (from.balance < amount) {
        throw InsufficientFunds();  // Locks automatically released
    }

    from.balance -= amount;
    to.balance += amount;
    // If exception thrown, locks still released via destructors
}
```

### C error codes

**When to use C error codes:**
- C codebase with no C++ features
- Performance-critical code (measure first!)
- Integration with C libraries

```c
// C pattern: Error codes with explicit checking
typedef enum {
    SUCCESS = 0,
    ERROR_INVALID_INPUT = -1,
    ERROR_OUT_OF_MEMORY = -2,
    ERROR_NOT_FOUND = -3
} error_code_t;

error_code_t parse_config(const char* filename, config_t* out) {
    if (!filename || !out) {
        return ERROR_INVALID_INPUT;
    }

    FILE* file = fopen(filename, "r");
    if (!file) {
        return ERROR_NOT_FOUND;
    }

    // Parse file...
    fclose(file);
    return SUCCESS;
}

// Usage: Must check every call
config_t config;
error_code_t err = parse_config("config.txt", &config);
if (err != SUCCESS) {
    fprintf(stderr, "Failed to parse config: %d\n", err);
    return err;
}
```

### std::optional (C++17)

**When to use:** Expected, non-exceptional failures where function may or may not return a value. Alternative to returning `nullptr` or error codes for simple true/false outcomes.

```cpp
// GOOD: optional for expected missing values
std::optional<int> parse_int(const std::string& str) {
    try {
        return std::stoi(str);
    } catch (...) {
        return std::nullopt;  // Expected failure
    }
}

// Usage patterns
if (auto result = parse_int(input)) {
    std::cout << "Parsed: " << *result << std::endl;
} else {
    std::cout << "Not a valid integer" << std::endl;
}

// Provide default value
int value = parse_int(input).value_or(42);

// C++23 monadic operations
auto doubled = parse_int(input).transform([](int x) { return x * 2; });
```

**vs nullptr:**
```cpp
// BAD: Nullable pointer requires nullptr checks
int* find_value(const std::vector<int>& vec, int key) {
    // Must return pointer to allow nullptr
    for (auto& val : vec) {
        if (val == key) return &val;  // Dangerous - lifetime issues
    }
    return nullptr;
}

// GOOD: optional expresses intent clearly
std::optional<int> find_value(const std::vector<int>& vec, int key) {
    for (int val : vec) {
        if (val == key) return val;  // Value semantics, safe
    }
    return std::nullopt;
}
```

### std::expected (C++23)

**When to use:** Recoverable errors where caller needs details about what went wrong. Middle ground between exceptions and simple optional.

```cpp
// Error type with semantic information
enum class ParseError {
    invalid_syntax,
    unexpected_eof,
    type_mismatch
};

// GOOD: expected for errors with details
std::expected<JsonValue, ParseError> parse_json(std::string_view input) {
    if (input.empty()) {
        return std::unexpected(ParseError::unexpected_eof);
    }

    // Parse logic...
    if (syntax_error) {
        return std::unexpected(ParseError::invalid_syntax);
    }

    return JsonValue{/* ... */};
}

// Usage with monadic chaining
auto result = parse_json(input)
    .and_then([](JsonValue val) { return extract_field(val, "name"); })
    .transform([](std::string name) { return std::toupper(name); })
    .or_else([](ParseError err) {
        log_error("Parse failed", err);
        return std::unexpected(err);
    });

if (result) {
    std::cout << "Name: " << *result << std::endl;
} else {
    switch (result.error()) {
        case ParseError::invalid_syntax:
            std::cerr << "Syntax error" << std::endl;
            break;
        case ParseError::unexpected_eof:
            std::cerr << "Unexpected end of input" << std::endl;
            break;
    }
}
```

**Prevent ignoring errors with [[nodiscard]]:**
```cpp
[[nodiscard]] std::expected<Config, Error> load_config();

// Compiler warning if result ignored
load_config();  // Warning: ignoring return value
```

### Error handling decision framework

| Scenario | Use | Rationale |
|----------|-----|-----------|
| **Exceptional, unexpected error** | C++ exceptions | Forces handling, propagates automatically |
| **Expected true/false outcome** | `std::optional<T>` | Simple presence/absence |
| **Recoverable error with details** | `std::expected<T,E>` | Caller needs error information |
| **Performance-critical** | Error codes or `optional` | Zero overhead on success path |
| **C codebase** | Error codes | No exception support in C |
| **Constructor failure** | Exceptions | Constructors can't return error codes |
| **Real-time/embedded** | Error codes | Exceptions often disabled |

**Key principle:** Make errors hard to ignore. Exceptions can't be ignored. `[[nodiscard]]` prevents ignoring optional/expected. Error codes require explicit checks (easy to forget).

## Type system

Modern C and C++ provide robust type systems to catch errors at compile time. Use type safety features to express intent and prevent undefined behavior.

### Fundamental types

**C and C++ share fundamental types:**

```c
// Integers - C style
#include <stdint.h>
int count;                      // At least 16 bits
int32_t value;                  // Exactly 32 bits (guaranteed)
uint64_t big_count;             // Unsigned 64-bit
ptrdiff_t pointer_difference;   // Signed integer for pointer math

// Floating point
float single_precision;         // Single precision (32-bit)
double double_precision;        // Double precision (64-bit)
long double extended;           // Extended precision (varies)

// Characters
char character;                 // May be signed or unsigned (ambiguous!)
signed char signed_char;        // Always signed
unsigned char byte;             // Always unsigned (for binary data)

// Booleans - C99+
#include <stdbool.h>
bool flag;                      // C99: true or false
_Bool c_bool;                   // Core C type

// Void
void* generic_pointer;          // Generic pointer
// GOOD: Use for C FFI
typedef void (*function_ptr)(int, int);
```

**C++ improvements:**

```cpp
// Fixed-width types (C++11)
#include <cstdint>
uint8_t byte;                   // Always 8 bits unsigned
int64_t big_signed;             // Always 64 bits signed

// Strongly typed booleans
bool modern_flag = true;        // Clear intent

// Prefer std containers over raw arrays
std::vector<int> numbers;       // Dynamic array
std::array<int, 10> fixed;      // Fixed-size array with bounds checking
std::string text;               // Dynamic string
```

**C vs C++ decision framework:**

| Type | C Convention | C++ Convention | When to Use Each |
|------|-------------|----------------|------------------|
| Array | `int arr[10]` | `std::array<int, 10>` (fixed) or `std::vector<int>` (dynamic) | C: FFI/interop. C++: Application code |
| String | `const char* str` or `char buf[256]` | `std::string` or `std::string_view` | C: Low-level parsing. C++: All string data |
| Integer | `int`, `long`, `int32_t` | `int`, `int32_t`, or use width-specific types | C: Portable code. C++: Same, use `<cstdint>` |
| Boolean | `_Bool` (C99) or `int` (older) | `bool` | C: Use C99+. C++: Always use `bool` |

### Type safety: enum class vs enum

**C-style enums pollute namespace:**

```c
// BAD: C style - pollutes namespace
enum color {
    RED = 0,
    GREEN = 1,
    BLUE = 2
};
enum size {
    RED = 0,  // ERROR: RED already defined!
    SMALL = 1
};

// Workaround with prefixes
enum color_t {
    COLOR_RED,
    COLOR_GREEN,
    COLOR_BLUE
};
enum size_t {
    SIZE_SMALL,
    SIZE_MEDIUM,
    SIZE_LARGE
};
```

**C++ strongly typed enums (enum class) are superior:**

```cpp
// GOOD: C++ enum class - scoped and type-safe
enum class Color {
    Red = 0,      // PascalCase values in enum class
    Green = 1,
    Blue = 2
};

enum class Size {
    Small = 0,
    Medium = 1,
    Large = 2
};

// Usage requires explicit scope
Color my_color = Color::Red;      // Must use Color::
Size my_size = Size::Small;       // Can't accidentally mix enums

// Can specify underlying type
enum class Status : uint8_t {
    Pending = 0,
    Running = 1,
    Done = 2
};

// Scoped enums prevent implicit conversion
// This code won't compile (type safety!)
if (my_color == my_size) { }  // ERROR: different types

// vs C enum (would compile!)
if ((enum color_t)my_color == (enum size_t)my_size) { }  // Danger!
```

### Type aliases: using vs typedef

**Modern C++ using is clearer:**

```cpp
// OLD: typedef (C compatible)
typedef std::vector<int> IntVector;
typedef int (*FunctionPtr)(double);
typedef std::map<std::string, int> StringToIntMap;

// GOOD: using (C++11+, clearer template syntax)
using IntVector = std::vector<int>;
using FunctionPtr = int(*)(double);
using StringToIntMap = std::map<std::string, int>;

// using excels with templates
template<typename T>
using Vector = std::vector<T>;  // Template alias

// BAD: with typedef
// Can't do: template typedef

// Semantic aliases improve readability
using UserId = int;
using Timestamp = std::chrono::system_clock::time_point;

// vs
typedef int UserId;
typedef std::chrono::system_clock::time_point Timestamp;
// Less clear with typedef for complex types
```

### Modern C++ features: auto, structured bindings, templates

**auto - type deduction (C++11+)**

```cpp
// GOOD: auto for complex types
auto iter = vector.begin();                    // Deduced as vector<int>::iterator
auto result = calculate_value();               // Deduced from return type
auto pair = std::make_pair(1, "hello");        // Deduced as pair<int, const char*>

// GOOD: auto simplifies refactoring
std::map<std::string, std::vector<int>> data;
for (auto& [key, values] : data) {            // Type deduced from container
    // Process key and values
}

// BAD: Avoid auto if type isn't obvious
auto x = 5;                    // Is this int? long? Could be clearer
auto func = [](int a) { return a * 2; };      // Type hidden

// GOOD: auto with clear context
auto count = get_item_count();   // Function name clarifies intent
auto total = sum_values(items);  // Purpose clear from function
```

**Structured bindings (C++17)**

```cpp
// GOOD: Unpack tuple/pair/aggregate
auto [key, value] = get_pair();               // Unpacks std::pair
auto [x, y, z] = get_coordinates();           // Unpacks struct or tuple
auto [status, message] = validate_input();    // Unpacks std::pair

// With const
const auto [key, value] = map_entry;          // Const references

// In loops
std::vector<std::pair<std::string, int>> pairs;
for (auto& [name, count] : pairs) {
    std::cout << name << ": " << count << std::endl;
}

// BAD: Without structured bindings
auto pair = get_pair();
auto key = std::get<0>(pair);
auto value = std::get<1>(pair);  // Verbose and unclear

// Prevents accidental copies
for (auto [key, value] : map) { }        // Copies key and value
for (auto& [key, value] : map) { }       // References - preferred
```

**Templates and concepts**

```cpp
// GOOD: Generic template
template<typename T>
T add(T a, T b) {
    return a + b;
}

// C++20: Concepts enforce type requirements
template<typename T>
concept Addable = requires(T a, T b) {
    { a + b } -> std::convertible_to<T>;
};

template<Addable T>
T safe_add(T a, T b) {  // Only accepts types that support +
    return a + b;
}

// Usage
int sum1 = safe_add(1, 2);                    // OK: int is Addable
double sum2 = safe_add(1.5, 2.5);            // OK: double is Addable
// safe_add("hello", "world");                // ERROR: string requires concept_to_string

// BAD: Without concepts (compiles but error far from usage)
template<typename T>
T bad_add(T a, T b) {
    return a + b;                             // Error if T doesn't support +
}
// bad_add(std::vector<int>{}, std::vector<int>{});  // Error: deeply nested
```

### Type qualifiers: const, volatile, mutable, static

**const - compile-time enforcement**

```cpp
// GOOD: const for read-only data
const int MAX_ITEMS = 100;                    // Compile-time constant
const char* readonly_string = "hello";        // Pointer to const string

// GOOD: const member function (doesn't modify object)
class Counter {
    int count = 0;
public:
    int get_count() const {                   // Can't modify this->count
        return count;
    }

    void increment() {                        // Can modify this->count
        count++;
    }
};

// GOOD: const reference (no copy overhead, can't modify)
void process_data(const std::vector<int>& data) {
    // Can read data, can't modify
}

// const pointer semantics
int x = 5;
int* ptr = &x;                                // Pointer to non-const int
const int* const_ptr = &x;                    // Pointer to const int (can't modify through ptr)
int* const const_ptr_var = &x;                // Const pointer to int (can't change ptr, can modify int)
const int* const const_const = &x;            // Const pointer to const int

// BAD: mutable to bypass const (use sparingly)
class Cache {
    mutable std::map<int, int> cache;         // Mutable despite const function
public:
    int lookup(int key) const {
        if (!cache.count(key)) {
            cache[key] = expensive_compute(key);
        }
        return cache[key];
    }
};
```

**volatile - prevent compiler optimization**

```cpp
// GOOD: volatile for hardware registers or shared memory
volatile int hardware_register;               // Compiler won't cache in register
volatile bool shutdown_flag;                  // External signal changes

// BAD: Misuse for thread synchronization (use std::atomic)
volatile int shared_counter;                  // WRONG! Not thread-safe
shared_counter++;                             // Race condition even with volatile

// GOOD: Thread synchronization
std::atomic<int> atomic_counter;              // Thread-safe
atomic_counter++;
```

**static - linkage and storage**

```cpp
// File scope - internal linkage (C)
static int internal_counter = 0;              // Visible only in this translation unit

// C++: Use unnamed namespace instead
namespace {
    int internal_counter = 0;                 // Also internal, but C++ style
}

// Static member - shared across all instances
class Logger {
    static int message_count;                 // Shared by all Logger instances
public:
    void log(const std::string& msg) {
        message_count++;
    }
    static int get_message_count() {
        return message_count;
    }
};
int Logger::message_count = 0;                // Definition with initializer
```

### Containers and aggregates

**Prefer std containers over C arrays:**

```cpp
// BAD: C-style arrays (no bounds checking)
int arr[10];
arr[15] = 5;                                  // Buffer overflow! Undefined behavior

// GOOD: std::array (fixed size with bounds)
std::array<int, 10> arr;
// arr[15] = 5;                               // std::out_of_range in at()
arr.at(15);                                   // Safe: throws exception
arr[15];                                      // Unsafe: no bounds check

// GOOD: std::vector (dynamic size)
std::vector<int> dynamic;
dynamic.push_back(1);
dynamic.push_back(2);
// Bounds checking with at()
dynamic.at(10);                               // Exception if out of range

// Structs vs Classes
struct POD {                                  // Plain Old Data - no custom behavior
    int x;
    int y;
    std::string name;
};

class Widget {                                // Custom behavior, encapsulation
private:
    int value_;
public:
    Widget(int v) : value_(v) { }
    int get_value() const { return value_; }
    void set_value(int v) { value_ = v; }
};

// GOOD: Aggregates for simple data
auto point = POD{1, 2, "origin"};             // Aggregate initialization
auto [x, y, name] = point;                    // Destructuring
```

### Type system decision framework

| Scenario | Use | Rationale |
|----------|-----|-----------|
| **Enumeration with multiple values** | `enum class` (C++) or prefixed enum (C) | Type-safe, prevents accidental mixing |
| **Complex type in multiple places** | `using` alias (C++) or `typedef` (C) | Improves readability and refactoring |
| **Array of fixed size** | `std::array<T, N>` | Bounds checking, RAII semantics |
| **Array of dynamic size** | `std::vector<T>` | Automatic growth, RAII semantics |
| **Read-only function parameter** | `const T&` | No copy overhead, no modifications |
| **Integer width varies by platform** | `int32_t`, `uint64_t` from `<cstdint>` | Portable, explicit width |
| **Generic algorithm** | Template or C++20 concept | Compile-time type checking |
| **Hardware register or memory-mapped I/O** | `volatile` | Prevents compiler optimization |
| **Shared variable in threads** | `std::atomic<T>` | Thread-safe operations |
| **Type-only information (no runtime cost)** | `constexpr` | Zero-overhead abstraction |

## Functions and signatures

Function design establishes the contract between caller and implementation. C emphasizes explicit parameter passing and return codes; C++ adds overloading, templates, and special member functions for type-safe generic code.

### Declaration styles: C vs C++

**C function declarations (forward declarations required):**

```c
// C: Forward declaration required
int add(int a, int b);

// Implementation
int add(int a, int b) {
    return a + b;
}

// Function pointers
typedef int (*operation_t)(int, int);
operation_t op = &add;
int result = op(5, 3);
```

**C++ function declarations (member and free functions):**

```cpp
// C++: Member function declaration in class
class Calculator {
public:
    int add(int a, int b) const;      // const member function
    static int multiply(int a, int b); // static member function
private:
    int subtract(int a, int b);        // private helper
};

// Implementation can be in .cpp or inline
int Calculator::add(int a, int b) const {
    return a + b;
}

// Lambda functions (C++11)
auto op = [](int a, int b) { return a + b; };
int result = op(5, 3);

// std::function type erasure (avoid unless necessary)
std::function<int(int, int)> operation = [](int a, int b) { return a + b; };
```

**Default parameters (C++, use sparingly):**

```cpp
// GOOD: Sensible defaults reduce API surface
void render(int width, int height, bool vsync = true, int framerate = 60) {
    // ...
}
render(800, 600);  // Uses vsync=true, framerate=60

// BAD: Hidden dependencies make code harder to understand
void process(int timeout = 5000, bool async = true, int retries = 3) {
    // Caller doesn't know what defaults are without reading docs
}
```

### Parameter passing conventions

Choose parameter passing based on performance and semantics:

| Parameter Type | Performance | Size | Use Case | Example |
|---|---|---|---|---|
| **By value** | Copy on pass | Small (< 64 bits) | Input only, simple types | `void process(int count)` |
| **const reference** | Zero-copy | Any | Input only, prevents modification | `void process(const std::vector<int>& items)` |
| **Non-const reference** | Zero-copy | Any | Output parameter (rare in C++) | `void get_coordinates(int& x, int& y)` |
| **Pointer** | Address only | Fixed | Optional (can be nullptr), C-style | `void process(const Item* item)` |
| **Rvalue reference** | Zero-copy move | Any | Sink parameters (capture ownership) | `void store(std::vector<int>&& data)` |
| **std::optional<ref>** | Zero-copy | Fixed | Optional value (C++17+) | Use with caution; unclear semantics |

**Performance analysis:**

```cpp
// GOOD: By value for small types
void process(int x, double y, bool flag) {  // Pass by value: <= 16 bytes
    // No indirection, cache-friendly
}

// GOOD: Const reference for large types
void process(const std::vector<int>& items) {  // Zero-copy
    // Prevents accidental modification
}

// BAD: Reference to temporary
const int& get_value() {
    int x = 42;
    return x;  // Dangling reference!
}

// GOOD: Return by value (move semantics makes it efficient)
std::vector<int> get_items() {
    std::vector<int> items;
    items.push_back(1);
    return items;  // Moved, not copied (NRVO or move)
}

// C pattern: Pointer for optional output
void parse(const char* input, int* out_value) {
    if (!input || !out_value) {
        return;  // Error
    }
    *out_value = atoi(input);
}
```

**const correctness enforces contract:**

```cpp
// GOOD: const reference parameter prevents modification
void update_ui(const std::string& message) {
    // message = "new text";  // Compiler error!
    display(message);
}

// GOOD: const member function (can't modify object state)
class Logger {
public:
    int get_line_count() const {        // Promise not to modify
        return line_count_;
    }
    void log(const std::string& msg) {  // Can modify object
        lines_.push_back(msg);
    }
private:
    std::vector<std::string> lines_;
    int line_count_ = 0;
};
```

### Return value patterns

Choose return patterns based on whether the function always produces a value:

**Return by value (default):**

```cpp
// GOOD: Simple return type with move semantics
std::string get_name() {
    std::string name = "Alice";
    return name;  // Moved, not copied
}

// GOOD: Small types (int, bool)
int calculate_sum(const std::vector<int>& items) {
    return std::accumulate(items.begin(), items.end(), 0);
}

// GOOD: User-defined types with move semantics
std::vector<int> get_items() {
    std::vector<int> items;
    items.reserve(100);
    // Fill items...
    return items;  // Efficient: moved
}
```

**const reference return (rarely appropriate):**

```cpp
// GOOD: Return reference to internal state only if lifetime is guaranteed
class Registry {
    std::map<int, std::string> entries_;
public:
    const std::string& lookup(int key) const {
        static const std::string empty;
        auto it = entries_.find(key);
        return it != entries_.end() ? it->second : empty;
    }
};

// BAD: Returning reference to temporary
const std::string& get_name() {
    std::string name = "Alice";
    return name;  // Dangling reference!
}

// GOOD: Use std::optional instead
std::optional<std::string> get_name() {
    return "Alice";
}
```

**Pointer return (C-style, mostly avoided in modern C++):**

```cpp
// C pattern: Pointer for optional value or ownership transfer
int* allocate_array(int size) {
    return (int*)malloc(size * sizeof(int));  // Caller must free
}

// GOOD: C++: Return unique_ptr instead
std::unique_ptr<int[]> allocate_array(int size) {
    return std::make_unique<int[]>(size);     // Automatic cleanup
}

// Pointer to indicate nullable
const Item* find_item(const std::vector<Item>& items, int key) {
    for (const auto& item : items) {
        if (item.id == key) return &item;  // Dangerous: lifetime issue
    }
    return nullptr;
}

// GOOD: Use optional instead
std::optional<Item> find_item(const std::vector<Item>& items, int key) {
    for (const auto& item : items) {
        if (item.id == key) return item;  // Safe: value semantics
    }
    return std::nullopt;
}
```

**std::optional (C++17):**

```cpp
// GOOD: Return optional for functions that might not produce value
std::optional<int> parse_int(const std::string& str) {
    try {
        return std::stoi(str);
    } catch (...) {
        return std::nullopt;
    }
}

// Usage with pattern matching
if (auto value = parse_int("42")) {
    std::cout << "Value: " << *value << std::endl;
} else {
    std::cout << "Invalid integer" << std::endl;
}

// Provide default
int value = parse_int("42").value_or(0);
```

### Function overloading (C++ only)

Overloading allows same name with different parameter types. Use carefully to avoid confusion.

```cpp
// GOOD: Overloading for semantic clarity
void display(int number) {
    std::cout << "Number: " << number << std::endl;
}

void display(const std::string& text) {
    std::cout << "Text: " << text << std::endl;
}

void display(double value) {
    std::cout << "Float: " << value << std::endl;
}

display(42);           // Calls display(int)
display("hello");      // Calls display(const std::string&)
display(3.14);         // Calls display(double)

// GOOD: Overloading with const
class Buffer {
public:
    int& get(int index) {           // Non-const: return mutable reference
        return data_[index];
    }
    const int& get(int index) const { // Const: return const reference
        return data_[index];
    }
private:
    std::vector<int> data_;
};

// BAD: Overloading that differs only in const
void process(int* ptr) {            // Different from below
    *ptr = 42;
}
void process(const int* ptr) {       // Different signature - OK
    std::cout << *ptr << std::endl;
}

// BAD: Overloading that differs in difficult-to-understand ways
void calculate(int x, int y);       // v1
void calculate(int x);              // v2 - caller confused about default
```

**Overload resolution (function matching order):**

```cpp
// C++ uses overload resolution: exact match > conversion > template
void func(int);
void func(double);

func(5);              // Exact match: func(int)
func(5.5);            // Exact match: func(double)
func(5u);             // Conversion needed: either works (ambiguous!)
// ambiguity error on func(5u) - resolves to neither int nor double perfectly
```

### Special member functions: Rule of Five

The **Rule of Five** states: if you define any of these, define all five:
1. Destructor
2. Copy constructor
3. Copy assignment operator
4. Move constructor (C++11)
5. Move assignment operator (C++11)

**Why it matters:** Resource management, deep copies, move semantics.

```cpp
// GOOD: Complete Rule of Five
class Resource {
    int* data_;
    int size_;

public:
    // Constructor
    Resource(int s) : size_(s) {
        data_ = new int[s];
    }

    // Destructor - releases resources
    ~Resource() {
        delete[] data_;
    }

    // Copy constructor - deep copy
    Resource(const Resource& other) : size_(other.size_) {
        data_ = new int[size_];
        std::copy(other.data_, other.data_ + size_, data_);
    }

    // Copy assignment - self-assignment safe, deep copy
    Resource& operator=(const Resource& other) {
        if (this == &other) return *this;  // Self-assignment guard
        delete[] data_;
        size_ = other.size_;
        data_ = new int[size_];
        std::copy(other.data_, other.data_ + size_, data_);
        return *this;
    }

    // Move constructor - transfer ownership
    Resource(Resource&& other) noexcept
        : data_(other.data_), size_(other.size_) {
        other.data_ = nullptr;
        other.size_ = 0;
    }

    // Move assignment - transfer ownership, release old resources
    Resource& operator=(Resource&& other) noexcept {
        if (this == &other) return *this;
        delete[] data_;
        data_ = other.data_;
        size_ = other.size_;
        other.data_ = nullptr;
        other.size_ = 0;
        return *this;
    }
};

// Usage demonstrates copy vs move
Resource create_resource(int size) {
    Resource res(size);
    return res;  // Move constructor called (not copy)
}

Resource res1(100);
Resource res2 = res1;              // Copy constructor
Resource res3 = std::move(res1);   // Move constructor (res1 now empty)
res2 = res3;                       // Copy assignment
res2 = std::move(res3);            // Move assignment
```

**When Rule of Five isn't needed (default behavior works):**

```cpp
// GOOD: No custom destructor = no custom Rule of Five
class SimpleData {
    std::string name_;        // Manages its own lifetime
    std::vector<int> values_; // Manages its own lifetime
    int count_;               // POD - no cleanup needed
public:
    SimpleData() = default;
    // Copy/move generated automatically by compiler
    // Calls copy/move of string and vector
};
```

**Default the rule of five when not implementing custom behavior:**

```cpp
class MyClass {
public:
    // Explicitly = default to use compiler-generated
    ~MyClass() = default;
    MyClass(const MyClass&) = default;
    MyClass& operator=(const MyClass&) = default;
    MyClass(MyClass&&) = default;
    MyClass& operator=(MyClass&&) = default;
private:
    std::unique_ptr<int> data_;  // Compiler does the right thing
};
```

### const member functions and constexpr

**const member functions** promise not to modify object state:

```cpp
class Counter {
    mutable int access_count_ = 0;
    int value_ = 0;

public:
    // const member function - can't modify value_
    int get_value() const {
        access_count_++;           // OK: mutable member
        // value_ = 42;             // ERROR: modifies non-mutable
        return value_;
    }

    // Non-const member function - can modify
    void set_value(int v) {
        value_ = v;
    }
};

// Const reference parameter typically calls const member functions
void use_counter(const Counter& c) {
    c.get_value();      // OK: calls const version
    // c.set_value(42);  // ERROR: set_value not const
}
```

**constexpr functions (evaluated at compile time):**

```cpp
// GOOD: constexpr for compile-time computation
constexpr int factorial(int n) {
    return n <= 1 ? 1 : n * factorial(n - 1);
}

// Evaluated at compile time
constexpr int fact5 = factorial(5);  // 120 (compile-time)

int value = get_user_input();
int fact_value = factorial(value);   // Runtime (value not compile-time constant)

// GOOD: constexpr with std containers (C++20)
constexpr std::vector<int> get_sequence() {
    std::vector<int> v;
    for (int i = 0; i < 10; i++) {
        v.push_back(i * i);
    }
    return v;
}

// constexpr member function
class Point {
    int x_ = 0, y_ = 0;
public:
    constexpr int get_x() const { return x_; }
    constexpr int get_y() const { return y_; }
};

constexpr Point p{3, 4};
constexpr int x = p.get_x();  // 3 at compile time
```

**Benefits of constexpr:**
- Compile-time computation (zero runtime cost)
- Improves code clarity (function does same thing always)
- Enables template metaprogramming

### Inline and linkage

**inline keyword (modern usage is different):**

```cpp
// OLD: inline told compiler to inline (modern compilers ignore this)
inline int add(int a, int b) {
    return a + b;
}

// MODERN: Use inline to define in header without linker errors
// Multiple translation units can safely include this
inline int add(int a, int b) {
    return a + b;
}

// NO inline needed for member functions defined in class body
class Calculator {
public:
    int add(int a, int b) {  // Implicitly inline
        return a + b;
    }

    // If defined outside, mark inline to avoid linker errors
    int multiply(int a, int b);
};
inline int Calculator::multiply(int a, int b) {
    return a * b;
}
```

**External linkage (default for functions):**

```cpp
// In header (shared across translation units)
void public_function();  // External linkage - visible everywhere

// In .cpp (internal linkage)
static void internal_function() { }  // Static: internal linkage only

// C++: Use anonymous namespace instead
namespace {
    void internal_function() { }      // Internal linkage
}
```

**Function templates require definition in header:**

```cpp
// GOOD: Template in header (must be complete)
template<typename T>
T add(T a, T b) {
    return a + b;
}

// GOOD: Explicit instantiation declaration/definition
template<typename T>
T multiply(T a, T b);  // Declaration

// Can instantiate for specific types in .cpp
template int multiply<int>(int, int);
template double multiply<double>(double, double);
```

### Functions and signatures decision framework

| Scenario | Choice | Rationale |
|----------|--------|-----------|
| **Simple input (< 64 bits)** | Pass by value | No indirection overhead |
| **Large object, read-only** | Pass const reference | Zero-copy, prevents modification |
| **Output parameter (rare)** | Pass non-const reference | Explicit that object will be modified |
| **Optional parameter** | Use default argument carefully | Simpler API surface |
| **Optional return value** | `std::optional<T>` | Safe, forces handling |
| **Many parameter groups** | Bundle in struct or use builder pattern | Improves readability |
| **Function needs to transfer ownership** | Use unique_ptr or return by value | Clear responsibility |
| **Member function doesn't modify state** | Mark const | Enables use with const objects |
| **Resource (RAII wrapper)** | Implement Rule of Five | Correct copy/move semantics |
| **Algorithm logic same for multiple types** | Use template | Type-safe generic code |
| **Performance-critical computation** | Use constexpr if possible | Compile-time evaluation |
| **Function only in .cpp** | Use anonymous namespace or static | Internal linkage, no export |

## Classes and structures

C++ uses classes for encapsulation and data hiding, while structs (in C++) are typically used for data aggregates. C uses structs for grouping data with no associated member functions. Design decisions center on responsibility, ownership, and whether behavior matters.

### Struct vs class decision framework

**C structs - data only:**

```c
// C: struct for grouping related data
struct Point {
    int x;
    int y;
};

// Usage: direct member access
struct Point p = {5, 10};
p.x = 20;

// Function pointers for behavior
typedef void (*draw_func)(struct Point);
void draw_point(struct Point p);

// Opaque struct for encapsulation (C pattern)
typedef struct Queue Queue;  // Forward declaration
Queue* queue_create();
void queue_push(Queue* q, int value);
int queue_pop(Queue* q);
void queue_destroy(Queue* q);
```

**C++ struct vs class distinction:**

| Aspect | struct | class |
|--------|--------|-------|
| **Default access** | public | private |
| **Default inheritance** | public | private |
| **Use case** | Data aggregate, POD | Encapsulation, complex behavior |
| **Memory layout** | Contiguous, predictable | Same, but may hide details |
| **Member functions** | Yes (same as class) | Yes (recommended) |

**Decision criteria:**

```cpp
// Use struct for:
// 1. Plain Old Data (POD) - no custom constructors/destructors
struct Color {
    uint8_t r, g, b, a;
};

// 2. Data aggregate with few helper functions
struct Configuration {
    std::string app_name;
    int port;
    bool debug_mode;

    // Simple helpers OK
    int get_port() const { return port; }
};

// Use class for:
// 1. Encapsulation with private state
class Logger {
private:
    std::vector<std::string> messages_;
    int verbosity_;

public:
    Logger(int v) : verbosity_(v) { }
    void log(const std::string& msg);
    int get_message_count() const;
};

// 2. Complex behavior requiring invariants
class BankAccount {
private:
    double balance_;
    std::string account_number_;

    void validate_balance() {
        if (balance_ < 0) throw std::logic_error("negative balance");
    }

public:
    BankAccount(const std::string& num, double initial)
        : account_number_(num), balance_(initial) {
        validate_balance();
    }

    void deposit(double amount);
    bool withdraw(double amount);
    double get_balance() const;
};

// 3. Polymorphic types (virtual functions)
class Shape {
public:
    virtual ~Shape() = default;
    virtual double area() const = 0;
};

class Circle : public Shape {
private:
    double radius_;
public:
    Circle(double r) : radius_(r) { }
    double area() const override { return 3.14159 * radius_ * radius_; }
};
```

**GOOD: Struct for POD data**
```cpp
struct DataPoint {
    int timestamp;
    double value;
    int sensor_id;
};

// Aggregate initialization
DataPoint dp{1000, 42.5, 3};
auto [ts, val, id] = dp;  // Structured binding
```

**BAD: Struct when you need encapsulation**
```cpp
// Don't do this - should be class
struct BankAccount {
    double balance;  // Exposed - anyone can set negative!
    void withdraw(double amount) {
        balance -= amount;  // No validation
    }
};
```

### Class design principles

**Single Responsibility Principle:** Each class has one reason to change.

```cpp
// BAD: Multiple responsibilities
class User {
    std::string name_;
    std::string email_;

public:
    void save_to_database() { }  // Database responsibility
    void send_email() { }        // Email responsibility
    void validate_input() { }    // Validation responsibility
};

// GOOD: Single responsibility
class User {
private:
    std::string name_;
    std::string email_;

public:
    const std::string& get_name() const { return name_; }
    const std::string& get_email() const { return email_; }
    bool is_valid() const;
};

class UserRepository {
public:
    void save(const User& user);
    User load(int id);
};

class UserNotifier {
public:
    void send_welcome_email(const User& user);
};
```

**Encapsulation:** Hide implementation details, expose only necessary interface.

```cpp
// GOOD: Data hiding with public interface
class Counter {
private:
    int value_ = 0;
    int max_value_;

    void validate_increment() {
        if (value_ >= max_value_) {
            throw std::overflow_error("counter overflow");
        }
    }

public:
    Counter(int max) : max_value_(max) { }

    void increment() {
        validate_increment();
        value_++;
    }

    int get() const { return value_; }
    void reset() { value_ = 0; }
};

// BAD: Public data breaks encapsulation
class BadCounter {
public:
    int value;  // Anyone can break invariants
    int max_value;

    void increment() {
        value++;  // No validation
    }
};
```

**Const correctness:** Member functions that don't modify state should be const.

```cpp
// GOOD: Clear intent with const
class Cache {
private:
    std::map<int, std::string> data_;
    mutable int hits_ = 0;

public:
    // const function - doesn't modify public state
    std::optional<std::string> get(int key) const {
        if (data_.count(key)) {
            hits_++;  // OK: mutable member
            return data_.at(key);
        }
        return std::nullopt;
    }

    // Non-const - modifies state
    void set(int key, const std::string& value) {
        data_[key] = value;
    }

    int get_hit_count() const { return hits_; }
};

// Usage
void display_user(const Cache& cache) {
    auto user = cache.get(42);  // OK: calls const get()
    // cache.set(42, "new");     // ERROR: set() not const
}
```

### Inheritance patterns

Inheritance enables polymorphism but creates tight coupling. Use carefully and prefer composition for code reuse.

**When inheritance is appropriate:**

```cpp
// GOOD: Polymorphic base class (is-a relationship)
class Shape {
public:
    virtual ~Shape() = default;  // REQUIRED: virtual destructor
    virtual double area() const = 0;
    virtual double perimeter() const = 0;
};

class Rectangle : public Shape {
private:
    double width_, height_;

public:
    Rectangle(double w, double h) : width_(w), height_(h) { }

    double area() const override {
        return width_ * height_;
    }

    double perimeter() const override {
        return 2 * (width_ + height_);
    }
};

class Circle : public Shape {
private:
    double radius_;

public:
    explicit Circle(double r) : radius_(r) { }

    double area() const override {
        return 3.14159 * radius_ * radius_;
    }

    double perimeter() const override {
        return 2 * 3.14159 * radius_;
    }
};

// Usage: polymorphism
void print_area(const Shape& shape) {
    std::cout << "Area: " << shape.area() << std::endl;
}

std::vector<std::unique_ptr<Shape>> shapes;
shapes.push_back(std::make_unique<Rectangle>(5, 3));
shapes.push_back(std::make_unique<Circle>(2));

for (const auto& shape : shapes) {
    print_area(*shape);  // Calls correct area() for each type
}
```

**Virtual destructors are REQUIRED:**

```cpp
// BAD: No virtual destructor - memory leak
class Base {
public:
    ~Base() { }  // Not virtual
};

class Derived : public Base {
private:
    int* data_;
public:
    Derived() { data_ = new int[100]; }
    ~Derived() { delete[] data_; }  // Never called!
};

std::unique_ptr<Base> ptr = std::make_unique<Derived>();
// When ptr destroyed, calls Base::~Base(), not Derived::~Derived()
// Derived destructor never runs - MEMORY LEAK

// GOOD: Virtual destructor
class Base {
public:
    virtual ~Base() = default;  // Virtual - calls derived destructor
};

class Derived : public Base {
private:
    int* data_;
public:
    Derived() { data_ = new int[100]; }
    ~Derived() override { delete[] data_; }  // Called correctly
};

std::unique_ptr<Base> ptr = std::make_unique<Derived>();
// When ptr destroyed, calls Derived::~Derived() then Base::~Base()
// Proper cleanup
```

**Override keyword (C++11) prevents bugs:**

```cpp
// GOOD: override catches mistakes
class Base {
public:
    virtual ~Base() = default;
    virtual void process(int value);
};

class Derived : public Base {
public:
    void process(int value) override {  // override keyword - safer
        // Implementation
    }
};

// BAD: Typo in function signature
class BadDerived : public Base {
public:
    void process(double value) {  // ERROR: different signature!
        // This is a new function, not an override
    }
};

// With override keyword:
class BadDerived : public Base {
public:
    void process(double value) override {  // COMPILER ERROR: doesn't match base
    }
};
```

**Abstract base classes (pure virtual functions):**

```cpp
// GOOD: Abstract interface
class DataStore {
public:
    virtual ~DataStore() = default;

    virtual void save(int id, const std::string& data) = 0;
    virtual std::optional<std::string> load(int id) const = 0;
    virtual void delete_entry(int id) = 0;
};

// Concrete implementations
class FileStore : public DataStore {
public:
    void save(int id, const std::string& data) override;
    std::optional<std::string> load(int id) const override;
    void delete_entry(int id) override;
};

class DatabaseStore : public DataStore {
public:
    void save(int id, const std::string& data) override;
    std::optional<std::string> load(int id) const override;
    void delete_entry(int id) override;
};

// Usage: switch implementations without changing code
void backup_data(DataStore& store) {
    store.save(1, "important data");
}

FileStore fs;
backup_data(fs);

DatabaseStore db;
backup_data(db);
```

### Special member functions: Rule of Five

**The Rule of Five:** If you define any of these, define all five:
1. Destructor
2. Copy constructor
3. Copy assignment operator
4. Move constructor
5. Move assignment operator

This applies to classes that manage resources.

```cpp
// GOOD: Complete Rule of Five
class DynamicArray {
private:
    int* data_;
    int size_;

public:
    // Constructor
    explicit DynamicArray(int size) : size_(size) {
        data_ = new int[size];
        std::fill(data_, data_ + size, 0);
    }

    // Destructor - releases memory
    ~DynamicArray() {
        delete[] data_;
    }

    // Copy constructor - deep copy
    DynamicArray(const DynamicArray& other)
        : size_(other.size_) {
        data_ = new int[size_];
        std::copy(other.data_, other.data_ + size_, data_);
    }

    // Copy assignment - self-assignment safe
    DynamicArray& operator=(const DynamicArray& other) {
        if (this == &other) return *this;  // Self-assignment guard

        delete[] data_;
        size_ = other.size_;
        data_ = new int[size_];
        std::copy(other.data_, other.data_ + size_, data_);
        return *this;
    }

    // Move constructor - transfer ownership
    DynamicArray(DynamicArray&& other) noexcept
        : data_(other.data_), size_(other.size_) {
        other.data_ = nullptr;
        other.size_ = 0;
    }

    // Move assignment - transfer and clean up
    DynamicArray& operator=(DynamicArray&& other) noexcept {
        if (this == &other) return *this;

        delete[] data_;
        data_ = other.data_;
        size_ = other.size_;
        other.data_ = nullptr;
        other.size_ = 0;
        return *this;
    }

    int get_size() const { return size_; }
    int& operator[](int index) { return data_[index]; }
    const int& operator[](int index) const { return data_[index]; }
};

// Usage patterns
DynamicArray arr1(10);
DynamicArray arr2 = arr1;           // Copy constructor
DynamicArray arr3 = std::move(arr1); // Move constructor (arr1 now empty)
arr2 = arr3;                        // Copy assignment
arr2 = std::move(arr3);             // Move assignment
```

**When you DON'T need custom Rule of Five:**

```cpp
// GOOD: Let compiler generate - simpler and correct
class SimplePoint {
    std::unique_ptr<int> x_;  // Manages its own lifetime
    std::unique_ptr<int> y_;
    std::string label_;       // Manages its own lifetime

public:
    SimplePoint() = default;
    // Compiler generates:
    // - Destructor calls unique_ptr and string destructors
    // - Move constructor/assignment (efficient)
    // - Copy constructor/assignment (deleted if any unique_ptr)
};

// GOOD: Explicitly default when appropriate
class DataPoint {
private:
    double value_;
    int timestamp_;

public:
    ~DataPoint() = default;
    DataPoint(const DataPoint&) = default;
    DataPoint& operator=(const DataPoint&) = default;
    DataPoint(DataPoint&&) = default;
    DataPoint& operator=(DataPoint&&) = default;
};
```

**Delete copy when move semantics required:**

```cpp
// GOOD: Move-only type (non-copyable)
class FileHandle {
    int fd_;

public:
    explicit FileHandle(const std::string& path);
    ~FileHandle();

    // Delete copy operations
    FileHandle(const FileHandle&) = delete;
    FileHandle& operator=(const FileHandle&) = delete;

    // Allow move operations
    FileHandle(FileHandle&& other) noexcept
        : fd_(other.fd_) {
        other.fd_ = -1;
    }

    FileHandle& operator=(FileHandle&& other) noexcept {
        if (this != &other) {
            close();
            fd_ = other.fd_;
            other.fd_ = -1;
        }
        return *this;
    }

private:
    void close();
};

// Usage enforces move semantics
FileHandle f1("data.txt");
// FileHandle f2 = f1;  // ERROR: copy deleted
FileHandle f2 = std::move(f1);  // OK: move
```

### Modern alternatives to inheritance

**Composition over inheritance (preferred):**

```cpp
// BAD: Deep inheritance hierarchy
class Vehicle {
protected:
    double speed_;
public:
    virtual ~Vehicle() = default;
    virtual void start() = 0;
};

class Car : public Vehicle {
    // All cars inherit speed_
};

class SportsCar : public Car {
    // Adds performance features
};

// Problem: Tight coupling, fragile base class problem

// GOOD: Composition - flexible and testable
class Engine {
public:
    void start();
    double get_max_speed() const;
};

class Transmission {
public:
    void engage_gear(int gear);
    double get_efficiency() const;
};

class Car {
private:
    Engine engine_;
    Transmission transmission_;
    double current_speed_ = 0;

public:
    void start() {
        engine_.start();
    }

    void accelerate() {
        current_speed_ += engine_.get_max_speed() * transmission_.get_efficiency();
    }

    double get_speed() const { return current_speed_; }
};

class SportsCar {
private:
    Engine performance_engine_;  // Higher performance engine
    Transmission racing_transmission_;
    double current_speed_ = 0;

public:
    void start() {
        performance_engine_.start();
    }

    void accelerate() {
        current_speed_ += performance_engine_.get_max_speed() * 1.2;
    }
};
```

**std::variant for type unions (C++17):**

```cpp
// GOOD: Type-safe union using variant
enum class ErrorType {
    FileNotFound,
    PermissionDenied,
    NetworkTimeout,
    ParseError
};

struct FileNotFoundError {
    std::string path;
};

struct PermissionError {
    std::string path;
};

struct NetworkError {
    int timeout_ms;
};

struct ParseError {
    int line;
    int column;
};

using Result = std::variant<
    std::string,          // Success value
    FileNotFoundError,
    PermissionError,
    NetworkError,
    ParseError
>;

Result load_config(const std::string& path) {
    if (!file_exists(path)) {
        return FileNotFoundError{path};
    }

    if (!has_permission(path)) {
        return PermissionError{path};
    }

    if (!connect_network()) {
        return NetworkError{5000};
    }

    if (auto parsed = parse_file(path)) {
        return *parsed;
    }

    return ParseError{10, 5};
}

// Usage with std::visit
void handle_result(const Result& result) {
    std::visit([](const auto& value) {
        if constexpr (std::is_same_v<std::decay_t<decltype(value)>, std::string>) {
            std::cout << "Config: " << value << std::endl;
        } else if constexpr (std::is_same_v<std::decay_t<decltype(value)>, FileNotFoundError>) {
            std::cerr << "File not found: " << value.path << std::endl;
        } else if constexpr (std::is_same_v<std::decay_t<decltype(value)>, NetworkError>) {
            std::cerr << "Network timeout: " << value.timeout_ms << "ms" << std::endl;
        }
        // ... handle other types
    }, result);
}
```

**std::variant as type-safe enum alternative:**

```cpp
// BAD: Inheritance for simple type tagging
class Message {
public:
    virtual ~Message() = default;
    virtual void process() = 0;
};

class UserMessage : public Message {
    std::string username_;
public:
    void process() override { }
};

class SystemMessage : public Message {
    int code_;
public:
    void process() override { }
};

// GOOD: std::variant for type union
struct UserMessage {
    std::string username;
    std::string text;
};

struct SystemMessage {
    int code;
    std::string description;
};

using Message = std::variant<UserMessage, SystemMessage>;

void process_message(const Message& msg) {
    std::visit([](const auto& m) {
        if constexpr (std::is_same_v<std::decay_t<decltype(m)>, UserMessage>) {
            std::cout << m.username << ": " << m.text << std::endl;
        } else if constexpr (std::is_same_v<std::decay_t<decltype(m)>, SystemMessage>) {
            std::cerr << "System [" << m.code << "]: " << m.description << std::endl;
        }
    }, msg);
}
```

### Classes and structures decision framework

| Scenario | Use | Rationale |
|----------|-----|-----------|
| **Simple data container** | struct with public members | Clear intent, minimal overhead |
| **Encapsulation with invariants** | class with private members | Hide implementation, enforce constraints |
| **Shared interface for multiple types** | Abstract base class | Polymorphism via virtual functions |
| **Type union without inheritance** | std::variant | Type-safe, no virtual cost |
| **Code reuse** | Composition | More flexible than inheritance |
| **Resource management** | Implement Rule of Five | Correct copy/move semantics |
| **Non-copyable resource** | =delete copy, allow move | Enforce unique ownership |
| **Simple group of related functions** | Free functions in namespace | No OO overhead if not needed |

## Const correctness

**Const correctness** is a compile-time mechanism that enforces immutability contracts. By marking data as const, you tell the compiler and other developers that certain values won't be modified, catching violations at compile time before they become bugs.

### The const promise

**Core principle:** const means "I promise not to modify this through this interface".

```cpp
// GOOD: const variable - compile-time enforcement of immutability
const int max_items = 100;
// max_items = 200;  // COMPILER ERROR

// GOOD: const reference parameter - no copy overhead, no modification
void process_items(const std::vector<int>& items) {
    // items.push_back(1);  // COMPILER ERROR: can't modify
    for (int item : items) {
        // Use item...
    }
}

// GOOD: const member function - promises not to modify object state
class Counter {
    int value_ = 0;

public:
    int get_value() const {
        // return value_++;  // COMPILER ERROR: can't modify
        return value_;
    }

    void increment() {
        value_++;  // OK: non-const member can modify
    }
};

// GOOD: const object ensures only const member functions can be called
const Counter c;
c.get_value();   // OK: const function
// c.increment();  // COMPILER ERROR: non-const function requires non-const object
```

**Why const matters:**
- **Compile-time verification:** Errors caught before runtime
- **Intent documentation:** Code clearly shows what won't be modified
- **Optimization opportunities:** Compiler can optimize knowing value won't change
- **Prevents accidental modification:** Especially critical in long functions or when refactoring

### Const member functions

**Inspector methods** (methods that read without modifying) should be marked const.

```cpp
// GOOD: Clear intent with const
class Cache {
    std::map<std::string, std::string> data_;
    mutable int access_count_ = 0;  // mutable allows modification in const functions

public:
    // const member function - doesn't modify cache data
    std::optional<std::string> get(const std::string& key) const {
        access_count_++;  // OK: mutable member
        auto it = data_.find(key);
        return it != data_.end() ? std::optional(it->second) : std::nullopt;
    }

    // Non-const member function - modifies cache
    void set(const std::string& key, const std::string& value) {
        data_[key] = value;
    }

    // Const function - read-only
    int get_access_count() const {
        return access_count_;
    }

    // Non-const function - modifies state
    void clear() {
        data_.clear();
        access_count_ = 0;
    }
};

// Usage: const vs non-const calls
Cache cache;
cache.set("key1", "value1");           // OK: non-const function
cache.get("key1");                     // OK: const function

const Cache const_cache;
// const_cache.set("key2", "value2");  // ERROR: set() not const
const_cache.get("key1");               // OK: const function
```

**const overloading:** Provide both const and non-const versions for different behavior.

```cpp
// GOOD: Different behavior for const vs non-const
class Vector {
private:
    std::vector<int> data_;

public:
    // Non-const version - returns modifiable reference
    int& operator[](int index) {
        return data_[index];
    }

    // Const version - returns immutable reference
    const int& operator[](int index) const {
        return data_[index];
    }

    // Read-only access
    bool contains(int value) const {
        return std::find(data_.begin(), data_.end(), value) != data_.end();
    }
};

// Usage
Vector vec;
vec[0] = 42;                           // Calls non-const operator[]

const Vector const_vec = vec;
int val = const_vec[0];                // Calls const operator[]
// const_vec[0] = 100;                 // ERROR: const operator[] returns const int&
```

**BAD: Bypassing const (use sparingly):**

```cpp
// BAD: Casting away const (usually indicates design problem)
class Logger {
    mutable std::vector<std::string> messages_;

public:
    void log(const std::string& msg) const {
        // Can modify mutable member in const function
        messages_.push_back(msg);  // OK with mutable
    }
};

// Very BAD: const_cast (avoid except in C interop)
void use_c_function(const std::string& str) {
    // If the C function incorrectly takes non-const char* but doesn't modify
    c_function(const_cast<char*>(str.c_str()));  // Last resort only
}
```

### Const references and parameters

**Parameter passing with const:**

Const references prevent copying large objects and prevent accidental modification:

```cpp
// GOOD: Const reference - zero-copy, can't modify
void process_items(const std::vector<int>& items) {
    for (int item : items) {
        std::cout << item << std::endl;
    }
    // items.push_back(1);  // ERROR: can't modify
}

// GOOD: Pass by value for small types (no const needed)
void process_single(int value) {
    // No const needed - value is already a copy
    value = 42;  // Doesn't affect original
}

// GOOD: Non-const reference when function modifies parameter (rare, make intent clear)
void get_coordinates(const Point& origin, int& x, int& y) {
    // Fills in x and y from origin
    x = origin.x();
    y = origin.y();
}

// GOOD: Use std::optional for optional output (C++17+)
std::optional<Point> find_intersection(const Line& a, const Line& b) {
    // Returns either point or empty
    if (parallel(a, b)) return std::nullopt;
    return calculate_intersection(a, b);
}

// BAD: Non-const reference for input-only parameter
void process(std::vector<int>& items) {  // Suggests modification
    // Process items read-only
    for (int item : items) { /* ... */ }
    // Confusing - reader expects modification
}

// BAD: Returning non-const reference to temporary
const std::string& get_name() {
    std::string name = "Alice";
    return name;  // DANGLING REFERENCE!
}

// GOOD: Return by value instead
std::string get_name() {
    std::string name = "Alice";
    return name;  // Moved, not copied
}
```

**Const propagation in template code:**

```cpp
// GOOD: Forward const-ness in generic code
template<typename T>
auto process(const T& input) -> decltype(input.get_value()) {
    // Calls const version of get_value if it exists
    return input.get_value();
}

// GOOD: Preserve const-ness with auto
const std::vector<int> vec = {1, 2, 3};
const auto& front = vec.front();       // Deduced as const reference
auto iter = vec.begin();               // Deduced as const iterator
```

### Pointer const variations

**Three different meanings with pointers - read right-to-left:**

```cpp
int x = 5;
int y = 10;

// 1. const T* - pointer to const T (can't modify data, can change pointer)
const int* ptr1 = &x;
// *ptr1 = 42;  // ERROR: can't modify data
ptr1 = &y;     // OK: can change what pointer points to

// 2. T* const - const pointer to T (can't change pointer, can modify data)
int* const ptr2 = &x;
*ptr2 = 42;    // OK: can modify data
// ptr2 = &y;  // ERROR: can't change pointer

// 3. const T* const - const pointer to const T (can't change either)
const int* const ptr3 = &x;
// *ptr3 = 42;  // ERROR: can't modify data
// ptr3 = &y;   // ERROR: can't change pointer

// Reading right-to-left rule:
// const int* const ptr3 = &x;
// ^   ^      ^
// |   |      +-- const (so ptr3 is const)
// |   +--------- int (data type)
// +------------- const (so data is const)

// Reading: ptr3 is a const pointer to const int
```

**Practical usage patterns:**

```cpp
// GOOD: const T* for functions that promise not to modify
void display(const int* value) {
    if (value) {
        std::cout << *value << std::endl;
    }
}

// GOOD: T* const for objects that own data
class Buffer {
private:
    int* const data_;  // Pointer can't change, but data can be modified
    int capacity_;

public:
    Buffer(int cap) : capacity_(cap) {
        data_ = new int[cap];
    }

    ~Buffer() {
        delete[] data_;
    }

    void write(int offset, int value) {
        if (offset < capacity_) {
            data_[offset] = value;
        }
    }
};

// GOOD: Return const pointer for internal data
class Registry {
private:
    std::map<int, std::string> entries_;

public:
    const std::string* find(int id) const {
        auto it = entries_.find(id);
        return it != entries_.end() ? &it->second : nullptr;
    }
};

// Usage of Registry
Registry reg;
const std::string* result = reg.find(42);
if (result) {
    std::cout << *result << std::endl;
}
```

**Pointer const in function signatures:**

```cpp
// GOOD: Const pointer to const data - safest
void inspect(const int* const ptr) {
    if (ptr) {
        std::cout << *ptr << std::endl;
    }
}

// GOOD: Const pointer to mutable data (less common)
void increment_at(int* const ptr) {
    if (ptr) {
        (*ptr)++;
    }
}

// GOOD: Non-const pointer to const data
void display(const int* ptr) {
    // Can iterate through array without modifying data
    for (int i = 0; i < 10; ++i) {
        std::cout << ptr[i] << std::endl;
    }
}

// GOOD: Non-const pointer to mutable data
void modify(int* ptr) {
    if (ptr) {
        *ptr = 42;
    }
}
```

### const_cast usage

**const_cast removes const - use only in justified cases.**

```cpp
// ACCEPTABLE: C library with non-const char* parameter
std::string name = "Alice";
// C function signature: int strlen_c(char* str);
// We know strlen doesn't modify, but signature isn't const-correct
int len = strlen_c(const_cast<char*>(name.c_str()));

// ACCEPTABLE: Implementing const/non-const pair (rare)
class Container {
private:
    std::vector<int> data_;

    // Common implementation
    int* find_impl(int value) {
        for (auto& item : data_) {
            if (item == value) return &item;
        }
        return nullptr;
    }

public:
    // Non-const version
    int* find(int value) {
        return find_impl(value);
    }

    // Const version delegates to non-const version
    const int* find(int value) const {
        return const_cast<Container*>(this)->find_impl(value);
    }
};

// BAD: Using const_cast to silence warnings (indicates design problem)
class Logger {
    int internal_state_;  // Should be mutable instead

public:
    void log(const std::string& msg) {
        // BAD: Modifying in const function without mutable
        const_cast<Logger*>(this)->internal_state_++;
    }
};

// GOOD: Use mutable instead
class BetterLogger {
    mutable int call_count_ = 0;

public:
    void log(const std::string& msg) const {
        call_count_++;  // OK: mutable allows modification
    }
};

// VERY BAD: Casting away const from immutable data
const int constant = 42;
int* ptr = const_cast<int*>(&constant);
// *ptr = 100;  // UNDEFINED BEHAVIOR - modifying const memory
```

**When you must use const_cast (priority order):**

1. **C interop only:** C library with non-const parameter that doesn't modify
2. **Documented violation:** Add comment explaining why const correctness is broken
3. **Last resort:** After considering other designs (mutable, separate functions, etc.)

```cpp
// GOOD: Document the reason
void initialize_from_c_lib(const std::vector<int>& data) {
    // c_lib_init requires non-const pointer but doesn't modify buffer
    // No alternative - const_cast needed for C interop
    c_lib_init(const_cast<int*>(data.data()), data.size());
}
```

### Const correctness decision framework

| Scenario | Use | Rationale |
|----------|-----|-----------|
| **Variable never changes** | `const int x = 5;` | Compiler prevents modification |
| **Function parameter, read-only** | `const std::vector<int>& items` | Zero-copy, prevents modification |
| **Function parameter, simple type** | `int value` (no const needed) | By value already safe |
| **Member function doesn't modify state** | `int get() const { ... }` | Enables use with const objects |
| **Need to modify in const function** | `mutable int counter_` | mutable member for non-essential state |
| **Pointer to const data** | `const int* ptr` | Can change pointer, not data |
| **Const pointer to data** | `int* const ptr` | Can change data, not pointer |
| **Returning reference to member** | `const T& member() const` | Only if lifetime guaranteed |
| **Return optional instead** | `std::optional<T> value()` | Safer than const reference |
| **Must remove const for C interop** | `const_cast<...>()` | Last resort, document why |

**Key principle:** const is a compile-time safety net. When const seems restrictive, it's usually revealing a design problem that should be fixed (using mutable, returning optional, or restructuring).

## Ownership and lifetimes

**Ownership** defines who is responsible for releasing a resource. Clear ownership patterns prevent memory leaks, dangling references, and use-after-free bugs. Modern C++ (C++11+) provides move semantics to make ownership transfer explicit and efficient.

### Ownership semantics

**Core principle:** Every resource has one owner responsible for cleanup.

```cpp
// GOOD: Explicit ownership with unique_ptr
class Document {
private:
    std::unique_ptr<FileBuffer> buffer_;  // This object owns the buffer

public:
    Document() : buffer_(std::make_unique<FileBuffer>()) { }
    ~Document() {
        // Destructor automatically deletes buffer_ via unique_ptr
    }
};

// Clear: The Document owns the FileBuffer lifecycle
Document doc;
// buffer_ created and managed automatically
// buffer_ deleted when doc destroyed

// BAD: Ambiguous ownership (raw pointer)
class DataProcessor {
private:
    Data* data_;  // Who owns this? Unclear!

public:
    DataProcessor(Data* d) : data_(d) { }
    ~DataProcessor() {
        delete data_;  // Assumes we own it - caller might have same assumption!
    }
};

// Caller code:
Data* my_data = new Data();
DataProcessor proc(my_data);
// Is my_data automatically deleted? Caller might think they own it
```

**Ownership models:**

```cpp
// 1. SOLE OWNERSHIP - One owner
std::unique_ptr<Widget> widget = std::make_unique<Widget>();
// Only this code path owns widget. No copies possible.

// 2. SHARED OWNERSHIP - Multiple owners via reference counting
std::shared_ptr<Resource> res1 = std::make_shared<Resource>();
std::shared_ptr<Resource> res2 = res1;  // Both own it
// Deleted when last shared_ptr is destroyed

// 3. BORROWED REFERENCE - No ownership
void process(const Widget& widget) {
    // Don't own widget. Caller is responsible for lifetime.
}

// 4. OPTIONAL BORROWED REFERENCE - May or may not exist
void find_widget(const std::string& id, const Widget** out) {
    // out receives pointer if found, nullptr if not
    // Caller doesn't own the Widget
}

// 5. C PATTERN - Explicit ownership via function pairs
Widget* create_widget() {
    return new Widget();  // Caller must call destroy_widget()
}

void destroy_widget(Widget* w) {
    delete w;
}
```

### Move semantics (C++11+)

**Move semantics** enable efficient transfer of ownership and resources without expensive copies. Rvalue references (`&&`) identify temporary objects that can be "moved from".

**Lvalue vs Rvalue:**

```cpp
// Lvalue: Something with an identity (has an address)
int x = 5;              // x is lvalue
int& ref = x;           // ref binds to lvalue

// Rvalue: Temporary with no address after use
int get_number() {
    return 5;           // Temporary, doesn't need copy
}

int y = get_number();   // get_number() is rvalue

// Rvalue reference (&& ) binds to rvalues
int&& rref = get_number();  // Can bind to temporary
// int&& bad = x;  // ERROR: x is lvalue, not rvalue
```

**Move constructors - transfer ownership:**

```cpp
// GOOD: Move constructor transfers ownership without copying
class String {
private:
    char* data_;
    int size_;

public:
    // Copy constructor - expensive deep copy
    String(const String& other) : size_(other.size_) {
        data_ = new char[size_ + 1];
        std::strcpy(data_, other.data_);
    }

    // Move constructor - cheap transfer
    String(String&& other) noexcept
        : data_(other.data_), size_(other.size_) {
        // Leave other in valid but empty state
        other.data_ = nullptr;
        other.size_ = 0;
    }

    ~String() {
        delete[] data_;
    }
};

// Usage
String s1 = "hello";                    // Constructs string
String s2 = std::move(s1);              // Move constructor - efficient!
// s1 is now valid but empty
// s2 owns the data

// Without move semantics, this would copy large buffer twice
std::vector<String> strings;
String large_string = "much data";
strings.push_back(std::move(large_string));  // Move, don't copy
```

**std::move - cast to rvalue reference:**

```cpp
// std::move indicates "I'm done with this object, you can take its resources"

// GOOD: Explicitly move expensive objects
std::vector<int> create_large_vector() {
    std::vector<int> result;
    result.reserve(1000000);
    // Fill result...
    return result;  // Move constructor called (not copy)
}

// If vector was important to preserve:
std::vector<int> processed;
std::vector<int> original;
processed = std::move(original);  // Transfer ownership
// original is now empty

// GOOD: Move in function parameters for sink parameters
void store_vector(std::vector<int>&& vec) {
    // Caller relinquishes ownership
    data_.push_back(std::move(vec));  // Take ownership of vec
}

// Usage
std::vector<int> temp;
// Fill temp...
store_vector(std::move(temp));  // temp is now empty

// BAD: Moving lvalues unnecessarily (confuses intent)
std::vector<int> important;
process(std::move(important));  // Dangerous - important now empty
important.push_back(42);        // Empty vector!
```

**Move assignment operator:**

```cpp
// GOOD: Complete move semantics
class Buffer {
private:
    uint8_t* data_;
    int capacity_;

public:
    // Copy assignment
    Buffer& operator=(const Buffer& other) {
        if (this != &other) {
            delete[] data_;
            capacity_ = other.capacity_;
            data_ = new uint8_t[capacity_];
            std::memcpy(data_, other.data_, capacity_);
        }
        return *this;
    }

    // Move assignment - transfer ownership
    Buffer& operator=(Buffer&& other) noexcept {
        if (this != &other) {
            delete[] data_;
            data_ = other.data_;
            capacity_ = other.capacity_;
            other.data_ = nullptr;
            other.capacity_ = 0;
        }
        return *this;
    }
};

// Usage
Buffer src(1000);
Buffer dst;
dst = std::move(src);  // Move assignment - efficient
// src is now empty, dst owns the data
```

**Return value optimization (RVO) vs move:**

```cpp
// Modern C++ compiler does RVO (Return Value Optimization)
// which is often better than move

std::vector<int> get_items() {
    std::vector<int> items;
    items.push_back(1);
    return items;  // Compiler performs RVO - no move needed!
    // Construction happens directly at call site
}

// If RVO not possible, move semantics handle it:
std::unique_ptr<Widget> create_widget(int type) {
    if (type == 1) {
        return std::make_unique<TypeA>();  // Different types
    } else {
        return std::make_unique<TypeB>();  // Use move
    }
}
```

### Transfer of ownership patterns

**Factory functions return ownership:**

```cpp
// GOOD: Caller owns returned object
std::unique_ptr<Parser> create_parser(const std::string& format) {
    if (format == "json") {
        return std::make_unique<JsonParser>();
    } else if (format == "xml") {
        return std::make_unique<XmlParser>();
    }
    throw std::invalid_argument("Unknown format");
}

// Usage - ownership explicit
auto parser = create_parser("json");  // parser owns the Parser object
// parser automatically deleted when it goes out of scope

// BAD: Raw pointer hides ownership
Parser* create_parser_bad(const std::string& format) {
    return new JsonParser();  // Caller must remember to delete!
}
```

**Sink parameters take ownership:**

```cpp
// GOOD: Sink parameter (takes ownership)
class MessageQueue {
private:
    std::vector<std::unique_ptr<Message>> messages_;

public:
    void enqueue(std::unique_ptr<Message> msg) {
        // Queue takes ownership of msg
        messages_.push_back(std::move(msg));
    }
};

// Usage makes ownership transfer explicit
auto msg = std::make_unique<Message>("hello");
queue.enqueue(std::move(msg));
// msg is now nullptr, queue owns the message

// BAD: Ambiguous parameter (does callee own it?)
void enqueue_bad(Message* msg) {
    queue_.push_back(msg);  // Who owns msg now?
}
```

**Release patterns (converting unique_ptr to raw pointer):**

```cpp
// GOOD: Explicit release when needed
auto ptr = std::make_unique<Resource>();
void* opaque = ptr.release();  // Release ownership
// Now we're responsible for deleting opaque

// Less commonly, get pointer without releasing ownership:
Resource* borrowed = ptr.get();  // Borrow only, don't own
// borrowed is valid only while ptr exists

// GOOD: Reset to take ownership
std::unique_ptr<Resource> old_res = std::make_unique<Resource>();
old_res.reset();  // Deletes old resource
old_res = std::make_unique<Resource>();  // Can reassign
```

**Shared ownership patterns:**

```cpp
// GOOD: Multiple owners via shared_ptr
class DataCache {
private:
    std::map<int, std::shared_ptr<CachedData>> cache_;

public:
    std::shared_ptr<CachedData> get_or_create(int id) {
        auto it = cache_.find(id);
        if (it != cache_.end()) {
            return it->second;  // Return shared ownership
        }

        auto data = std::make_shared<CachedData>(id);
        cache_[id] = data;
        return data;
    }
};

// Usage
{
    auto data1 = cache.get_or_create(1);
    {
        auto data2 = data1;  // Shared ownership
        // use_count() would be 3 (cache + data1 + data2)
    }
    // data2 destroyed, use_count() is 2
}
// data1 destroyed, cache still holds copy
```

### Dangling reference prevention

**Dangling reference:** A reference to an object that has been deleted.

```cpp
// BAD: Dangling reference
const int& get_value() {
    int x = 42;
    return x;  // ERROR: x destroyed at function return
}

int main() {
    const int& value = get_value();
    std::cout << value << std::endl;  // UNDEFINED BEHAVIOR
}

// GOOD: Return by value instead
int get_value() {
    return 42;  // Safe - returns value
}

// GOOD: Return reference to object that outlives function
class Registry {
private:
    std::map<int, int> data_;

public:
    const int& lookup(int key) const {
        static const int NOT_FOUND = -1;
        auto it = data_.find(key);
        return it != data_.end() ? it->second : NOT_FOUND;
    }
};

// GOOD: Return optional instead of reference
std::optional<int> find_user_id(const std::string& name) {
    auto it = users_.find(name);
    if (it != users_.end()) {
        return it->second.id;
    }
    return std::nullopt;
}
```

**Iterator invalidation (a form of dangling):**

```cpp
// BAD: Dangling iterator after vector grows
std::vector<int> vec = {1, 2, 3};
auto iter = vec.begin();
vec.push_back(4);  // May reallocate - iter is now dangling!
std::cout << *iter << std::endl;  // UNDEFINED BEHAVIOR

// GOOD: Don't hold iterators across modifying operations
std::vector<int> vec = {1, 2, 3};
{
    auto iter = vec.begin();
    std::cout << *iter << std::endl;  // Use immediately
}
// Don't use iter after vec.push_back()

// GOOD: Use indices for stable references
std::vector<int> vec = {1, 2, 3};
int first_index = 0;
vec.push_back(4);  // Safe - index still valid
std::cout << vec[first_index] << std::endl;  // OK

// GOOD: Clear/rebuild vectors safely
std::vector<int> items;
for (int i = 0; i < 10; ++i) {
    items.push_back(i);  // Reserve prevents reallocation
}
items.reserve(100);  // Pre-allocate space
for (int i = 10; i < 100; ++i) {
    items.push_back(i);  // No reallocation needed
}
```

**Circular references with shared_ptr:**

```cpp
// BAD: Memory leak with circular references
class Node {
public:
    std::shared_ptr<Node> next;
    std::shared_ptr<Node> prev;  // Circular!
};

auto node1 = std::make_shared<Node>();
auto node2 = std::make_shared<Node>();
node1->next = node2;
node2->prev = node1;  // Circular reference - memory leak!
// Neither can be deleted because each holds a reference to the other

// GOOD: Break cycle with weak_ptr
class Node {
public:
    std::shared_ptr<Node> next;
    std::weak_ptr<Node> prev;  // Non-owning reference
};

auto node1 = std::make_shared<Node>();
auto node2 = std::make_shared<Node>();
node1->next = node2;
node2->prev = node1;  // Not circular - node1 can be deleted
// When node1 deleted, prev becomes dangling (checked via lock())

// Usage with weak_ptr
if (auto parent = node->prev.lock()) {
    // parent is valid, use it
} else {
    // parent was deleted
}
```

### Lifetime management best practices

**Object lifetime chart:**

```
Stack objects: Created at declaration, destroyed at scope exit
    int x = 5;
    { x lives here }
    // x destroyed here

Dynamic objects: Created by new/make_unique/make_shared, destroyed by delete/unique_ptr/shared_ptr
    auto ptr = std::make_unique<Widget>();
    // ptr->lifetime managed automatically

Function parameters: Live only during function call
    void process(const Widget& w) {
        // w lives here
    }
    // w out of scope

Member variables: Live as long as containing object
    class Container {
        std::unique_ptr<Data> data_;  // Lives until Container destroyed
    };
```

**RAII (Resource Acquisition Is Initialization) ensures correct lifetimes:**

```cpp
// GOOD: RAII guarantees cleanup
void process_file(const std::string& filename) {
    // Open file (resource acquired)
    std::ifstream file(filename);
    if (!file) throw std::runtime_error("failed to open");

    // Use file...
    process_lines(file);

    // file.close() called automatically at function end
    // Even if exception thrown, file closed via destructor
}

// Contrast with C (error-prone):
FILE* file = fopen(filename, "r");
if (!file) return;
process_lines(file);
if (error) return;  // LEAK! fclose not called
fclose(file);

// GOOD: Scope guards for temporary lifetimes
{
    std::lock_guard<std::mutex> lock(mutex_);
    shared_data_ = new_value;  // Critical section
}  // Lock released here, other threads can proceed
```

**Temporary lifetimes (beware of references):**

```cpp
// BAD: Reference to temporary
const std::string& get_message() {
    return std::string("hello");  // Temporary - destroyed at return!
}

std::string msg = get_message();  // Dangling reference!

// GOOD: Return by value
std::string get_message() {
    return std::string("hello");  // Copied/moved to caller
}

// GOOD: Accept temporary directly (std::string_view)
void display(std::string_view msg) {
    std::cout << msg << std::endl;
}

display("hello");  // Temporary lives for function duration
```

**Function-local static lifetime (careful with threading):**

```cpp
// GOOD: Singleton-like pattern (C++11 thread-safe)
Logger& get_logger() {
    static Logger logger;  // Created once, destroyed at program exit
    return logger;
}

// Not thread-safe in C++03, but guaranteed thread-safe in C++11+

// BAD: Non-thread-safe manual singleton
class Config {
private:
    static Config* instance_;
public:
    static Config& get_instance() {
        if (!instance_) {
            instance_ = new Config();  // Not thread-safe!
        }
        return *instance_;
    }
};
```

### Ownership and lifetimes decision framework

| Scenario | Use | Rationale |
|----------|-----|-----------|
| **Single owner, exclusive access** | `unique_ptr<T>` | Default choice, move-only semantics |
| **Multiple owners** | `shared_ptr<T>` | Reference counting manages cleanup |
| **Non-owning reference** | `const T&` or raw pointer | Just observe, don't manage lifetime |
| **Optional non-owning reference** | `weak_ptr<T>` (with lock()) | Break circular references, detect deletion |
| **Return from function** | Return by value or `unique_ptr` | Caller receives ownership |
| **Function parameter takes ownership** | `unique_ptr<T>` parameter | Make ownership transfer explicit |
| **Function parameter reads value** | `const T&` or pass by value | Caller retains ownership |
| **Temporary object** | Rvalue reference `&&` with move | Efficient transfer of temporary |
| **C library returns malloc'd memory** | `unique_ptr<T, decltype(&free)>` | Wrap in RAII |
| **Can't use smart pointers (legacy code)** | Document ownership clearly | Prevent leaks and use-after-free |

**Key principle:** Ownership must be explicit and unambiguous. When reading code, you should immediately understand who is responsible for cleanup. Use smart pointers to make ownership mechanical (automatic) rather than relying on developer discipline (manual).

## Standard library and containers

Modern C++ provides powerful standard library containers and algorithms. This section covers container selection, string handling, and common algorithms. For comprehensive reference material, see [cpp-standard-library.md](./cpp-standard-library.md).

### Container selection

The Standard Template Library (STL) provides containers with different performance characteristics. Choose based on access patterns and operations:

| Container | Use When | Performance | Example |
|-----------|----------|-------------|---------|
| `std::vector<T>` | Need dynamic array, frequent random access or append | O(1) append (amortized), O(1) random access | `std::vector<int> numbers = {1, 2, 3}; numbers.push_back(4);` |
| `std::array<T, N>` | Fixed-size array known at compile time | O(1) random access, no heap allocation | `std::array<int, 10> fixed_size;` |
| `std::deque<T>` | Frequent insertions/deletions at both ends | O(1) front/back operations, O(1) random access | Double-ended queue for task scheduling |
| `std::list<T>` | Frequent insertions/deletions in middle | O(1) insert/erase if iterator known | `std::list<Task> pending; pending.erase(iter);` |
| `std::map<K, V>` | Ordered key-value pairs, iteration in order | O(log n) lookup, maintains sort order | `std::map<std::string, int> scores;` |
| `std::set<T>` | Unique values, ordered, needs fast lookup | O(log n) insertion/lookup, no duplicates | `std::set<int> unique_ids;` |
| `std::unordered_map<K, V>` | Fast key-value lookup, order doesn't matter | O(1) average lookup, no guaranteed order | Hash table for fast cache lookups |
| `std::unordered_set<T>` | Fast membership testing, order doesn't matter | O(1) average contains check | `if (seen.count(value)) { ... }` |

**Decision flow:**
1. Start with `std::vector` - it's the right choice 80% of the time
2. Need different performance? Check what operations dominate your code
3. Avoid `std::list` unless you have explicit iterator-based insertions (not just loop-based)
4. Unordered variants are faster only when you need hash-based lookup, not just iteration

**Performance pitfalls:**
```cpp
// BAD: Frequent insertions at front of vector
std::vector<int> data;
for (int val : incoming) {
    data.insert(data.begin(), val);  // O(n) per insertion!
}

// GOOD: Use deque for front insertions
std::deque<int> data;
for (int val : incoming) {
    data.push_front(val);  // O(1)
}

// BAD: Erase elements in vector during iteration
std::vector<int> nums = {1, 2, 3, 4, 5};
for (int i = 0; i < nums.size(); ++i) {
    if (nums[i] % 2 == 0) nums.erase(nums.begin() + i);  // Invalidates iterators!
}

// GOOD: Erase-remove idiom or collect to erase
auto it = std::remove_if(nums.begin(), nums.end(), [](int x) { return x % 2 == 0; });
nums.erase(it, nums.end());
```

### String handling: std::string vs std::string_view

C++17 introduces `std::string_view` - a non-owning reference to string data. Choose based on ownership:

```cpp
// std::string - owns the data
std::string read_file(const std::string& filename) {
    std::ifstream file(filename);
    std::string contents;
    std::string line;
    while (std::getline(file, line)) {
        contents += line + "\n";
    }
    return contents;  // Caller gets ownership
}

// std::string_view - borrows a reference (C++17)
void process_data(std::string_view data) {
    // Efficient - no copy needed
    // But data must outlive this function call
    std::cout << data << std::endl;
}

// GOOD: Pass string_view for read-only function parameters
void display(std::string_view message) {
    std::cout << message << std::endl;
}

display("Hello");                              // No temporary created
display(std::string("Hello"));                 // Temporary, still works
display(owned_string);                         // Borrows from owned_string
std::string_view partial = owned_string.substr(0, 5);  // No copy!

// BAD: String view to temporary - DANGLING REFERENCE
std::string_view bad_view() {
    return std::string("temporary");  // Returns view to destroyed string!
}

// BAD: Storing string_view when string might be reassigned
class DataContainer {
    std::string data_;
    std::string_view view_;  // DANGEROUS if data_ might reallocate
public:
    void set_data(const std::string& d) {
        data_ = d;
        view_ = data_;  // OK, but view_ invalid if data_ reallocates
    }
};

// GOOD: string_view for parameters, std::string for storage
class DataContainer {
    std::string data_;
public:
    void set_data(std::string_view d) {
        data_ = std::string(d);  // Convert to owned string
    }

    std::string_view get_data() const {
        return data_;  // Safe - data_ won't change during return
    }
};
```

**String handling guidelines:**
- Use `std::string` when you own the data (members, return values)
- Use `std::string_view` for read-only function parameters (avoids copies)
- Use `std::string_view` to represent substrings without copying
- Never store `std::string_view` as member variable unless you control lifetime of referenced data
- Use `std::string(view)` to convert view to owned string when needed

### Algorithms and iterators

C++ STL algorithms operate on iterator ranges. Common patterns:

```cpp
#include <algorithm>
#include <numeric>

std::vector<int> data = {3, 1, 4, 1, 5, 9, 2, 6};

// std::find - locate first matching element
auto it = std::find(data.begin(), data.end(), 4);
if (it != data.end()) {
    std::cout << "Found at position " << std::distance(data.begin(), it) << std::endl;
}

// std::sort - sort in place
std::sort(data.begin(), data.end());
// data = {1, 1, 2, 3, 4, 5, 6, 9}

// std::sort with custom comparator
std::sort(data.begin(), data.end(), std::greater<int>());  // Descending
// data = {9, 6, 5, 4, 3, 2, 1, 1}

// std::transform - apply function to each element
std::vector<int> doubled;
std::transform(data.begin(), data.end(), std::back_inserter(doubled),
               [](int x) { return x * 2; });
// doubled = {18, 12, 10, 8, 6, 4, 2, 2}

// std::accumulate - sum/fold operation
int sum = std::accumulate(data.begin(), data.end(), 0);
// sum = 27

// std::remove_if + erase - filter elements
data.erase(std::remove_if(data.begin(), data.end(),
                          [](int x) { return x < 3; }),
           data.end());
// data = {9, 6, 5, 4, 3}

// std::find_if - find first matching condition
auto large_it = std::find_if(data.begin(), data.end(),
                             [](int x) { return x > 5; });

// std::all_of, std::any_of, std::none_of - predicates
bool all_positive = std::all_of(data.begin(), data.end(),
                                 [](int x) { return x > 0; });

// std::count_if - count matching elements
int large_count = std::count_if(data.begin(), data.end(),
                                [](int x) { return x > 5; });
```

**Iterator invalidation (container-specific):**

```cpp
std::vector<int> vec = {1, 2, 3, 4, 5};

// vector - insert/erase/push_back invalidate iterators after affected position
auto it = vec.begin();
vec.push_back(6);          // May reallocate - all iterators invalid!
// DON'T use it after this

// deque - push_back/push_front don't invalidate iterators (unless reallocate)
std::deque<int> deq = {1, 2, 3, 4, 5};
auto deq_it = deq.begin();
deq.push_back(6);         // Doesn't invalidate deq_it

// list - insert/erase only invalidate affected iterators
std::list<int> lst = {1, 2, 3, 4, 5};
auto list_it = std::next(lst.begin());
lst.erase(list_it);       // Only list_it invalidated, not others

// map/set - insert/erase only invalidates iterator to erased element
std::map<int, int> m = {{1, 'a'}, {2, 'b'}, {3, 'c'}};
auto map_it = m.find(2);
m.insert({4, 'd'});       // Doesn't invalidate map_it
m.erase(map_it);          // Invalidates only map_it
```

### Smart pointers recap

For detailed ownership patterns, see the [Memory management](#memory-management) section. Quick reference:

```cpp
// unique_ptr - sole ownership
std::unique_ptr<Widget> widget = std::make_unique<Widget>();
// Only this code path owns widget. No copies. Move only.

// shared_ptr - shared ownership
std::shared_ptr<Resource> resource = std::make_shared<Resource>();
std::shared_ptr<Resource> copy = resource;  // Both own it
// Deleted when last shared_ptr destroyed

// weak_ptr - non-owning reference (break circular references)
std::weak_ptr<Node> parent_ref = shared_parent;  // Doesn't extend lifetime
if (auto parent = parent_ref.lock()) {  // Check if still alive
    parent->do_something();
}
```

Use `unique_ptr` by default. Only use `shared_ptr` when multiple owners genuinely needed.

### Optional and expected error handling

For expected failures (not exceptional conditions), use value types:

```cpp
#include <optional>
#include <variant>

// std::optional<T> - value may or may not exist (C++17)
std::optional<int> parse_int(const std::string& str) {
    try {
        return std::stoi(str);
    } catch (...) {
        return std::nullopt;  // No value
    }
}

// Usage
if (auto value = parse_int("42")) {
    std::cout << "Parsed: " << *value << std::endl;
} else {
    std::cout << "Parse failed" << std::endl;
}

// std::expected<T, E> for value + error (C++23, or boost/custom)
// Returns either a value or an error code/message
class Result {
    std::variant<std::string, std::string> data_or_error_;
    bool is_error_;
};

// For now, use std::optional for failures and exceptions for exceptional conditions
// Link to [Error handling](#error-handling) section for detailed guidance
```

For comprehensive reference material on containers, algorithms, and STL utilities, see [cpp-standard-library.md](./cpp-standard-library.md).

## Performance patterns

Performance optimization is a discipline: measure first, understand bottlenecks, apply targeted fixes. This section covers profiling methodology, memory layout optimization, and move semantics for efficiency.

### When to optimize: The profiling-first framework

**The cardinal rule:** Profile first, measure always, optimize last.

Premature optimization is the source of unreadable code and wasted engineering time. Follow this discipline:

1. **Establish baseline:** Measure current performance with real-world data
2. **Profile the hot path:** Use profiling tools to find where time/memory is actually spent (usually not where you think)
3. **Measure before and after:** Quantify the improvement of any optimization
4. **Avoid "intuitive" optimizations:** Your intuition about performance is usually wrong

```cpp
// WRONG: "Obviously we need to pre-allocate for efficiency"
std::vector<Item> items;
items.reserve(1000000);  // If you don't know the actual size, this wastes memory
for (auto item : get_items()) {
    items.push_back(item);  // Might only add 100 items anyway
}

// RIGHT: Measure first. If profiling shows allocation is bottleneck, then:
std::vector<Item> items;
if (size_t expected = estimate_item_count()) {
    items.reserve(expected);
}
for (auto item : get_items()) {
    items.push_back(item);
}
```

**When to optimize:**
- After profiling identifies a bottleneck
- When measurements show > 10% improvement possible
- When you understand why the optimization helps
- Never on speculation alone

**Never optimize:**
- Code that runs once per program lifetime
- Code that takes < 1% of execution time
- Without before/after measurements
- If it makes code significantly harder to understand

### Profiling tools

Different tools answer different questions. Choose based on your bottleneck:

**perf (Linux) - CPU time and cache misses:**
```bash
# Record profile of a program
perf record ./your_program

# Analyze and show hot functions
perf report

# Generate flame graph for visualization
perf record -F 99 ./your_program
perf script > out.perf
# (Use FlameGraph tools to generate SVG)
```

**gprof - Function call timing (simple, limited):**
```bash
# Compile with profiling support
g++ -pg -O2 your_code.cpp -o your_program

# Run program
./your_program

# Generate profile report
gprof ./your_program gmon.out

# Shows: function call counts, cumulative time, call graph
```

**Valgrind cachegrind - Cache behavior:**
```bash
# Profile cache misses and branch prediction
valgrind --tool=cachegrind ./your_program

# Generate visualization
cg_annotate cachegrind.out.* | head -50
```

**Memory profiling with Valgrind:**
```bash
# Detect memory leaks and allocation patterns
valgrind --leak-check=full ./your_program

# Massif tool shows heap memory over time
valgrind --tool=massif ./your_program
ms_print massif.out.*
```

**Choosing a tool:**
- **Need CPU hotspots?** -> Use `perf` on Linux (most detailed)
- **Need call graph?** -> Use `gprof` (simpler but less accurate)
- **Need cache analysis?** -> Use `perf` with cache event counting
- **Need cache visualization?** -> Use `valgrind cachegrind`
- **Need memory profile?** -> Use `valgrind massif`

### Memory layout and cache efficiency

Modern CPUs are built around caching. Accessing memory that's in cache is ~100x faster than main memory. Structure layout matters.

**Cache lines and struct packing:**

```cpp
// BAD: Poor memory layout
struct UserData {
    char name[64];      // Accessed frequently
    int user_id;        // Accessed frequently
    bool is_admin;      // Accessed rarely
    double created_at;  // Accessed rarely
    std::vector<int> tags;  // Pointer to dynamic data
};
// Cache misses when accessing frequently-used fields scattered across cache lines

// GOOD: Organize by access frequency
struct UserData {
    // Hot fields (accessed frequently) together
    int user_id;
    char name[64];
    bool is_admin;
    // Cold fields (accessed rarely) separate
    double created_at;
    std::vector<int> tags;
};
// Hot fields fit in fewer cache lines

// GOOD: Use alignas for alignment-sensitive code
struct CacheLine {
    alignas(64) int counter;  // 64-byte alignment matches typical L1 cache line
};

// BAD: False sharing - different cores accessing same cache line
struct SharedData {
    std::atomic<int> counter1;  // Core 1 modifies this
    std::atomic<int> counter2;  // Core 2 modifies this - SAME CACHE LINE!
};
// Cache line bounces between cores - performance degrades

// GOOD: Separate hot data with padding
struct SharedData {
    std::atomic<int> counter1;
    char padding[56];  // 64-byte cache line alignment
    std::atomic<int> counter2;
};
```

**Access pattern optimization:**

```cpp
// BAD: Strided access (jumping through memory)
std::vector<std::vector<int>> matrix(1000, std::vector<int>(1000));
int sum = 0;
for (int j = 0; j < 1000; ++j) {
    for (int i = 0; i < 1000; ++i) {
        sum += matrix[i][j];  // Column-major access - cache misses!
    }
}

// GOOD: Sequential access
int sum = 0;
for (int i = 0; i < 1000; ++i) {
    for (int j = 0; j < 1000; ++j) {
        sum += matrix[i][j];  // Row-major access - cache hits!
    }
}
```

### Move semantics for performance

Move semantics avoid expensive copies. Use them when transferring ownership.

```cpp
// Move constructor - transfers ownership without copying
class DataBuffer {
    std::vector<char> buffer_;
public:
    DataBuffer(std::vector<char>&& data) : buffer_(std::move(data)) {
        // Takes ownership, no copy
    }
};

// GOOD: Move construction (zero copy)
std::vector<char> data = read_large_file("bigfile.bin");
DataBuffer buf(std::move(data));  // Moves, doesn't copy

// BAD: Unnecessary copy (data still in scope)
std::vector<char> data = read_large_file("bigfile.bin");
DataBuffer buf(data);  // Copies all bytes!

// RVO - compiler optimization (return value optimization)
std::vector<int> create_result() {
    std::vector<int> result = expensive_calculation();
    return result;  // Compiler elides copy - returned directly to caller
}

// NRVO - named return value optimization
std::vector<int> build_array() {
    std::vector<int> output;
    output.push_back(1);
    output.push_back(2);
    return output;  // Compiler may elide copy even with named variable
}

// GOOD: Let compiler optimize returns - don't try to force move
std::vector<int> get_values() {
    return std::vector<int>{1, 2, 3};  // Compiler applies RVO
}

// Move in loops (swap approach for update-in-place)
class Pipeline {
    std::vector<Task> queue_;
public:
    void process() {
        std::vector<Task> new_queue;
        for (auto& task : queue_) {
            if (task.should_keep()) {
                new_queue.push_back(std::move(task));  // Move, not copy
            }
        }
        queue_ = std::move(new_queue);  // Swap ownership
    }
};
```

**Move semantics guidelines:**
- Use `std::move()` when transferring ownership of expensive objects
- Prefer `std::move()` in constructors, assignment operators, and move-returning functions
- Don't `std::move()` primitives (int, double) - overhead isn't worth it
- Let compiler apply RVO/NRVO - don't force moves that inhibit optimization

### Common performance mistakes

**Mistake 1: Unnecessary copies**

```cpp
// BAD: Copy-and-modify pattern
std::string format_name(const std::string& first, const std::string& last) {
    std::string result = first;  // Copy
    result += " ";
    result += last;              // Copy again during concatenation
    return result;               // Copy on return
}

// GOOD: Build in place
std::string format_name(std::string_view first, std::string_view last) {
    std::string result;
    result.reserve(first.size() + last.size() + 1);
    result += first;  // Append without extra copy
    result += " ";
    result += last;
    return result;    // RVO applies
}
```

**Mistake 2: Inefficient algorithms**

```cpp
// BAD: O(n^2) when better exists
std::vector<int> data = get_data();
std::vector<int> unique_values;
for (int val : data) {
    if (std::find(unique_values.begin(), unique_values.end(), val) == unique_values.end()) {
        unique_values.push_back(val);  // Linear search in vector - O(n^2)!
    }
}

// GOOD: O(n log n) with set
std::set<int> unique_set(data.begin(), data.end());
std::vector<int> unique_values(unique_set.begin(), unique_set.end());

// Or use unordered_set for O(n) average
std::unordered_set<int> unique_set(data.begin(), data.end());
```

**Mistake 3: Premature optimization**

```cpp
// WRONG: Optimizing single-use initialization
class Settings {
    int value = 0;
public:
    void init() {
        // Pre-computed lookup table for single init call - unnecessary complexity
        static const int lookup[] = {10, 20, 30};
        value = lookup[0];  // "Optimization" with no measurable benefit
    }
};

// RIGHT: Use clear, simple code
class Settings {
    int value = 0;
public:
    void init() {
        value = 10;  // Obvious, single copy, no performance impact
    }
};

// Only optimize after profiling shows this is a bottleneck
```

**Performance mistake checklist:**
- Did you profile before optimizing? (No -> stop)
- Did you measure improvement? (No -> revert)
- Is the code now harder to understand? (Yes -> reconsider)
- Is this the hottest bottleneck? (No -> optimize something else)

## Testing strategies

Testing is the foundation of reliable C++ code. This section covers unit testing frameworks, test organization patterns, memory testing with sanitizers and Valgrind, error handling verification, and mocking strategies.

### Framework selection: GoogleTest and Catch2

Two frameworks dominate modern C++ testing. Choose based on your project needs:

**GoogleTest (Google's framework):**
- Comprehensive assertion library
- Built-in mocking with GoogleMock
- Best for large projects with complex dependencies
- Mature, widely adopted in industry
- Some verbosity in setup

```cpp
#include <gtest/gtest.h>
#include <gmock/gmock.h>

class CalculatorTest : public ::testing::Test {
protected:
    Calculator calc;
};

TEST_F(CalculatorTest, AddPositiveNumbers) {
    EXPECT_EQ(calc.add(2, 3), 5);
    EXPECT_EQ(calc.add(0, 0), 0);
}

TEST_F(CalculatorTest, AddNegativeNumbers) {
    EXPECT_EQ(calc.add(-2, -3), -5);
    EXPECT_EQ(calc.add(5, -3), 2);
}
```

**Catch2 (header-only framework):**
- Minimal, elegant syntax
- Single header file inclusion
- No external dependencies
- Excellent documentation
- Good for small to medium projects

```cpp
#define CATCH_CONFIG_MAIN
#include <catch2/catch.hpp>

TEST_CASE("Addition", "[calculator]") {
    Calculator calc;

    REQUIRE(calc.add(2, 3) == 5);
    REQUIRE(calc.add(0, 0) == 0);
    REQUIRE(calc.add(-2, -3) == -5);
}

TEST_CASE("Subtraction", "[calculator]") {
    Calculator calc;

    REQUIRE(calc.subtract(5, 3) == 2);
    REQUIRE(calc.subtract(0, 0) == 0);
}
```

**Framework comparison:**

| Aspect | GoogleTest | Catch2 |
|--------|-----------|--------|
| Learning curve | Steeper | Gentle |
| Mocking support | Built-in (GoogleMock) | Third-party (Fakeit, etc.) |
| Dependencies | External | Header-only |
| Setup complexity | Moderate | Minimal |
| Assertion flexibility | Comprehensive | Expressive |

### Unit testing patterns: ARRANGE-ACT-ASSERT

Every test follows the same structure: set up state, perform action, verify result.

```cpp
TEST_F(FileReaderTest, ReadsValidJsonFile) {
    // ARRANGE: Set up test data
    std::string test_file = "/tmp/test.json";
    std::ofstream out(test_file);
    out << R"({"name": "Alice", "age": 30})";
    out.close();

    FileReader reader;

    // ACT: Perform the operation
    nlohmann::json data = reader.read_json(test_file);

    // ASSERT: Verify the result
    EXPECT_EQ(data["name"], "Alice");
    EXPECT_EQ(data["age"], 30);
}
```

**Test fixtures reduce repetition:**

```cpp
class DataProcessorTest : public ::testing::Test {
protected:
    DataProcessor processor;
    std::vector<int> sample_data = {1, 2, 3, 4, 5};

    void SetUp() override {
        // Called before each test
        processor.initialize();
    }

    void TearDown() override {
        // Called after each test - cleanup resources
        processor.cleanup();
    }
};

TEST_F(DataProcessorTest, ComputesSum) {
    int result = processor.sum(sample_data);
    EXPECT_EQ(result, 15);
}

TEST_F(DataProcessorTest, ComputesAverage) {
    double result = processor.average(sample_data);
    EXPECT_DOUBLE_EQ(result, 3.0);
}
```

### Testing memory management: Valgrind and sanitizers

Memory bugs are silent killers. Test for leaks and corruption every run.

**AddressSanitizer (ASan) - Detects memory errors at runtime:**

```bash
# Compile with ASan
clang++ -fsanitize=address -g -O1 your_program.cpp -o your_program

# Run program - ASan reports errors immediately
./your_program
# Output example: ERROR: AddressSanitizer: heap-buffer-overflow
```

**MemorySanitizer (MSan) - Detects use of uninitialized memory:**

```bash
# Compile with MSan
clang++ -fsanitize=memory -g -O1 your_program.cpp -o your_program

./your_program
# Reports uninitialized variable access
```

**ThreadSanitizer (TSan) - Detects data races in multithreaded code:**

```bash
# Compile with TSan
clang++ -fsanitize=thread -g -O1 your_program.cpp -o your_program

./your_program
# Reports concurrent access to same data without synchronization
```

**UndefinedBehaviorSanitizer (UBSan) - Detects undefined behavior:**

```bash
# Compile with UBSan
clang++ -fsanitize=undefined -g -O1 your_program.cpp -o your_program

./your_program
# Reports integer overflow, null dereference, etc.
```

**Valgrind - Comprehensive memory debugging:**

```bash
# Detect memory leaks
valgrind --leak-check=full --show-leak-kinds=all ./your_program

# Example output:
# ==12345== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
# ==12345== LEAK SUMMARY:
# ==12345==    definitely lost: 0 bytes in 0 blocks
# ==12345==    indirectly lost: 0 bytes in 0 blocks
```

**Integrating sanitizers in CI:**

```bash
# Test script that runs with all sanitizers
#!/bin/bash
set -e

echo "Building with AddressSanitizer..."
clang++ -fsanitize=address -g tests.cpp -o tests_asan
./tests_asan

echo "Building with MemorySanitizer..."
clang++ -fsanitize=memory -g tests.cpp -o tests_msan
./tests_msan

echo "Building with ThreadSanitizer..."
clang++ -fsanitize=thread -g tests.cpp -o tests_tsan
./tests_tsan

echo "Building with UndefinedBehaviorSanitizer..."
clang++ -fsanitize=undefined -g tests.cpp -o tests_ubsan
./tests_ubsan

echo "Running Valgrind..."
valgrind --leak-check=full ./tests_asan

echo "All memory tests passed!"
```

### Testing error handling: Exceptions and error codes

Test both success and failure paths.

**Testing exception handling:**

```cpp
TEST(DivisionTest, ThrowsOnZeroDivisor) {
    Calculator calc;

    // EXPECT_THROW: Verify exception is thrown
    EXPECT_THROW(calc.divide(10, 0), std::invalid_argument);

    // EXPECT_NO_THROW: Verify no exception
    EXPECT_NO_THROW(calc.divide(10, 2));
}

TEST(DivisionTest, ExceptionMessage) {
    Calculator calc;

    try {
        calc.divide(10, 0);
        FAIL() << "Expected std::invalid_argument";
    } catch (const std::invalid_argument& e) {
        EXPECT_THAT(e.what(), ::testing::HasSubstr("division by zero"));
    }
}
```

**Testing error codes:**

```cpp
TEST(FileOperationTest, ReturnErrorOnMissingFile) {
    FileHandler handler;

    auto result = handler.read_file("/nonexistent/path");

    // Verify error code, not exception
    EXPECT_FALSE(result);
    EXPECT_EQ(result.error(), ErrorCode::FileNotFound);
}

TEST(FileOperationTest, SucceedsWithValidFile) {
    FileHandler handler;

    auto result = handler.read_file("/tmp/test.txt");

    EXPECT_TRUE(result);
    EXPECT_EQ(result.value(), "file contents");
}
```

### Mocking and dependency injection

Use mocks to isolate components and test interfaces.

**GoogleMock for dependency injection:**

```cpp
// Define mock interface
class MockDatabase : public Database {
public:
    MOCK_METHOD(std::optional<User>, get_user, (int id), (override));
    MOCK_METHOD(bool, save_user, (const User& user), (override));
};

// Test service that depends on database
class UserServiceTest : public ::testing::Test {
protected:
    MockDatabase mock_db;
    UserService service{mock_db};
};

TEST_F(UserServiceTest, FetchesUserFromDatabase) {
    User expected_user{1, "Alice", "alice@example.com"};

    // Set expectation: mock_db.get_user(1) should return expected_user
    EXPECT_CALL(mock_db, get_user(1))
        .WillOnce(::testing::Return(expected_user));

    auto user = service.get_user(1);

    EXPECT_EQ(user.id, 1);
    EXPECT_EQ(user.name, "Alice");
}

TEST_F(UserServiceTest, HandlesUserNotFound) {
    // Set expectation: return empty optional
    EXPECT_CALL(mock_db, get_user(999))
        .WillOnce(::testing::Return(std::nullopt));

    auto user = service.get_user(999);

    EXPECT_FALSE(user);
}
```

**Dependency injection without mocks:**

```cpp
class DataProcessor {
    std::unique_ptr<DataSource> source_;
public:
    explicit DataProcessor(std::unique_ptr<DataSource> src)
        : source_(std::move(src)) {}

    void process() {
        auto data = source_->fetch();
        // Process data...
    }
};

// In tests, inject test implementation
class MockDataSource : public DataSource {
public:
    std::vector<int> fetch() override {
        return {1, 2, 3};  // Controlled test data
    }
};

TEST(DataProcessorTest, ProcessesTestData) {
    auto mock_source = std::make_unique<MockDataSource>();
    DataProcessor processor(std::move(mock_source));

    // Processor uses test data
    processor.process();
    // Assert results...
}
```

### Running tests in CI

Integrate testing into continuous integration pipelines:

```bash
# CMakeLists.txt example
cmake_minimum_required(VERSION 3.14)
project(MyProject)

# Enable testing
enable_testing()

# Add GoogleTest
include(FetchContent)
FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/main.zip
)
FetchContent_MakeAvailable(googletest)

# Add tests
add_executable(my_tests test.cpp)
target_link_libraries(my_tests gtest gtest_main)

# Register tests
add_test(NAME AllTests COMMAND my_tests)

# Run with sanitizers
if(ENABLE_SANITIZERS)
    target_compile_options(my_tests PRIVATE
        -fsanitize=address,undefined
        -g -O1
    )
    target_link_options(my_tests PRIVATE
        -fsanitize=address,undefined
    )
endif()
```

For comprehensive testing reference material, see [testing-cpp.md](./testing-cpp.md).

## Tools and libraries

Professional C++ development requires a mature toolchain for compilation, analysis, and runtime validation. This section covers compilers, build systems, static and dynamic analysis, standard libraries, and testing frameworks.

### Compilers: GCC, Clang, and MSVC

Choose your compiler based on platform needs and optimization priorities.

**GCC (GNU Compiler Collection):**
- Mature, stable, widely used on Linux
- Excellent C++ standards support
- Strong optimizer for production code
- Recommended version: GCC 11 or later
- Use flag: `-std=c++17` or `-std=c++20` for standards

**Clang (LLVM-based compiler):**
- Modern, modular architecture
- Superior diagnostics and error messages
- Better debug information
- Powers XCode on macOS
- Recommended version: Clang 14 or later
- Same flag conventions as GCC

**MSVC (Microsoft Visual C++):**
- Default for Windows development
- Excellent IDE integration
- Strong optimizer for Windows
- C++ standards support varies by version
- Use `/std:c++latest` or `/std:c++17` for standards

**Compiler selection guide:**
- Linux servers: GCC or Clang
- macOS development: Clang (XCode)
- Windows applications: MSVC
- Cross-platform: Clang (most portable diagnostics)

**Example compilation:**
```bash
# GCC with C++20 and warnings
g++ -std=c++20 -Wall -Wextra -Wpedantic main.cpp -o app

# Clang with Address Sanitizer
clang++ -std=c++20 -fsanitize=address -g main.cpp -o app

# MSVC with C++17
cl /std:c++17 /W4 main.cpp
```

### Build systems: CMake, Make, and Ninja

Modern projects use CMake for cross-platform consistency. Legacy projects may still use Make or Ninja for speed.

**CMake (recommended for modern projects):**
- Platform-independent build specification
- Generates platform-native build files (Unix Makefiles, Ninja, Visual Studio)
- Excellent package management with FetchContent
- Standard in most modern C++ projects
- Example: Configure, compile, test in one workflow

**Basic CMake workflow:**
```cmake
cmake_minimum_required(VERSION 3.20)
project(MyApp)

# Set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add executable
add_executable(myapp src/main.cpp src/utils.cpp)

# Link libraries
target_link_libraries(myapp PRIVATE somelib)

# Enable testing
enable_testing()
add_test(NAME unit_tests COMMAND myapp_tests)
```

**Make (legacy, still widely used):**
- Simple rule-based system
- Lightweight, no configuration needed
- Steep learning curve for complex projects
- Best for small projects or embedded systems

```makefile
CXX = g++
CXXFLAGS = -std=c++20 -Wall
LDFLAGS = -lm

app: main.o utils.o
	$(CXX) $(LDFLAGS) -o $@ $^

main.o: main.cpp
	$(CXX) $(CXXFLAGS) -c $<

utils.o: utils.cpp
	$(CXX) $(CXXFLAGS) -c $<

clean:
	rm -f *.o app
```

**Ninja (fast, minimal):**
- Faster incremental builds than Make
- Minimal language, optimized for speed
- Generated by CMake (not written by hand)
- Use CMake to generate Ninja files: `cmake -G Ninja`

### Static analysis: clang-tidy, cppcheck, and clang-format

Catch issues before runtime by analyzing code structure and style.

**clang-tidy (linting and bug detection):**
- Part of LLVM/Clang ecosystem
- Detects code smells, style violations, performance issues
- Enforces modern C++ idioms
- Integrates with most IDEs and CI systems

```bash
# Run clang-tidy on all source files
clang-tidy src/*.cpp -- -I./include

# Run specific checks only
clang-tidy src/main.cpp -checks=readability-*,performance-*

# Fix issues automatically (with caution)
clang-tidy src/main.cpp --fix

# Typical .clang-tidy config
Checks: '-*,readability-*,performance-*,modernize-*'
WarningsAsErrors: '*'
FormatStyle: file
```

**cppcheck (static analysis):**
- Independent static analyzer
- Detects logic errors, memory errors, undefined behavior
- No compilation required (preprocesses source directly)
- Lighter weight than clang-tidy

```bash
# Scan entire directory
cppcheck src/

# Enable all checks
cppcheck --enable=all src/

# Output results in various formats
cppcheck --output-file=report.txt src/
```

**clang-format (code formatting):**
- Automatic code style enforcement
- Prevents style debates in code review
- Integrates into build systems and pre-commit hooks
- Consistent formatting across team

```bash
# Format a single file
clang-format -i src/main.cpp

# Check formatting without modifying
clang-format --output-replacements-xml src/main.cpp

# Format entire project
find src -name "*.cpp" -o -name "*.hpp" | xargs clang-format -i
```

### Dynamic analysis: Valgrind and sanitizers

Runtime analysis catches errors that static analysis misses.

**Valgrind (comprehensive memory debugging):**
- Detects memory leaks, buffer overflows, use-after-free
- Heavy instrumentation (5-30x slowdown)
- Platform-specific (mainly Linux)
- Excellent for finding elusive memory bugs

```bash
# Detect all leak kinds
valgrind --leak-check=full --show-leak-kinds=all ./myapp

# Suppress known leaks
valgrind --suppressions=myapp.supp ./myapp

# Output example (clean):
# ==12345== LEAK SUMMARY:
# ==12345==    definitely lost: 0 bytes in 0 blocks
# ==12345==    indirectly lost: 0 bytes in 0 blocks
```

**Sanitizers (AddressSanitizer, MemorySanitizer, ThreadSanitizer, UBSan):**
- Built into Clang and GCC
- Lower overhead than Valgrind (2-5x slowdown)
- Best for continuous testing
- Multiple orthogonal tools for different error classes

```bash
# AddressSanitizer: heap/stack buffer overflows, use-after-free
clang++ -fsanitize=address -g myapp.cpp

# MemorySanitizer: uninitialized memory access
clang++ -fsanitize=memory -g myapp.cpp

# ThreadSanitizer: data races in multithreaded code
clang++ -fsanitize=thread -g myapp.cpp

# UndefinedBehaviorSanitizer: signed overflow, null dereference, etc.
clang++ -fsanitize=undefined -g myapp.cpp

# Combine multiple sanitizers (common in CI)
clang++ -fsanitize=address,undefined -g myapp.cpp
```

### Standard libraries: STL and Boost

**C++ Standard Library (STL):**
- Always available in modern C++
- Containers, algorithms, utilities provided by language standard
- Optimized, battle-tested implementations
- Should be default choice for core functionality

Common STL components:
- Containers: `std::vector`, `std::map`, `std::unordered_map`, `std::string`
- Algorithms: `std::sort`, `std::find`, `std::transform`
- Utilities: `std::optional`, `std::variant`, `std::expected`
- Concurrency: `std::thread`, `std::mutex`, `std::condition_variable`

**Boost Libraries:**
- Extended functionality beyond STL
- Industry-standard additions (many later adopted into STL)
- Mature, well-maintained ecosystem
- Use when STL doesn't provide needed capability

Common Boost libraries:
- `boost::asio` - Networking and async I/O
- `boost::filesystem` - Cross-platform file operations
- `boost::regex` - Regular expressions
- `boost::format` - Formatted output
- `boost::smart_ptr` - Advanced pointer patterns (now in STL)

**When to choose:**
- Default to STL for standard needs
- Add Boost when STL doesn't cover requirement
- Prefer Boost over custom implementations of common patterns
- Avoid Boost for single utility if STL alternative exists

### Testing frameworks: GoogleTest, Catch2, and GoogleMock

*See Testing strategies section above for detailed framework comparison and examples.*

**Quick reference:**

| Framework | Style | Mocking | Dependencies | Best for |
|-----------|-------|---------|--------------|----------|
| GoogleTest | xUnit | Built-in (GoogleMock) | External | Large projects, complex mocking needs |
| Catch2 | Modern BDD | Third-party | Header-only | Small/medium projects, simple setup |
| GoogleMock | Mock-centric | Primary focus | Requires GoogleTest | Dependency injection testing |

Both GoogleTest and Catch2 are production-ready. Choose based on project complexity and team preference.
