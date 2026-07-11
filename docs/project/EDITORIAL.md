# OHS Editorial Rules

The normative editorial requirements are defined by OHS-000.

The following practical rules apply to OHS specification chapters:

- Every chapter uses YAML frontmatter.
- Every document contains exactly one H1 heading.
- Subsections use H2 or deeper headings.
- Informative documents do not use uppercase RFC 2119 keywords.
- Metadata is not duplicated in the visible document body.
- Rationale and examples do not introduce hidden requirements.
- Files end with one newline and contain no trailing whitespace.
- Normative requirements are concise, vendor-neutral, and testable.

Run:

```bash
uv run ohs-editorial --check
```

Safe automatic fixes can be applied with:

```bash
uv run ohs-editorial --fix
```
