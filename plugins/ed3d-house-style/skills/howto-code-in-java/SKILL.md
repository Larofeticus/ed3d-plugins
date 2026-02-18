---
name: howto-code-in-java
description: Use when writing or reviewing Java code - comprehensive house style covering naming conventions, Javadoc, code style, immutability, modern Java features (records, sealed classes, pattern matching, text blocks, switch expressions), Optional, Streams, exception handling, generics, enums, collections, and sharp edges for Java up to and including Java 17
user-invocable: false
---

# Java House Style

## Overview

Comprehensive Java coding standards targeting Java 17 (LTS). Covers all language features up to and including Java 17.

**Core principles:**
- Immutability by default: records, final fields, immutable collections
- Use the type system: generics, sealed classes, enums over int constants
- Modern Java features replace verbose boilerplate: records, switch expressions, text blocks
- Explicit over implicit: Javadoc all public APIs, Optional for nullable returns
- Never use floating-point for money

**Related skills (do not duplicate):**
- FCIS pattern (pure functions vs I/O): `howto-functional-vs-imperative`
- Test philosophy and patterns: `writing-good-tests`

## Quick Self-Check (Use Under Pressure)

When under deadline pressure or focused on other concerns, STOP and verify:

- [ ] Using `BigDecimal` not `double`/`float` for money or currency
- [ ] Using `.equals()` not `==` for object comparison
- [ ] Not returning mutable internal collections directly (defensive copy or `List.copyOf`)
- [ ] Public API methods return `Optional<T>`, not `null`
- [ ] All public APIs have Javadoc
- [ ] Using immutable collection factories (`List.of`, `Map.of`, `Set.of`) over `new ArrayList<>()`
- [ ] Catching specific exception types, not `Exception` or `Throwable`
- [ ] Resources closed with try-with-resources, not finally
- [ ] No raw types (`List` -> `List<String>`)
- [ ] Using `record` for pure data carriers

**Why this matters:** Under pressure, you will default to familiar patterns from older Java or other languages. These checks catch the most common violations.

## Naming Conventions

### Packages

**All lowercase, reverse domain, no underscores.**

```java
// GOOD
package com.example.userservice;
package org.project.data.models;

// BAD
package com.example.UserService;
package com.example.user_service;
```

### Classes and Interfaces

**PascalCase. Nouns for classes, adjectives or nouns for interfaces.**

```java
// GOOD: classes are nouns
class UserRepository { }
class OrderProcessingService { }
record PaymentDetails(String id, BigDecimal amount) { }
enum OrderStatus { PENDING, SHIPPED, DELIVERED }

// GOOD: interfaces - noun or adjective
interface Closeable { }
interface UserStore { }

// BAD: verbs, abbreviations, non-descriptive names
class ProcessUser { }   // verb
class UsrRepo { }       // abbreviation
class Stuff { }         // non-descriptive
```

**No `I` prefix on interfaces. No `Impl` suffix on classes unless genuinely needed for disambiguation.**

```java
// BAD: Hungarian notation on interfaces
interface IUserRepository { }

// BAD: Impl suffix as default naming
class UserRepositoryImpl implements UserRepository { }

// GOOD: disambiguate by implementation strategy
class JpaUserRepository implements UserRepository { }
class InMemoryUserRepository implements UserRepository { }
```

### Methods

**camelCase. Verbs or verb phrases. Boolean methods use is/has/can/should.**

```java
// GOOD
void processOrder(Order order)
User findById(String id)
boolean isActive()
boolean hasPermission(String action)
Optional<User> findByEmail(String email)

// BAD
void order_processing(Order o)    // snake_case, abbreviation
boolean active()                   // missing is/has prefix for boolean
User get(String id)                // too generic
```

### Fields

**camelCase. Private by default. Static final constants in SCREAMING_SNAKE_CASE.**

```java
// GOOD
private final String userId;
private int retryCount;
private static final int MAX_RETRY_COUNT = 3;
private static final Duration DEFAULT_TIMEOUT = Duration.ofSeconds(30);

// BAD
private String UserId;             // PascalCase
private int retry_count;           // snake_case
private static final int maxRetryCount = 3;  // constant not SCREAMING_SNAKE_CASE
public String name;                // public mutable field
```

### Generic Type Parameters

**Single uppercase letter, or descriptive PascalCase with T prefix for complex bounds.**

