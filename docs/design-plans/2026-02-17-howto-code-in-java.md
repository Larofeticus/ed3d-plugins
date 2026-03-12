# Java House Style Design

## Summary

A new `howto-code-in-java` skill for the `ed3d-house-style` plugin providing comprehensive Java coding standards for the language as it stands at Java 17. Covers naming, Javadoc, code style, immutability, modern Java features, Optional, Streams, exception handling, generics, enums, collections, sharp edges, and common mistakes. Registered in all locations that enumerate language-specific skills. Plugin version bumped with changelog entry.

## Definition of Done

A new `howto-code-in-java/SKILL.md` skill in `ed3d-house-style` covering comprehensive Java programming style for the language as it stands at Java 17 (all features up to and including Java 17, nothing later). The skill covers naming conventions, Javadoc commenting, code style, immutability patterns, modern Java features, exception handling, sharp edges, common mistakes, and red flags. It does not duplicate content already covered by other house-style skills (FCIS, testing philosophy, property-based testing, defense-in-depth). The skill is registered in all locations that enumerate language-specific house style skills, and the plugin version is bumped with changelog entry.

## Acceptance Criteria

### howto-code-in-java.AC1 - Skill file exists with correct structure

**howto-code-in-java.AC1.1** - `plugins/ed3d-house-style/skills/howto-code-in-java/SKILL.md` exists with valid YAML frontmatter (`name: howto-code-in-java`, correct `description`, `user-invocable: false`)

**howto-code-in-java.AC1.2** - Skill covers all required topics: naming conventions, Javadoc, code style, immutability, modern Java features (≤17), Optional, Streams, exception handling, generics, enums, collections, sharp edges, Quick Self-Check, Common Mistakes table, Red Flags

**howto-code-in-java.AC1.3** - Skill does NOT duplicate content from `howto-functional-vs-imperative`, `writing-good-tests`, `property-based-testing`, or `defense-in-depth`

**howto-code-in-java.AC1.4** - Skill contains no Java features introduced after Java 17

### howto-code-in-java.AC2 - Skill registered in all skill lists

**howto-code-in-java.AC2.1** - `coding-effectively/SKILL.md` lists `howto-code-in-java` in the conditional sub-skills section

**howto-code-in-java.AC2.2** - `code-reviewer.md` lists Java in the language-specific skills section

**howto-code-in-java.AC2.3** - `task-implementor-fast.md` references Java skill alongside other language skills

**howto-code-in-java.AC2.4** - `task-bug-fixer.md` references Java skill alongside other language skills

### howto-code-in-java.AC3 - Plugin versioning updated

**howto-code-in-java.AC3.1** - `plugins/ed3d-house-style/.claude-plugin/plugin.json` version bumped

**howto-code-in-java.AC3.2** - `.claude-plugin/marketplace.json` ed3d-house-style version matches plugin.json

**howto-code-in-java.AC3.3** - `CHANGELOG.md` has entry for the new version describing the Java skill addition

## Architecture

### Skill Structure

The skill follows the `howto-code-in-typescript` model: comprehensive, section-per-topic, with GOOD/BAD code examples. Sections:

1. **YAML frontmatter** — name, description, user-invocable: false
2. **Overview** — core principles (Java-specific, not FCIS/testing which live elsewhere)
3. **Quick Self-Check** — checklist for use under pressure
4. **Naming Conventions** — packages, classes, interfaces, methods, fields, constants, generics, booleans
5. **Javadoc** — when to write, format, what to omit
6. **Code Style** — braces, indentation, member ordering, line length
7. **Immutability** — final fields, records, immutable collection factories, defensive copies
8. **Modern Java (≤17)** — records, sealed classes, pattern matching instanceof, text blocks, switch expressions, var
9. **Optional** — correct use, anti-patterns
10. **Streams** — when to use vs loops, collecting, side-effect avoidance
11. **Exception Handling** — checked vs unchecked, try-with-resources, don't swallow
12. **Generics** — no raw types, bounded wildcards, variance
13. **Enums** — over int constants, fields/methods on enums, switch exhaustiveness
14. **Collections** — prefer interfaces, immutable factories, Map.Entry patterns
15. **Sharp Edges** — == vs equals, Integer caching, NPE, float/double for money, Math.abs(MIN_VALUE), integer overflow, string interning
16. **Common Mistakes** — table format
17. **Red Flags** — stop-and-refactor list

### Registration Locations

| File | Change |
|------|--------|
| `plugins/ed3d-house-style/skills/coding-effectively/SKILL.md` | Add `howto-code-in-java` to conditional sub-skills list |
| `plugins/ed3d-plan-and-execute/agents/code-reviewer.md` | Add Java to language-specific review list |
| `plugins/ed3d-plan-and-execute/agents/task-implementor-fast.md` | Add Java skill to language-specific examples |
| `plugins/ed3d-plan-and-execute/agents/task-bug-fixer.md` | Add Java skill to language-specific examples |
| `plugins/ed3d-house-style/.claude-plugin/plugin.json` | Bump version 1.1.0 -> 1.2.0 |
| `.claude-plugin/marketplace.json` | Bump ed3d-house-style to 1.2.0 |
| `CHANGELOG.md` | Add entry for ed3d-house-style 1.2.0 |

### Content Boundaries

What this skill covers vs. other skills:

| Topic | This skill | Other skill |
|-------|-----------|-------------|
| FCIS pattern | Cross-reference only | `howto-functional-vs-imperative` |
| Test philosophy | Cross-reference only | `writing-good-tests` |
| Property-based testing | Not mentioned | `property-based-testing` |
| Validate at all layers | Not mentioned | `defense-in-depth` |
| Currency arithmetic | BigDecimal required (Java-specific) | — |
| HPC/parallelism | Not mentioned | `hpc-cpp-guidelines` |

## Implementation Phases

### Phase 1: Create the skill file

Create `plugins/ed3d-house-style/skills/howto-code-in-java/SKILL.md` with all sections per the architecture above.

Verification: File exists, UTF-8 clean, YAML frontmatter valid, all 17 sections present.

### Phase 2: Register skill in all lists

Update `coding-effectively/SKILL.md`, `code-reviewer.md`, `task-implementor-fast.md`, `task-bug-fixer.md`.

Verification: Each file contains `howto-code-in-java` reference.

### Phase 3: Bump version and update changelog

Update `plugin.json`, `marketplace.json`, `CHANGELOG.md`.

Verification: Both JSON files have matching version 1.2.0, CHANGELOG has entry at top.

## Glossary

- **LTS** - Long-Term Support. Java 17 is an LTS release, making it the standard baseline for production Java.
- **Record** - Java 16+ immutable data carrier class with auto-generated constructor, accessors, equals, hashCode, toString.
- **Sealed class** - Java 17 class/interface that restricts which other classes may extend/implement it.
- **Pattern matching** - Java 16+ `instanceof` enhancement that combines type check and cast: `if (obj instanceof String s)`.
- **Text block** - Java 15+ multi-line string literal using triple-quote delimiters.
- **var** - Java 10+ local variable type inference keyword.
- **Optional** - Java 8+ container object used to represent a value that may or may not be present.
