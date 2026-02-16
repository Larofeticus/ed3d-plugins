# Testing C++ Reference

## Introduction

Testing is fundamental to writing reliable C++ code. This reference covers testing frameworks, patterns, and strategies for modern C++ (C++17+) with focus on unit testing, mocking, detecting memory errors, and validating exception safety.

Use this guide when setting up unit tests with GoogleTest, creating mocks with GoogleMock, running sanitizers, testing RAII patterns, integrating tests into CI, or validating exception safety. This complements the main C/C++ House Style skill by providing detailed testing patterns.

## GoogleTest Setup

### Basic Installation and CMake Integration

GoogleTest requires CMake configuration:

```cmake
# CMakeLists.txt
enable_testing()

# Download GoogleTest
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/v1.13.0.zip
)
FetchContent_MakeAvailable(googletest)

# Link test target
target_link_libraries(my_test gtest_main)

# Register test
add_test(NAME my_test COMMAND my_test)
```

### First Test Example

```cpp
#include <gtest/gtest.h>

TEST(StringUtilTest, ToUpperConvertsLowercase) {
    EXPECT_EQ(toUpper("hello"), "HELLO");
}

TEST(StringUtilTest, ToUpperPreservesUppercase) {
    EXPECT_EQ(toUpper("HELLO"), "HELLO");
}
```

Run tests with: `ctest` or `./my_test`

### Test Fixtures for Setup/Teardown

```cpp
class ListTest : public ::testing::Test {
protected:
    void SetUp() override {
        list.push_back(1);
        list.push_back(2);
        list.push_back(3);
    }

    std::list<int> list;
};

TEST_F(ListTest, SizeReturnsCorrectCount) {
    EXPECT_EQ(list.size(), 3);
}
```

## GoogleTest Patterns

### ASSERT vs EXPECT

**EXPECT** - Continue testing after failure:
```cpp
TEST(CalculatorTest, AdditionChain) {
    EXPECT_EQ(add(2, 3), 5);  // Failure: continue
    EXPECT_EQ(add(4, 5), 9);  // Still runs even if above fails
}
```

**ASSERT** - Stop testing on failure:
```cpp
TEST(CalculatorTest, DivisionByZero) {
    ASSERT_NE(divisor, 0) << "Divisor must be non-zero";
    EXPECT_EQ(divide(10, divisor), expected);  // Only runs if ASSERT passes
}
```

Use ASSERT for preconditions, EXPECT for verifying behavior.

### Parameterized Tests

Test multiple input-output pairs with one test function:

```cpp
class FibonacciTest : public ::testing::TestWithParam<std::pair<int, int>> {};

TEST_P(FibonacciTest, ProducesCorrectSequence) {
    auto [input, expected] = GetParam();
    EXPECT_EQ(fibonacci(input), expected);
}

INSTANTIATE_TEST_SUITE_P(
    FibSequence,
    FibonacciTest,
    ::testing::Values(
        std::make_pair(0, 0),
        std::make_pair(1, 1),
        std::make_pair(5, 5),
        std::make_pair(10, 55)
    )
);
```

### Typed Tests

Test the same logic across multiple types:

```cpp
template <typename T>
class ContainerTest : public ::testing::Test {};

using ContainerTypes = ::testing::Types<
    std::vector<int>,
    std::list<int>,
    std::deque<int>
>;

TYPED_TEST_SUITE(ContainerTest, ContainerTypes);

TYPED_TEST(ContainerTest, PushBackIncrementsSize) {
    TypeParam container;
    container.push_back(42);
    EXPECT_EQ(container.size(), 1);
}
```

### Death Tests (Testing Crashes/Aborts)

```cpp
TEST(ProcessTest, AbortOnInvalidInput) {
    EXPECT_DEATH(
        process(nullptr),
        "Invalid input"
    );
}

TEST(PointerTest, AssertOnNullptrDereference) {
    int* p = nullptr;
    EXPECT_DEATH(
        { *p = 5; },
        ".*"  // Match any message
    );
}
```

## GoogleMock Patterns

### Creating Mocks

```cpp
// Real interface
class Database {
public:
    virtual ~Database() = default;
    virtual bool connect(const std::string& host) = 0;
    virtual std::string query(const std::string& sql) = 0;
};

// Mock version
class MockDatabase : public Database {
public:
    MOCK_METHOD(bool, connect, (const std::string& host), (override));
    MOCK_METHOD(std::string, query, (const std::string& sql), (override));
};
```