```java
// GOOD: single-letter for simple cases
class Container<T> { }
interface Mapper<T, R> { }
<E extends Enum<E>> void process(E value)

// GOOD: descriptive for complex cases
<TKey extends Comparable<TKey>, TValue> Map<TKey, TValue> buildIndex(...)

// BAD: lowercase, non-descriptive multi-char
class Container<type> { }
<item> void process(item value)
```

### Boolean Naming

**Prefer positive names. Use is/has/can/should/will prefixes.**

```java
// GOOD
boolean isActive;
boolean hasPermission;
boolean canRetry;

// BAD: negative names require double negation to reason about
boolean isNotActive;     // prefer isActive (and negate at call site)
boolean disabled;        // prefer isEnabled
```

## Javadoc

### When to Write Javadoc

**Write Javadoc on all public classes, interfaces, methods, and fields.** Skip Javadoc on:
- Private members (use inline comments if needed)
- Overriding methods where the parent Javadoc is sufficient (use `{@inheritDoc}` sparingly)
- Test methods (use descriptive method names instead)
- Record components (document on the record class itself)

### Format

```java
/**
 * Processes a payment and returns the result.
 *
 * <p>Retries up to {@link #MAX_RETRY_COUNT} times on transient failures.
 * Does not retry on {@link PaymentDeclinedException}.
 *
 * @param request the payment request; must not be null
 * @param context the processing context with merchant configuration
 * @return the payment result, never null
 * @throws PaymentDeclinedException if the payment was explicitly declined
 * @throws IllegalArgumentException if request is null
 */
public PaymentResult processPayment(PaymentRequest request, MerchantContext context) {
    // ...
}
```

**Rules:**
- First sentence is a summary (ends with period, shown in hover/index)
- Use `<p>` for additional paragraphs
- `@param` for every parameter; note null behavior
- `@return` for non-void methods; note if null is possible
- `@throws` for checked exceptions; include unchecked if they're part of the contract
- Reference other types with `{@link ClassName#methodName}`

### What NOT to Write

```java
// BAD: restates the signature, adds no value
/**
 * Gets the user.
 * @param id the id
 * @return the user
 */
User getUser(String id);

// GOOD: adds contract information
/**
 * Finds a user by their unique identifier.
 *
 * @param id the user ID; must not be null or blank
 * @return the user, or empty if no user exists with this ID
 */
Optional<User> findById(String id);
```

## Code Style

### Braces

**Always use braces for control structures, even single-statement bodies.**

```java
// GOOD
if (condition) {
    doSomething();
}

// BAD: easy to break when adding a second statement
if (condition)
    doSomething();
```

**Opening brace on same line (K&R style):**

```java
// GOOD
public void method() {
    if (condition) {
        // code
    } else {
        // code
    }
}

// BAD: Allman style (don't use in Java)
public void method()
{
    // code
}
```

### Indentation and Line Length

- 4 spaces per indent level (not tabs)
- Lines up to 120 characters (100 preferred for readability)
- Wrap long method signatures by aligning parameters:

```java
// GOOD: wrap and indent continuation
public ProcessingResult processOrderWithRetry(
        Order order,
        RetryPolicy retryPolicy,
        NotificationService notifier) {
    // ...
}
```

### Class Member Ordering

Order members within a class:
1. Static constants (`static final`)
2. Static fields
3. Instance fields
4. Constructors
5. Static factory methods
6. Public instance methods
7. Package-private and protected instance methods
8. Private instance methods
9. Static nested classes/interfaces

```java
public class OrderService {
    // 1. Static constants
    private static final int MAX_ITEMS = 100;

    // 3. Instance fields
    private final OrderRepository repository;
    private final PaymentService paymentService;

    // 4. Constructor
    public OrderService(OrderRepository repository, PaymentService paymentService) {
        this.repository = repository;
        this.paymentService = paymentService;
    }

    // 5. Static factory (if any)
    public static OrderService create(OrderRepository repo) {
        return new OrderService(repo, PaymentService.defaultInstance());
    }

    // 6. Public methods
    public Order placeOrder(OrderRequest request) { ... }
}
```

## Immutability

### Final Fields

**Mark all fields final unless mutation is genuinely required.**

```java
// GOOD: all dependencies immutable
public class UserService {
    private final UserRepository repository;
    private final EmailService emailService;

    public UserService(UserRepository repository, EmailService emailService) {
        this.repository = repository;
        this.emailService = emailService;
    }
}

// BAD: mutable fields without reason
public class UserService {
    private UserRepository repository;  // why is this mutable?
    private EmailService emailService;
}
```

