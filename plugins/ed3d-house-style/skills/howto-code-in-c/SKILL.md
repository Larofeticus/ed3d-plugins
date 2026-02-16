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
