# Memory Management Patterns in C++

## Introduction

Memory management is the cornerstone of C++ performance and safety. This reference guide covers the patterns, techniques, and decision frameworks for effective memory management in modern C++. Unlike garbage-collected languages, C++ gives you direct control over object lifetime - and with that control comes responsibility.

**Core philosophy:** Tie resource lifetimes to object lifetimes through RAII (Resource Acquisition Is Initialization). Prefer smart pointers over raw pointers. Choose stack allocation when possible, heap allocation with RAII when necessary.

Use this guide when:
- Designing classes that own resources (memory, files, locks)
- Choosing between unique_ptr, shared_ptr, and raw pointers
- Implementing custom deleters for non-standard resources
- Optimizing memory allocation patterns
- Debugging memory leaks or use-after-free issues

This complements the main C/C++ House Style skill by providing detailed patterns for safe and efficient memory management.

## RAII Pattern Examples

### File Handle RAII Wrapper

**Bad - Manual resource management:**
```cpp
void processFile(const char* filename) {
    FILE* f = fopen(filename, "r");
    if (!f) return;

    // If any error here, file never closed
    char buffer[256];
    fread(buffer, 1, 256, f);
    printf("%s\n", buffer);

    fclose(f);  // Only called on success path
}
```

**Good - RAII wrapper:**
```cpp
class FileHandle {
private:
    FILE* file_;
public:
    explicit FileHandle(const char* filename) {
        file_ = fopen(filename, "r");
        if (!file_) throw std::runtime_error("Cannot open file");
    }

    ~FileHandle() {
        if (file_) fclose(file_);
    }

    FILE* get() { return file_; }

    // Prevent copying
    FileHandle(const FileHandle&) = delete;
    FileHandle& operator=(const FileHandle&) = delete;
};

void processFile(const char* filename) {
    FileHandle f(filename);  // Acquires resource
    char buffer[256];
    fread(buffer, 1, 256, f.get());
    printf("%s\n", buffer);
    // f destroyed, file automatically closed - even if exception thrown
}
```

### Mutex Lock Guard Pattern

**Bad - Forgetting to unlock:**
```cpp
std::mutex m;

void criticalSection() {
    m.lock();
    // If exception here, lock never released
    doSomething();
    m.unlock();  // Easily forgotten
}
```

**Good - RAII lock guard:**
```cpp
std::mutex m;

void criticalSection() {
    std::lock_guard<std::mutex> lock(m);  // Acquires
    doSomething();  // Exception-safe
    // lock destroyed, mutex unlocked automatically
}
```

### Resource Wrapper Template

```cpp
template<typename Resource, typename Deleter>
class ResourceGuard {
private:
    Resource resource_;
    Deleter deleter_;

public:
    ResourceGuard(Resource r, Deleter d)
        : resource_(r), deleter_(d) {}

    ~ResourceGuard() { deleter_(resource_); }

    Resource get() const { return resource_; }

    // Prevent copying
    ResourceGuard(const ResourceGuard&) = delete;
    ResourceGuard& operator=(const ResourceGuard&) = delete;

    // Allow moving
    ResourceGuard(ResourceGuard&& other) noexcept
        : resource_(other.resource_), deleter_(other.deleter_) {
        other.resource_ = nullptr;
    }
};
```

## Smart Pointer Decision Tree

**Start here:** You're managing a heap-allocated object. Which pointer type?

```
Does one object own it exclusively?
| YES -> unique_ptr<T>
|        (Move-only, zero overhead, most common)
|        Use: Database connections, file handles, temporary objects
|
| NO -> Multiple objects need access
        Is ownership shared equally?
        | YES (shared ownership) -> shared_ptr<T>
        |        (Reference counting, thread-safe reference count)
        |        Use: Observer patterns, shared data structures
        |
        | NO -> Just borrowing a reference (don't manage lifetime)
                raw pointer (T*) or reference (T&)
                Use: Function parameters, observer/listener patterns
                WARNING: Ensure pointer valid at use site
```

**Decision table:**

| Scenario | Choose | Rationale |
|----------|--------|-----------|
| Database connection, owns exclusively | `unique_ptr<Database>` | Move semantics, clear ownership |
| Cache shared by multiple systems | `shared_ptr<CacheEntry>` | Reference counting handles cleanup |
| Function parameter, don't own | `T*` or `const T&` | No overhead, caller manages lifetime |
| Array of objects, exclusive ownership | `unique_ptr<T[]>` | Smart enough for arrays |
| Temporary workspace | `unique_ptr<T>` | RAII cleanup on scope exit |
| Circular reference potential | `shared_ptr<T>` with `weak_ptr<T>` | weak_ptr breaks cycles |