### Records for Data Carriers

**Use records for pure data carriers.** Records are implicitly final, provide equals/hashCode/toString, and accessors automatically.

```java
// GOOD: record for value objects
record Money(BigDecimal amount, Currency currency) {
    // Compact constructor for validation
    Money {
        Objects.requireNonNull(amount, "amount must not be null");
        Objects.requireNonNull(currency, "currency must not be null");
        if (amount.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("amount must not be negative");
        }
    }

    Money add(Money other) {
        if (!this.currency.equals(other.currency)) {
            throw new IllegalArgumentException("cannot add different currencies");
        }
        return new Money(this.amount.add(other.amount), this.currency);
    }
}

// BAD: classic value object boilerplate when record suffices
public final class Money {
    private final BigDecimal amount;
    private final Currency currency;
    // ... 30 lines of constructor, getters, equals, hashCode, toString
}
```

### Immutable Collections

**Always use immutable collection factories for collections that should not change.**

```java
// GOOD: immutable from the start
List<String> roles = List.of("admin", "editor");
Map<String, Integer> config = Map.of("timeout", 30, "retries", 3);
Set<Status> terminal = Set.of(Status.COMPLETE, Status.FAILED, Status.CANCELLED);

// GOOD: copy of mutable input to create immutable output
public List<User> getUsers() {
    return List.copyOf(this.users);  // defensive copy
}

// BAD: mutable when immutable would do
List<String> roles = new ArrayList<>(Arrays.asList("admin", "editor"));

// BAD: returning internal mutable collection
public List<User> getUsers() {
    return this.users;  // caller can mutate internal state
}
```

## Modern Java (up to Java 17)

### Records (Java 16)

See Immutability section above. Key rules:
- Use records for data transfer objects, value objects, and method return bundles
- Add validation in the compact constructor
- Records can implement interfaces but not extend classes
- Avoid mutable fields in records (use `List.copyOf` in compact constructor if needed)

### Sealed Classes (Java 17)

**Use sealed classes/interfaces to model closed type hierarchies.** Pairs well with pattern matching.

```java
// GOOD: sealed hierarchy for result types
public sealed interface PaymentResult
        permits PaymentResult.Success, PaymentResult.Declined, PaymentResult.Error {

    record Success(String transactionId, BigDecimal amount) implements PaymentResult { }
    record Declined(String reason) implements PaymentResult { }
    record Error(String message, Throwable cause) implements PaymentResult { }
}

// Dispatch on type using if-instanceof (Java 17 GA)
String describe(PaymentResult result) {
    if (result instanceof PaymentResult.Success s) {
        return "Charged " + s.amount();
    } else if (result instanceof PaymentResult.Declined d) {
        return "Declined: " + d.reason();
    } else if (result instanceof PaymentResult.Error e) {
        return "Error: " + e.message();
    } else {
        throw new IllegalStateException("Unknown PaymentResult: " + result);
    }
}

// Note: Pattern matching in switch expressions (exhaustive type dispatch) is available GA from Java 21.
```

### Pattern Matching for instanceof (Java 16)

**Always use pattern matching instead of cast-after-instanceof.**

```java
// GOOD: pattern matching
if (obj instanceof String s) {
    System.out.println(s.toUpperCase());  // s is String in this scope
}

// BAD: old-style cast
if (obj instanceof String) {
    String s = (String) obj;  // redundant cast
    System.out.println(s.toUpperCase());
}
```

### Text Blocks (Java 15)

**Use text blocks for multi-line strings: SQL, JSON, HTML.**

```java
// GOOD: text block for SQL
String sql = """
        SELECT u.id, u.email, u.name
        FROM users u
        WHERE u.active = true
          AND u.created_at > :since
        ORDER BY u.name
        """;

// GOOD: text block for JSON template
String json = """
        {
            "type": "event",
            "name": "%s",
            "timestamp": "%s"
        }
        """.formatted(event.name(), event.timestamp());

// BAD: string concatenation for multi-line content
String sql = "SELECT u.id, u.email " +
             "FROM users u " +
             "WHERE u.active = true";
```

The closing `"""` determines the indentation baseline; align it with the content.

### Switch Expressions (Java 14)

**Prefer switch expressions over switch statements. Use arrow syntax.**