### EXPECT_CALL and Argument Matchers

```cpp
TEST(UserServiceTest, CreatesUserWhenDatabaseConnected) {
    MockDatabase db;

    EXPECT_CALL(db, connect("localhost"))
        .Times(1)
        .WillOnce(::testing::Return(true));

    EXPECT_CALL(db, query(::testing::MatchesRegex("INSERT.*")))
        .Times(1)
        .WillOnce(::testing::Return("OK"));

    UserService service(&db);
    EXPECT_TRUE(service.createUser("Alice"));
}
```

Common matchers: `Eq()`, `Le()`, `Gt()`, `MatchesRegex()`, `StartsWith()`, `Contains()`

### Return Value Specification

```cpp
MockDatabase db;

// Return a value
EXPECT_CALL(db, query("..."))
    .WillOnce(::testing::Return("success"));

// Return different values on successive calls
EXPECT_CALL(db, query("..."))
    .WillOnce(::testing::Return("first"))
    .WillOnce(::testing::Return("second"));

// Call a function to generate return value
EXPECT_CALL(db, query("..."))
    .WillOnce(::testing::Invoke([](const std::string& sql) {
        return "Result for: " + sql;
    }));
```

### Sequence Verification

Enforce call ordering:

```cpp
using ::testing::Sequence;

MockDatabase db;
Sequence s;

EXPECT_CALL(db, connect("localhost"))
    .InSequence(s)
    .WillOnce(::testing::Return(true));

EXPECT_CALL(db, query("SELECT * FROM users"))
    .InSequence(s)
    .WillOnce(::testing::Return("users"));
```

## Testing RAII and Exception Safety

### Testing Destructors Are Called

```cpp
class ResourceTracker {
public:
    static int constructionCount;
    static int destructionCount;

    ResourceTracker() { ++constructionCount; }
    ~ResourceTracker() { ++destructionCount; }
};

int ResourceTracker::constructionCount = 0;
int ResourceTracker::destructionCount = 0;

TEST(RAIITest, DestructorCalledOnStackUnwind) {
    {
        ResourceTracker rt;
        EXPECT_EQ(ResourceTracker::constructionCount, 1);
    }
    EXPECT_EQ(ResourceTracker::destructionCount, 1);
}

TEST(RAIITest, DestructorCalledOnException) {
    EXPECT_THROW({
        try {
            ResourceTracker rt;
            throw std::runtime_error("test");
        } catch (...) {
            EXPECT_EQ(ResourceTracker::destructionCount, 1);
            throw;
        }
    }, std::runtime_error);
}
```

### Testing Exception Safety Guarantees

```cpp
class Transaction {
public:
    void commit();  // Strong exception safety
    void rollback() noexcept;  // Noexcept guarantee
};

TEST(TransactionTest, CommitRollesBackOnException) {
    Transaction t;
    EXPECT_THROW(t.commit(), std::exception);
    // Verify state is consistent (unchanged)
    // Test invariants still hold
}
```

## Sanitizers

Sanitizers detect memory errors, data races, and undefined behavior at runtime. Enable them in CMake:

### AddressSanitizer (ASan)

Detects buffer overflows, use-after-free, double-free, memory leaks:

```cmake
# In CMakeLists.txt
if(ENABLE_ASAN)
    add_compile_options(-fsanitize=address)
    add_link_options(-fsanitize=address)
endif()
```

```cpp
// This detects buffer overflow
TEST(BufferTest, DetectsOverflow) {
    int arr[10];
    arr[15] = 5;  // Caught by ASan
}

// This detects use-after-free
TEST(PointerTest, DetectsUseAfterFree) {
    int* p = new int(42);
    delete p;
    EXPECT_EQ(*p, 42);  // Use after free - caught by ASan
}
```

Run with: `ASAN_OPTIONS=verbosity=1:halt_on_error=1 ./my_test`

### MemorySanitizer (MSan)

Detects reads of uninitialized memory:

```cmake
if(ENABLE_MSAN)
    add_compile_options(-fsanitize=memory)
    add_link_options(-fsanitize=memory)
endif()
```

### ThreadSanitizer (TSan)

