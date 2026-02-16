# C++ Standard Library (STL) Reference

## Introduction

This reference guide covers the most important components of the C++ Standard Library (STL). Rather than a complete API reference, it focuses on decision frameworks - when to use each container and algorithm, complexity characteristics, and practical patterns.

Use this guide when:
- Choosing between multiple container types (vector vs deque vs list)
- Selecting algorithms for common operations (search, sort, transform)
- Deciding between smart pointers and utility types
- Optimizing performance-critical code
- Understanding complexity trade-offs

This complements the main C/C++ House Style skill by providing detailed reference material for library usage decisions.

## Containers

### Container Selection Decision Framework

| Problem | Choose | Why |
|---------|--------|-----|
| Dynamic array, frequent access | `vector<T>` | O(1) access, cache-friendly, fast append |
| Frequent front/back operations | `deque<T>` | O(1) push_front/back, better than vector |
| Frequent insertions/deletions | `list<T>` | O(1) insert/erase with iterator, not random access |
| No front insertions needed | `forward_list<T>` | Lower memory than list (single-link) |
| Unique values, sorted | `set<T>` | O(log n) operations, ordered |
| Non-unique values, sorted | `multiset<T>` | Like set but allows duplicates |
| Key-value pairs, sorted | `map<K,V>` | O(log n) lookup by key |
| Non-unique keys | `multimap<K,V>` | Like map but multiple values per key |
| Fast lookup (unordered) | `unordered_set<T>` | Average O(1) lookup, worst O(n) |
| Fast key-value lookup | `unordered_map<K,V>` | Average O(1) lookup, hash-based |
| Fixed-size array, stack allocation | `array<T,N>` | Zero-cost abstraction over C array |
| Stack operations | `stack<T>` | Adapter on vector/deque/list |
| Queue operations | `queue<T>` | Adapter on deque/list |
| Priority order | `priority_queue<T>` | Adapter on vector/deque, heap-based |

### Sequential Containers

**`vector<T>`** - Dynamic array with tail insertion
```cpp
std::vector<int> v = {1, 2, 3};
v.push_back(4);        // O(1) amortized
v[0] = 5;              // O(1) random access
v.erase(v.begin() + 1); // O(n) in worst case
```
Use when: Need dynamic array with fast random access and push_back. Default choice for sequences.

**`array<T, N>`** - Fixed-size array, stack or static allocation
```cpp
std::array<int, 5> a = {1, 2, 3, 4, 5};
int x = a[0];          // O(1), bounds-checked with .at()
a.size();              // Always 5
```
Use when: Size known at compile time, need zero overhead. Prefer over C arrays.

**`deque<T>`** - Double-ended queue
```cpp
std::deque<int> d;
d.push_front(1);       // O(1)
d.push_back(2);        // O(1)
int x = d[0];          // O(1) random access
```
Use when: Need efficient push_front and push_back. Better than vector if frequently prepending.

**`list<T>`** - Doubly-linked list
```cpp
std::list<int> l = {1, 2, 3};
auto it = l.begin();
++it;
l.insert(it, 99);      // O(1) with iterator
l.erase(it);           // O(1) with iterator
```
Use when: Frequent insertions/deletions in middle, don't need random access. Cache-unfriendly.

**`forward_list<T>`** - Singly-linked list
```cpp
std::forward_list<int> fl = {1, 2, 3};
fl.push_front(0);      // O(1)
// No back operations, no size() method
```
Use when: Memory critical, only traverse forward, no backward iteration needed.

### Associative Containers (Ordered)

**`set<T>`** - Unique sorted values
```cpp
std::set<int> s = {3, 1, 2};
s.insert(4);           // O(log n), returns {iterator, bool}
s.find(2);             // O(log n), returns iterator or end()
s.count(2);            // O(log n), returns 0 or 1
for (int x : s) { }    // Sorted iteration: 1, 2, 3, 4
```
Use when: Need sorted unique values with efficient search. Custom comparators with `set<T, Compare>`.

**`multiset<T>`** - Non-unique sorted values
```cpp
std::multiset<int> ms = {1, 2, 2, 3};
ms.insert(2);          // O(log n), always succeeds
ms.count(2);           // Returns 3
ms.equal_range(2);     // Returns pair of iterators for all 2's
```
Use when: Need duplicates in sorted container. Same complexity as set.