```java
// GOOD: switch expression, exhaustive, no fall-through
int days = switch (month) {
    case JANUARY, MARCH, MAY, JULY, AUGUST, OCTOBER, DECEMBER -> 31;
    case APRIL, JUNE, SEPTEMBER, NOVEMBER -> 30;
    case FEBRUARY -> java.time.Year.isLeap(year) ? 29 : 28;
};

// GOOD: switch expression with blocks
String label = switch (status) {
    case PENDING -> "Awaiting processing";
    case PROCESSING -> {
        log.debug("Processing order {}", orderId);
        yield "In progress";
    }
    case COMPLETE -> "Done";
    case FAILED -> "Failed";
};

// BAD: switch statement with fall-through
String label;
switch (status) {
    case PENDING:
        label = "Awaiting processing";
        break;
    case COMPLETE:
        label = "Done";
        break;
    // ...
}
```

### Local Variable Type Inference - var (Java 10)

**Use `var` for local variables when the type is obvious from the right-hand side.**

```java
// GOOD: type obvious from constructor
var service = new UserService(repository, emailService);
var results = new ArrayList<ProcessingResult>();

// GOOD: type obvious from method name and context
var users = userRepository.findAll();

// BAD: type not obvious
var x = process(data);  // what type is x?
var result = compute();

// BAD: var on primitives (no benefit, adds noise)
var count = 0;   // just write: int count = 0;
var flag = true; // just write: boolean flag = true;

// NEVER use var for fields (only local variables)
```

## Optional

### When to Use Optional

**Use `Optional<T>` as a return type when a method might not return a value.** Do NOT use it for fields, method parameters, or collections.

```java
// GOOD: Optional return type
public Optional<User> findById(String id) {
    return Optional.ofNullable(repository.get(id));
}

// GOOD: consuming Optional
findById(userId)
    .map(User::email)
    .ifPresent(emailService::sendWelcome);

// GOOD: providing a default
String name = findById(userId)
    .map(User::name)
    .orElse("Anonymous");

// BAD: Optional field
private Optional<String> middleName;  // use String middleName (nullable field, document the contract)

// BAD: Optional parameter
void process(Optional<String> name) { }  // use overloads or accept null with a null check

// BAD: Optional in collections
List<Optional<User>> users;  // filter nulls instead
```

### Anti-Patterns

```java
// BAD: isPresent/get instead of map/orElse
if (opt.isPresent()) {
    return opt.get().getName();
} else {
    return "unknown";
}

// GOOD: use map and orElse
return opt.map(User::getName).orElse("unknown");

// BAD: creating Optional.of with null (throws NullPointerException)
Optional.of(value);       // use Optional.ofNullable(value)

// BAD: Optional.get() without check
opt.get();  // throws NoSuchElementException; always use orElse/orElseGet/orElseThrow
```

## Streams

### When to Use Streams vs Loops

**Streams excel at collection transformations. Loops are clearer for stateful, sequential, or early-exit logic.**

```java
// GOOD: stream for transformation pipeline (assuming User is a record)
List<String> activeEmails = users.stream()
    .filter(User::isActive)
    .map(User::email)
    .sorted()
    .toList();  // Java 16+, returns unmodifiable list

// GOOD: loop for complex stateful logic
int runningTotal = 0;
for (Order order : orders) {
    runningTotal += order.amount();
    if (runningTotal > limit) {
        throw new LimitExceededException(limit);
    }
}

// BAD: stream when loop is clearer
OptionalInt firstOver = IntStream.range(0, orders.size())
    .filter(i -> orders.get(i).amount() > threshold)
    .findFirst();
// Just use a loop with early return here
```

### Side Effects in Streams

**Avoid side effects in stream operations. Streams are declarative pipelines.**

```java
// BAD: side effect in stream
List<String> names = new ArrayList<>();
users.stream()
    .filter(User::isActive)
    .forEach(u -> names.add(u.name()));  // mutation in stream

// GOOD: collect instead
List<String> names = users.stream()
    .filter(User::isActive)
    .map(User::name)
    .collect(Collectors.toList());  // or .toList() (Java 16+)
```

### Common Collectors

```java
// Collect to list (unmodifiable, Java 16+)
.toList()

// Collect to list (mutable)
.collect(Collectors.toList())

// Collect to set
.collect(Collectors.toSet())

// Group by key
Map<Department, List<Employee>> byDept =
    employees.stream()
        .collect(Collectors.groupingBy(Employee::department));

// Join strings
String csv = names.stream().collect(Collectors.joining(", "));

// Counting
long count = users.stream().filter(User::isActive).count();
```

