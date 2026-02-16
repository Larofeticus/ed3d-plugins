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