**Anti-patterns to avoid:**

- `new` and `delete` in application code - use smart pointers
- `shared_ptr` when `unique_ptr` would work - unnecessary reference counting overhead
- `T*` when `unique_ptr<T>` more appropriate - confuses ownership
- Passing `shared_ptr` by value when const reference would work - unnecessary atomic operations

## Custom Deleters

### C Library Resource Cleanup

**Problem:** C library returns malloc'd memory, but you want RAII.

```cpp
// C API signature
char* getConfigString(void);  // Caller must free result
void freeConfigString(char* s);

// Wrap with custom deleter
std::unique_ptr<char, decltype(&freeConfigString)> getConfig() {
    auto deleter = [](char* s) { freeConfigString(s); };
    return std::unique_ptr<char, decltype(deleter)>(
        getConfigString(),
        deleter
    );
}

// Or simpler - store deleter as type
using ConfigString = std::unique_ptr<char, decltype(&freeConfigString)>;

ConfigString config(getConfigString(), &freeConfigString);
// Automatically calls freeConfigString when config goes out of scope
```

### Array Deleters

```cpp
// Heap-allocated array
std::unique_ptr<int[]> arr(new int[100]);
arr[0] = 42;
// Correctly calls delete[] in destructor

// With custom deleter
auto customArrayDeleter = [](int* p) {
    std::cout << "Freeing array\n";
    delete[] p;
};

std::unique_ptr<int[], decltype(customArrayDeleter)>
    arr2(new int[50], customArrayDeleter);
```

### No-Op Deleters for Non-Owning Pointers

```cpp
// Sometimes you need shared_ptr semantics but don't own the object
class Observer {
    std::shared_ptr<Model> model_;

public:
    // model parameter is not owned by Observer
    Observer(Model* m)
        : model_(m, [](void*) {}) {}  // No-op deleter
};

// Now Observer can use model_ like any shared_ptr
// but cleanup is caller's responsibility
```

### Lambda Deleters

```cpp
// Custom cleanup logic as lambda
auto config = std::unique_ptr<FILE, decltype([](FILE* f) {
    if (f) fclose(f);
})>(fopen("config.txt", "r"));

// With explicit lambda type
auto fileDeleter = [](FILE* f) {
    if (f) fclose(f);
};

std::unique_ptr<FILE, decltype(fileDeleter)>
    file(fopen("log.txt", "w"), fileDeleter);
```

## Circular Reference Prevention

### Identifying Circular References

**Problem pattern - Parent/Child both use shared_ptr:**
```cpp
class Parent {
    std::shared_ptr<Child> child_;
};

class Child {
    std::shared_ptr<Parent> parent_;  // PROBLEM: Reference cycle
};

// After: parent owns child, child owns parent
// Neither can be deleted - reference count never reaches zero
```

### Breaking Cycles with weak_ptr

```cpp
class Parent {
    std::shared_ptr<Child> child_;  // Parent owns child
};

class Child {
    std::weak_ptr<Parent> parent_;  // Child borrows parent

public:
    void doSomething() {
        if (auto p = parent_.lock()) {  // Safely get shared_ptr
            p->callMethod();
        }
        // If parent deleted, lock() returns nullptr
    }
};

// Setup
auto parent = std::make_shared<Parent>();
auto child = std::make_shared<Child>();
parent->setChild(child);
child->setParent(parent);  // Now safe - child doesn't extend lifetime

// When parent deleted, child->parent_ becomes nullptr (safely)
parent = nullptr;
```

### Parent-Child Relationship Pattern

```cpp
class Node {
    std::weak_ptr<Node> parent_;      // Don't control parent lifetime
    std::vector<std::shared_ptr<Node>> children_;  // Own children

public:
    // Tree is owned from root - no cycles
    // Child can access parent safely via parent_.lock()
    // When root deleted, entire tree deleted
};
```

## Placement New and Arena Allocation

### When to Use Placement New

**Use case:** Pre-allocated buffer, need to construct object without new memory allocation.

```cpp
// Pre-allocate buffer
alignas(MyClass) std::array<char, sizeof(MyClass)> buffer;

// Construct object in place
MyClass* obj = new (buffer.data()) MyClass("initialized");

// Manual destruction required
obj->~MyClass();

// Buffer memory still exists, can reuse
```

### Arena Allocator Pattern