## Exception Handling

### Checked vs Unchecked

**Throw unchecked exceptions (RuntimeException) for programming errors and unrecoverable conditions. Use checked exceptions only for recoverable conditions callers are expected to handle.**

```java
// GOOD: unchecked for programming errors
if (id == null) {
    throw new IllegalArgumentException("id must not be null");
}

// GOOD: unchecked for unrecoverable conditions
throw new IllegalStateException("connection pool exhausted");

// GOOD: checked when caller can and should recover
public byte[] readFile(Path path) throws IOException {
    return Files.readAllBytes(path);
}
```

### try-with-resources

**Always use try-with-resources for AutoCloseable resources.**

```java
// GOOD: try-with-resources
try (var connection = dataSource.getConnection();
     var statement = connection.prepareStatement(sql)) {
    statement.setString(1, userId);
    try (var rs = statement.executeQuery()) {
        return rs.next() ? mapUser(rs) : Optional.empty();
    }
}

// BAD: manual finally block
Connection connection = null;
try {
    connection = dataSource.getConnection();
    // ...
} finally {
    if (connection != null) {
        try { connection.close(); } catch (SQLException ignored) { }
    }
}
```

### Don't Swallow Exceptions

```java
// BAD: swallowing exception
try {
    processOrder(order);
} catch (Exception e) {
    // silently ignored
}

// BAD: logging without rethrowing when caller needs to know
try {
    processOrder(order);
} catch (Exception e) {
    log.error("Failed", e);
    // caller thinks it succeeded
}

// GOOD: handle or propagate
try {
    processOrder(order);
} catch (PaymentException e) {
    log.warn("Payment failed for order {}: {}", order.id(), e.getMessage());
    throw new OrderProcessingException("Payment failed", e);
}
```

### Catch Specific Types

```java
// BAD: catching broad exception types
try {
    riskyOperation();
} catch (Exception e) { ... }  // too broad — swallows programming errors

// GOOD: catch what you can handle
try {
    riskyOperation();
} catch (IOException e) {
    handleIo(e);
} catch (TimeoutException e) {
    retry();
}
```

## Generics

### Never Use Raw Types

```java
// BAD: raw types lose type safety
List list = new ArrayList();
list.add("hello");
list.add(42);  // compiles, fails at runtime

// GOOD: always parameterize
List<String> list = new ArrayList<>();
```

### Wildcards

**Use bounded wildcards to increase API flexibility.**

```java
// GOOD: producer extends (PECS principle)
// "I only read from this collection"
double sum(List<? extends Number> numbers) {
    return numbers.stream().mapToDouble(Number::doubleValue).sum();
}

// GOOD: consumer super
// "I only write to this collection"
void addNumbers(List<? super Integer> dest, int count) {
    for (int i = 0; i < count; i++) {
        dest.add(i);
    }
}

// Rule of thumb: PECS - Producer Extends, Consumer Super
```

### Avoid Unchecked Casts

```java
// BAD: unchecked cast
@SuppressWarnings("unchecked")
List<String> list = (List<String>) rawList;

// GOOD: use typed APIs or redesign to avoid cast
```

## Enums

### Prefer Enums Over Int Constants

```java
// BAD: int constants (no type safety, no documentation)
public static final int STATUS_PENDING = 0;
public static final int STATUS_ACTIVE = 1;
public static final int STATUS_CLOSED = 2;

// GOOD: enum
public enum OrderStatus {
    PENDING, ACTIVE, CLOSED
}
```

### Enums with Fields and Methods

```java
// GOOD: enums can carry data and behavior
public enum Planet {
    MERCURY(3.303e+23, 2.4397e6),
    VENUS(4.869e+24, 6.0518e6),
    EARTH(5.976e+24, 6.37814e6);

    private static final double G = 6.67300E-11;  // gravitational constant

    private final double mass;   // in kilograms
    private final double radius; // in meters

    Planet(double mass, double radius) {
        this.mass = mass;
        this.radius = radius;
    }

    double surfaceGravity() {
        return G * mass / (radius * radius);
    }
}
```

### Switch Exhaustiveness

**Switch on enums (and sealed classes) should cover all cases. Use default only when you genuinely want a fallback.**

