# Human Test Plan: howto-code-in-java

Generated from implementation plan: `docs/implementation-plans/2026-02-17-howto-code-in-java/`

All automated checks (AC1.1, AC1.2, AC2.1–AC2.4, AC3.1–AC3.3) passed. The two acceptance criteria below require human judgment and cannot be fully automated.

---

## Step 1: Open the Java skill file

Open and read the entire file:

```
plugins/ed3d-house-style/skills/howto-code-in-java/SKILL.md
```

---

## Step 2: AC1.3 — Confirm no content duplication with sibling skills

Open each sibling skill file:

- `plugins/ed3d-house-style/skills/howto-functional-vs-imperative/SKILL.md`
- `plugins/ed3d-house-style/skills/writing-good-tests/SKILL.md`
- `plugins/ed3d-house-style/skills/property-based-testing/SKILL.md`
- `plugins/ed3d-house-style/skills/defense-in-depth/SKILL.md`

For each sibling, verify the Java skill does not re-teach or substantially reproduce its content. Cross-references and brief mentions (e.g., "see `howto-functional-vs-imperative`") are acceptable.

**Pass condition:** No section in the Java skill teaches:
- The FCIS (Functional Core / Imperative Shell) pattern
- Test design philosophy (AAA, test isolation, mocking strategy)
- Property-based testing strategies (jqwik, shrinking, Arbitrary types)
- Defense-in-depth validation layering

Note: Automated checks confirmed no verbatim phrase matches. This human review catches semantically equivalent content expressed with different wording.

---

## Step 3: AC1.4 — Confirm the Modern Java section stays within Java 17

Read the `## Modern Java (up to Java 17)` section.

For each feature mentioned, confirm it was finalized (not preview) in Java 17 or earlier:

| Feature | GA Version | Expected result |
|---------|-----------|----------------|
| Records | Java 16 | PASS |
| Sealed classes | Java 17 | PASS |
| Pattern matching for `instanceof` | Java 16 | PASS |
| Text blocks | Java 15 | PASS |
| Switch expressions | Java 14 | PASS |
| Local variable type inference (`var`) | Java 10 | PASS |

Also verify the inline warning at the sealed-class dispatch example reads as a caution note (not teaching the feature):

> `// Note: Pattern matching in switch expressions (exhaustive type dispatch) is available GA from Java 21.`

**Pass condition:** Every feature and standard library API discussed is available and non-preview in Java 17 LTS. No feature released only in Java 18 or later is present elsewhere in the file.