```cpp
class Arena {
private:
    std::vector<char> buffer_;
    size_t offset_ = 0;

public:
    template<typename T, typename... Args>
    T* allocate(Args&&... args) {
        if (offset_ + sizeof(T) > buffer_.size()) {
            throw std::bad_alloc();
        }

        T* obj = new (buffer_.data() + offset_) T(std::forward<Args>(args)...);
        offset_ += sizeof(T);
        return obj;
    }

    void reset() {
        offset_ = 0;
        // Objects not destroyed - caller responsible
    }
};

// Use case: temporary objects during computation
Arena temp_arena;
auto* a = temp_arena.allocate<Vector3>(1, 2, 3);
auto* b = temp_arena.allocate<Vector3>(4, 5, 6);
// Compute with a and b
temp_arena.reset();  // All deallocated at once
```

## Memory Alignment

### alignas and alignof

```cpp
// Require 64-byte alignment (cache line)
struct alignas(64) CacheLinePadded {
    int counter;
};

static_assert(alignof(CacheLinePadded) == 64);
static_assert(sizeof(CacheLinePadded) >= 64);

// Query alignment requirement
auto align = alignof(double);  // typically 8

// Create array with specific alignment
std::vector<alignas(16) int> aligned_vec;
```

### Over-Aligned Types

```cpp
// Some types need unusual alignment (SIMD, hardware)
struct alignas(32) SIMD_Vector {
    float data[8];  // AVX alignment
};

// Heap allocation respects alignment
auto vec = std::make_unique<SIMD_Vector>();

// But raw operator new might not
SIMD_Vector* p = new SIMD_Vector();  // May not be 32-byte aligned
```

### std::aligned_storage

```cpp
// Pre-allocate aligned buffer
std::aligned_storage_t<sizeof(MyClass), alignof(MyClass)> buffer;

// Construct in place
MyClass* obj = new (&buffer) MyClass();

// Use obj...

// Manual destruction
obj->~MyClass();
```

## Stack vs Heap Decision Framework

| Decision Factor | Choose Stack | Choose Heap |
|-----------------|--------------|------------|
| Size known at compile time | YES - `T obj;` | - |
| Size only at runtime | NO | YES - `unique_ptr<T>` |
| Lifetime ends with scope | YES - stack | - |
| Lifetime spans multiple scopes | NO | YES - smart pointer |
| Large object (>8KB) | Consider heap | YES - avoid stack overflow |
| Temporary computation object | YES - stack | - |
| Object needs move semantics | Either | shared_ptr if shared |
| Exception safety critical | Stack preferred (RAII automatic) | - |

**Stack allocation:**
```cpp
int buffer[1024];           // OK - compile-time size
Vector3 pos(1, 2, 3);       // OK - small, automatic cleanup
```

**Heap allocation:**
```cpp
int size = getUserInput();
auto buffer = std::make_unique<int[]>(size);  // Runtime size

std::string name = "Alice";  // Actually heap internally, but managed
auto config = std::make_shared<Config>();    // Shared ownership
```

## Common Memory Mistakes

### Double Delete

```cpp
// BAD
int* p = new int(42);
delete p;
delete p;  // Undefined behavior!

// GOOD - Use smart pointers, double-delete impossible
auto p = std::make_unique<int>(42);
// p deleted once in destructor
```

### Memory Leaks

```cpp
// BAD - Exception between new and delete
void processData() {
    int* data = new int[1000];
    parseData(data);  // If throws, memory leaked
    delete[] data;
}

// GOOD - RAII guarantees cleanup
void processData() {
    auto data = std::make_unique<int[]>(1000);
    parseData(data.get());  // Exception-safe
    // data cleaned up automatically
}
```

### Use-After-Free

```cpp
// BAD
std::unique_ptr<int> p = std::make_unique<int>(42);
int* raw = p.get();
p = nullptr;      // p deleted
*raw = 100;       // Use-after-free!

// GOOD - Keep reference in scope
std::unique_ptr<int> p = std::make_unique<int>(42);
*p = 100;  // Safe - p still owns object
// p deleted only when out of scope
```

### Dangling Pointers

```cpp
// BAD - Returning reference to stack object
int* getBadPointer() {
    int x = 42;
    return &x;  // x destroyed at function exit
}

// GOOD - Return owned object
std::unique_ptr<int> getGoodPointer() {
    return std::make_unique<int>(42);
}

std::string getBadString() {
    char buffer[256] = "hello";
    return buffer;  // OK - string copies data
}
```