```java
// GOOD: exhaustive, compiler warns if new values added and no default
String describe(OrderStatus status) {
    return switch (status) {
        case PENDING -> "Awaiting processing";
        case ACTIVE -> "In progress";
        case CLOSED -> "Completed";
    };
}

// Only add default if you explicitly want to handle unknowns:
return switch (status) {
    case PENDING -> "Awaiting";
    case ACTIVE -> "Active";
    default -> "Other: " + status.name();
};
```

## Collections

### Prefer Interface Types in Declarations

**Declare fields and variables using the interface type, not the implementation.**

```java
// GOOD: interface types
List<User> users = new ArrayList<>();
Map<String, Order> ordersByKey = new HashMap<>();
Set<Permission> permissions = new HashSet<>();

// BAD: implementation types
ArrayList<User> users = new ArrayList<>();
HashMap<String, Order> ordersByKey = new HashMap<>();
```

### Immutable Collection Factories

```java
// List.of, Map.of, Set.of - all throw NullPointerException on null elements
List<String> statuses = List.of("PENDING", "ACTIVE", "CLOSED");
Set<String> reserved = Set.of("admin", "root", "system");
Map<String, Integer> limits = Map.of("daily", 100, "monthly", 2000);

// For >10 entries in a map, use Map.ofEntries
Map<String, String> codes = Map.ofEntries(
    Map.entry("en", "English"),
    Map.entry("fr", "French"),
    Map.entry("de", "German")
);

// To copy (and make unmodifiable)
List<User> snapshot = List.copyOf(mutableList);
```

### Iterating

```java
// GOOD: enhanced for loop
for (User user : users) {
    process(user);
}

// GOOD: stream when transforming
users.stream().filter(User::isActive).forEach(this::notify);

// BAD: index-based loop when not needed
for (int i = 0; i < users.size(); i++) {
    process(users.get(i));
}

// GOOD: index-based loop when index matters
for (int i = 0; i < items.size(); i++) {
    items.get(i).setPosition(i);
}
```

## Sharp Edges

Runtime hazards. Know these cold.

### == vs .equals()

**Never use `==` to compare objects. Only use `==` for primitives and null checks.**

```java
// CORRECT: null check with ==
if (value == null) { ... }

// CORRECT: primitive comparison
if (count == 0) { ... }

// CORRECT: object comparison
if (name.equals("admin")) { ... }
if (Objects.equals(a, b)) { ... }  // null-safe

// WRONG: object identity instead of equality
String a = new String("hello");
String b = new String("hello");
a == b;        // false (different objects)
a.equals(b);   // true (same content)

// TRICKY: string literals may be interned (== works by accident)
"hello" == "hello"   // true (both interned)
// Don't rely on this. Always use .equals() for strings.
```

### Integer Caching

**Integer values -128 to 127 are cached; == works by accident. Outside that range, == fails.**

```java
Integer a = 127;
Integer b = 127;
a == b;   // true (cached)

Integer x = 128;
Integer y = 128;
x == y;   // false (not cached)

// Always use .equals() or .intValue() == .intValue() for Integer comparison
x.equals(y);       // true
x.intValue() == y.intValue();  // true
```

### Never Use float or double for Money

**IEEE 754 floating-point is imprecise. Use `BigDecimal` for all currency and financial calculations.**

```java
// WRONG: precision errors compound
double price = 0.1 + 0.2;  // 0.30000000000000004

// CORRECT: BigDecimal with string constructor
BigDecimal price = new BigDecimal("0.10").add(new BigDecimal("0.20"));
// price.equals(new BigDecimal("0.30")) -> true

// WRONG: BigDecimal from double (inherits the imprecision)
new BigDecimal(0.1)  // 0.1000000000000000055511151231257827021181583404541015625

// CORRECT: always construct BigDecimal from String or long
new BigDecimal("0.1")
BigDecimal.valueOf(1, 1)   // 0.1
```

### NullPointerException

**Fail fast on null inputs. Return Optional instead of null from public APIs.**

```java
// GOOD: validate null inputs early
public void process(Order order) {
    Objects.requireNonNull(order, "order must not be null");
    // ...
}

// GOOD: Optional for absent values
public Optional<User> findByEmail(String email) {
    return Optional.ofNullable(store.get(email));
}

// BAD: silently accepting null and failing later
public void process(Order order) {
    order.validate();  // NullPointerException if order is null
}
```

### Math.abs of Integer.MIN_VALUE