**`map<K, V>`** - Sorted key-value pairs, unique keys
```cpp
std::map<std::string, int> m;
m["age"] = 30;         // Insert or update, O(log n)
if (m.find("age") != m.end()) { } // O(log n) search
m.count("age");        // 0 or 1
for (auto [k, v] : m) { } // Sorted by key
```
Use when: Need efficient key lookup with associated values. Default for associative data.

**`multimap<K, V>`** - Sorted key-value pairs, duplicate keys allowed
```cpp
std::multimap<std::string, int> mm;
mm.insert({"name", 1});
mm.insert({"name", 2}); // Both stored
mm.count("name");       // Returns 2
auto range = mm.equal_range("name"); // Both values
```
Use when: Multiple values per key in sorted container.

### Associative Containers (Unordered)

**`unordered_set<T>`** - Unique values, hash-based
```cpp
std::unordered_set<std::string> s;
s.insert("hello");     // Average O(1), worst O(n)
s.find("hello");       // Average O(1), worst O(n)
// Order is unspecified
```
Use when: Need fast membership testing without sorting. Fastest for large sets.

**`unordered_map<K, V>`** - Hash-based key-value pairs
```cpp
std::unordered_map<std::string, int> m;
m["name"] = "Alice";   // Average O(1) insertion
m.at("name");          // Throws if missing, unlike operator[]
```
Use when: Need O(1) average key lookup. Watch for hash collisions in worst case.

**`unordered_multiset<T>` and `unordered_multimap<K, V>`** - Hash-based with duplicates
```cpp
std::unordered_multimap<int, std::string> mm;
mm.insert({1, "one"});
mm.insert({1, "uno"}); // Duplicate key allowed
```
Use when: Need duplicates and hash speed. Same average complexity as unordered versions.

### Container Adapters

**`stack<T>`** - LIFO (Last-In-First-Out)
```cpp
std::stack<int> s;
s.push(1);    // O(1)
int top = s.top();  // Peek top element
s.pop();      // Remove top, O(1)
```
Use when: Need LIFO semantics. Implemented on deque by default.

**`queue<T>`** - FIFO (First-In-First-Out)
```cpp
std::queue<int> q;
q.push(1);    // O(1) enqueue
int front = q.front();
q.pop();      // O(1) dequeue
```
Use when: Need FIFO semantics. Implemented on deque by default.

**`priority_queue<T>`** - Max-heap by default
```cpp
std::priority_queue<int> pq;
pq.push(5);
pq.push(3);
int max = pq.top();   // 5
pq.pop();
// Use std::greater<int> for min-heap
std::priority_queue<int, std::vector<int>, std::greater<int>> minpq;
```
Use when: Need efficient access to max/min element. O(log n) push/pop.

## Algorithms

### Non-Modifying Algorithms

| Function | Purpose | Example |
|----------|---------|---------|
| `find(first, last, value)` | Find first matching element | `auto it = find(v.begin(), v.end(), 5);` |
| `find_if(first, last, pred)` | Find first element matching predicate | `find_if(v.begin(), v.end(), [](int x) { return x > 3; })` |
| `count(first, last, value)` | Count matching elements | `int n = count(v.begin(), v.end(), 5);` |
| `count_if(first, last, pred)` | Count elements matching predicate | `count_if(v.begin(), v.end(), [](int x) { return x < 0; })` |
| `all_of(first, last, pred)` | Check if all match predicate | `bool ok = all_of(v.begin(), v.end(), [](int x) { return x > 0; });` |
| `any_of(first, last, pred)` | Check if any match predicate | `bool has_neg = any_of(v.begin(), v.end(), [](int x) { return x < 0; });` |
| `none_of(first, last, pred)` | Check if none match predicate | `bool all_pos = none_of(v.begin(), v.end(), [](int x) { return x < 0; });` |

### Modifying Algorithms