Detects data races in multithreaded code:

```cmake
if(ENABLE_TSAN)
    add_compile_options(-fsanitize=thread)
    add_link_options(-fsanitize=thread)
endif()
```

```cpp
TEST(ConcurrencyTest, DetectsDataRace) {
    int counter = 0;
    std::thread t1([&counter]() { ++counter; });
    std::thread t2([&counter]() { ++counter; });
    t1.join();
    t2.join();
    EXPECT_EQ(counter, 2);  // Data race if not synchronized
}
```

### UndefinedBehaviorSanitizer (UBSan)

Detects undefined behavior (signed overflow, out-of-bounds array access, etc.):

```cmake
if(ENABLE_UBSAN)
    add_compile_options(-fsanitize=undefined)
    add_link_options(-fsanitize=undefined)
endif()
```

### Sanitizers in CI Integration

Example CI configuration (GitHub Actions):

```yaml
name: Tests with Sanitizers

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        sanitizer: [asan, msan, tsan, ubsan]
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: sudo apt-get install -y clang
      - name: Build with sanitizer
        run: |
          cmake -B build -DENABLE_${SANITIZER^^}=ON
          cmake --build build
      - name: Run tests
        run: ctest --test-dir build --output-on-failure
```

## Property-Based Testing

Property-based testing generates random inputs to verify invariants hold across many cases.

### RapidCheck Library Setup

```cmake
FetchContent_Declare(
  rapidcheck
  GIT_REPOSITORY https://github.com/emil-e/rapidcheck.git
)
FetchContent_MakeAvailable(rapidcheck)

target_link_libraries(my_test rc)
```

### Property Definition Pattern

```cpp
#include <rapidcheck.h>

TEST(SortTest, SortedArrayIsIncreasing) {
    rc::check([]() {
        auto v = *rc::gen::container<std::vector<int>>(
            rc::gen::inRange(0, 100)
        );
        std::sort(v.begin(), v.end());

        // Verify sorted invariant
        for (size_t i = 1; i < v.size(); ++i) {
            RC_ASSERT(v[i] >= v[i-1]);
        }
    });
}

TEST(StringTest, ReversingTwiceEqualsOriginal) {
    rc::check([]() {
        auto s = *rc::gen::string<std::string>();
        std::string reversed = s;
        std::reverse(reversed.begin(), reversed.end());
        std::reverse(reversed.begin(), reversed.end());
        RC_ASSERT(reversed == s);
    });
}
```

## Numerical Accuracy Testing

Never use `==` for floating-point comparison. GoogleTest provides EXPECT_NEAR for absolute tolerance and EXPECT_DOUBLE_EQ for ULP-based tolerance:

```cpp
// Bad
TEST(MathTest, SquareRootCorrect) {
    EXPECT_EQ(sqrt(2.0) * sqrt(2.0), 2.0);  // Likely fails
}

// Good - absolute tolerance
TEST(MathTest, SquareRootCorrectAbsolute) {
    EXPECT_NEAR(sqrt(2.0) * sqrt(2.0), 2.0, 1e-9);
}

// Good - ULP tolerance
TEST(FloatTest, FloatEquality) {
    EXPECT_FLOAT_EQ(0.1f + 0.2f, 0.3f);
    EXPECT_DOUBLE_EQ(0.1 + 0.2, 0.3);
}
```

## CI Integration Examples

Example GitHub Actions workflow:

```yaml
name: C++ Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and test with ASan
        run: |
          cmake -B build -DENABLE_ASAN=ON
          cmake --build build
          ctest --test-dir build --output-on-failure
      - name: Build and test with UBSan
        run: |
          cmake -B build-ubsan -DENABLE_UBSAN=ON
          cmake --build build-ubsan
          ctest --test-dir build-ubsan --output-on-failure
```

## Testing Checklist

Before considering tests complete:

- [ ] Unit tests cover normal and edge cases
- [ ] ASSERT for preconditions, EXPECT for behavior verification
- [ ] Parametrized tests for multiple input cases
- [ ] Mocks verify dependency interactions
- [ ] RAII tests verify cleanup on exception
- [ ] Float comparisons use EXPECT_NEAR, not EXPECT_EQ
- [ ] Builds with ASan, MSan, TSan, UBSan without warnings
- [ ] Tests run in CI with sanitizers enabled