**`Math.abs(Integer.MIN_VALUE)` returns a negative number.**

```java
Integer.MIN_VALUE        // -2147483648
Math.abs(Integer.MIN_VALUE)  // -2147483648 (overflow!)
Math.abs(Long.MIN_VALUE)     // same problem

// If you need absolute value of arbitrary integers, check first:
if (value == Integer.MIN_VALUE) throw new ArithmeticException("no positive counterpart");
```

### Integer Overflow

**Java int arithmetic wraps silently on overflow.**

```java
int max = Integer.MAX_VALUE;
max + 1;   // -2147483648 (wraps to MIN_VALUE, no exception)

// Use Math.addExact, Math.multiplyExact etc. to detect overflow:
Math.addExact(max, 1);  // throws ArithmeticException

// Or use long for calculations that may exceed int range
long result = (long) a * b;
```

### String Concatenation in Loops

**Don't concatenate Strings in loops. Use StringBuilder.**

```java
// BAD: O(n^2) - creates new String object each iteration
String result = "";
for (String item : items) {
    result += item + ", ";
}

// GOOD: StringBuilder
StringBuilder sb = new StringBuilder();
for (String item : items) {
    sb.append(item).append(", ");
}
String result = sb.toString();

// GOOD: String.join or Collectors.joining for simple cases
String result = String.join(", ", items);
String result = items.stream().collect(Collectors.joining(", "));
```

### Mutable Collections Returned from Methods

**Never return a reference to an internal mutable collection.**

```java
// BAD: caller can mutate internal state
public class UserCache {
    private final List<User> users = new ArrayList<>();

    public List<User> getUsers() {
        return users;  // caller can call users.clear()!
    }
}

// GOOD: return unmodifiable view or copy
public List<User> getUsers() {
    return Collections.unmodifiableList(users);  // view, no copy
}

public List<User> getUsers() {
    return List.copyOf(users);  // defensive copy
}
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using `==` for object comparison | Use `.equals()` or `Objects.equals()` |
| `new BigDecimal(0.1)` | Use `new BigDecimal("0.1")` |
| `double`/`float` for money | Use `BigDecimal` |
| Returning mutable internal collections | Return `List.copyOf()` or `Collections.unmodifiableList()` |
| Catching `Exception` or `Throwable` | Catch specific exception types |
| Manual resource cleanup in `finally` | Use try-with-resources |
| Raw types (`List`, `Map`) | Always parameterize generics |
| Null return from public API | Return `Optional<T>` |
| `Optional.get()` without check | Use `.orElse()`, `.orElseGet()`, `.orElseThrow()` |
| `Optional` as field or parameter | Only use Optional as return type |
| String concatenation in loops | Use `StringBuilder` or `Collectors.joining` |
| `instanceof` with manual cast | Use pattern matching: `instanceof Foo f` |
| Verbose switch statement with fall-through | Use switch expression with arrow syntax |
| Classic value object boilerplate | Use `record` |
| Public mutable fields | Use private final with constructor injection |
| Missing Javadoc on public API | Add Javadoc with contract information |
| `I` prefix on interfaces | Just name the interface (no `IFoo`) |
| `Impl` suffix as default | Name by implementation strategy (`JpaFoo`) |
| `Math.abs(Integer.MIN_VALUE)` without guard | Use `Math.addExact` or check first |
| Integer overflow without detection | Use `Math.addExact`/`multiplyExact` |

## Red Flags

**STOP and refactor when you see:**

- `double` or `float` variable named `price`, `amount`, `total`, `cost`, or `balance`
- `==` between non-primitive, non-null types
- `catch (Exception e)` or `catch (Throwable t)` in business logic
- Empty catch block or catch that only logs without propagating
- `finally { resource.close() }` (use try-with-resources)
- Raw types: `List list`, `Map map`, `Set set`
- Public non-final mutable fields
- Method returning `null` instead of `Optional` or throwing
- `Optional.get()` without a preceding `isPresent()` or use of `.orElse`
- `Optional` used as a field type or method parameter
- `new ArrayList<>()` for a collection that never changes (use `List.of`)
- `getUsers()` returning `this.users` directly (internal list exposure)
- `instanceof` check immediately followed by a cast on the next line (use pattern matching)
- Switch statement with `case X: ... break;` (use switch expression)
- Class with no fields except one method (use a static method or functional interface)
- `I` prefix on interface names
- Missing `@Override` annotation on overridden methods