| Function | Purpose | Complexity |
|----------|---------|-----------|
| `copy(src_first, src_last, dest)` | Copy range | O(n) |
| `move(src_first, src_last, dest)` | Move range (std::move semantics) | O(n) |
| `fill(first, last, value)` | Set all elements to value | O(n) |
| `fill_n(first, count, value)` | Set first n elements | O(n) |
| `replace(first, last, old, new)` | Replace all matching values | O(n) |
| `replace_if(first, last, pred, new)` | Replace elements matching predicate | O(n) |
| `transform(src_first, src_last, dest, func)` | Apply function to each element | O(n) |
| `reverse(first, last)` | Reverse in-place | O(n) |
| `rotate(first, pivot, last)` | Rotate sequence | O(n) |
| `shuffle(first, last, rng)` | Randomize order | O(n) |

### Sorting Algorithms

| Function | Best Case | Avg Case | Worst Case | Stable | Use When |
|----------|-----------|----------|------------|--------|----------|
| `sort` | O(n log n) | O(n log n) | O(n log n) | No | General sorting, need fast average |
| `stable_sort` | O(n log n) | O(n log n) | O(n log n) | Yes | Need to preserve relative order |
| `partial_sort` | O(n log k) | O(n log k) | O(n log k) | No | Need only first k elements |
| `nth_element` | O(n) avg | O(n) avg | O(n^2) | No | Find kth smallest without full sort |

```cpp
std::vector<int> v = {3, 1, 4, 1, 5, 9, 2, 6};
std::sort(v.begin(), v.end());         // 1, 1, 2, 3, 4, 5, 6, 9
std::sort(v.begin(), v.end(), std::greater<int>()); // Descending
std::stable_sort(v.begin(), v.end());  // Preserve equal elements' order
std::partial_sort(v.begin(), v.begin() + 3, v.end()); // First 3 sorted
```

### Binary Search Algorithms

**Requires sorted range:**

| Function | Returns | Example |
|----------|---------|---------|
| `binary_search(first, last, value)` | bool - found? | `bool found = binary_search(v.begin(), v.end(), 5);` |
| `lower_bound(first, last, value)` | Iterator to first >= value | `auto it = lower_bound(v.begin(), v.end(), 5);` |
| `upper_bound(first, last, value)` | Iterator to first > value | `auto it = upper_bound(v.begin(), v.end(), 5);` |
| `equal_range(first, last, value)` | Pair {lower, upper} | `auto [lo, hi] = equal_range(v.begin(), v.end(), 5);` |

All O(log n) complexity.

## Utilities

### Smart Pointers

**`unique_ptr<T>`** - Exclusive ownership
```cpp
std::unique_ptr<Widget> w(new Widget());  // or make_unique
w->method();
// w destroyed automatically, calls destructor
// Not copyable, only moveable
std::unique_ptr<Widget> w2 = std::move(w); // w now nullptr
```
Use when: Single owner of resource. Prefer `std::make_unique<T>(args)`.

**`shared_ptr<T>`** - Shared ownership
```cpp
std::shared_ptr<Widget> w1(new Widget());
std::shared_ptr<Widget> w2 = w1;  // Both own
// Destroyed when last shared_ptr destroyed
w1.use_count();  // 2
w1.reset();      // Release ownership
```
Use when: Multiple owners. Overhead of reference counting. Watch for circular references.

**`weak_ptr<T>`** - Non-owning observer
```cpp
std::shared_ptr<Node> sp = std::make_shared<Node>();
std::weak_ptr<Node> wp = sp;  // Non-owning reference
if (auto locked = wp.lock()) {  // Convert to shared_ptr
    locked->method();
}
```
Use when: Breaking circular references with shared_ptr. Convert to shared_ptr to use.

### Optional Types

**`optional<T>`** - Value that may be absent
```cpp
std::optional<int> maybe_age = 25;
if (maybe_age) {
    std::cout << maybe_age.value();
}
maybe_age = std::nullopt;  // Clear the value
std::optional<int> empty;  // Uninitialized
```
Use when: Value may legitimately be absent. Prefer to nullable pointers.

**`variant<T1, T2, ...>`** - Type-safe union holding one of several types
```cpp
std::variant<int, std::string> v = 5;
if (std::holds_alternative<int>(v)) {
    std::get<int>(v);  // Returns 5
}
v = "hello";  // Now holds string
```
Use when: Value can be one of several types. Type-safe alternative to void*.

**`any`** - Type-erased value
```cpp
std::any a = 5;
a = std::string("hello");
std::string s = std::any_cast<std::string>(a);  // Throws if wrong type
```
Use when: Runtime type flexibility needed. Slower than variant (no compile-time type info).

### Pair and Tuple

**`pair<T1, T2>`** - Two-element tuple
```cpp
std::pair<int, std::string> p = {1, "one"};
auto [num, str] = p;  // Structured binding (C++17)
std::make_pair(1, "one");
```
Use when: Returning two related values. Map/set use pair<const Key, Value>.

**`tuple<T1, T2, T3, ...>`** - N-element tuple
```cpp
std::tuple<int, std::string, double> t = {1, "one", 1.0};
auto [num, str, d] = t;  // Structured binding
std::get<0>(t);          // Access by index
std::get<int>(t);        // Access by type (if unique)
```
Use when: Returning multiple values. Prefer structured bindings for clarity.

### Function Objects

**`std::function<R(Args...)>`** - Callable wrapper
```cpp
std::function<int(int, int)> add = [](int a, int b) { return a + b; };
std::function<int(int, int)> another = &my_function;  // Function pointer
int result = add(2, 3);  // Calls wrapped callable
```
Use when: Need to store callables polymorphically. Overhead vs direct call.

**`std::bind`** - Bind arguments to callable
```cpp
auto add_five = std::bind([](int a, int b) { return a + b; }, 5, std::placeholders::_1);
add_five(3);  // Calls lambda with args (5, 3)
```
Use when: Creating partial applications. Often lambdas with capture are clearer.

## String Handling

### `std::string` vs `std::string_view`

| Type | Owns Data | Mutable | Use When |
|------|-----------|---------|----------|
| `std::string` | Yes | Yes | Need ownership or modification |
| `std::string_view` | No | No | Passing reference, don't modify |

```cpp
std::string s = "hello";
std::string_view sv = s;         // Reference to s
sv[0];                           // Access without copy
// sv becomes invalid if s destroyed

void process(std::string_view data) {  // Prefer to const std::string&
    // Works with string, C string, string_view
}
```

### Common String Operations

```cpp
std::string s = "hello";
s.length();                 // 5
s.substr(1, 3);            // "ell"
s.find("ll");              // 2 (position)
s.find("x");               // std::string::npos (not found)
s.replace(1, 2, "XX");     // "heXXo"
s.append(" world");        // "hello world"
s + " world";              // Concatenation
```

## Quick Reference Tables

### Container Complexity Summary

| Operation | vector | deque | list | set | map | unordered_set | unordered_map |
|-----------|--------|-------|------|-----|-----|---------------|---------------|
| Access | O(1) | O(1) | O(n) | - | - | - | - |
| Search | O(n) | O(n) | O(n) | O(log n) | O(log n) | O(1) avg | O(1) avg |
| Insert | O(1) tail | O(1) ends | O(1) iter | O(log n) | O(log n) | O(1) avg | O(1) avg |
| Delete | O(n) | O(n) | O(1) iter | O(log n) | O(log n) | O(1) avg | O(1) avg |
| Space | Linear | Linear | Linear | Linear | Linear | Linear | Linear |

### Algorithm Complexity Summary

| Algorithm | Complexity | Notes |
|-----------|-----------|-------|
| find, find_if | O(n) | Linear scan |
| sort | O(n log n) | Introsort (hybrid) |
| stable_sort | O(n log n) | Preserves order, may use O(n) extra space |
| binary_search | O(log n) | Requires sorted range |
| lower_bound, upper_bound | O(log n) | Requires sorted range |
| unique, sort_unique | O(n log n) | remove duplicates |
| partition | O(n) | Divide by predicate |
| nth_element | O(n) avg | Find kth element |

## When to Use Each Tool

**Choose vector unless you have a specific reason not to.** It's cache-friendly and has excellent performance for most workloads.

Use specialized containers only when:
- `deque`: Frequent push_front operations needed
- `list`: Frequent insertions/deletions in middle
- `set/map`: Need sorted data or O(log n) operations
- `unordered_set/map`: Need average O(1) and don't care about order
- `array`: Size known at compile time

For algorithms, remember: Always consider whether a standard algorithm applies before writing custom loops.
