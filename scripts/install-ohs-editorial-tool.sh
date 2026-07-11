#!/usr/bin/env bash
set -euo pipefail

# install-ohs-editorial-tool.sh
#
# Installs a permanent editorial checker/fixer:
#
#   uv run ohs-editorial --check
#   uv run ohs-editorial --fix
#
# The tool validates and safely normalizes Markdown in standard/OHS-001.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[!] Run this script inside the OHS Git repository."
  exit 1
fi

mkdir -p src/ohs tests/editorial docs/project

cat > src/ohs/editorial.py <<'PY'
from __future__ import annotations

import argparse
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import yaml

NORMATIVE_KEYWORDS = (
    "MUST NOT",
    "SHALL NOT",
    "SHOULD NOT",
    "REQUIRED",
    "RECOMMENDED",
    "OPTIONAL",
    "MUST",
    "SHALL",
    "SHOULD",
    "MAY",
)

DUPLICATE_METADATA_LINES = (
    re.compile(r"^\*\*Status:\*\*\s+.+$"),
    re.compile(r"^\*\*Version:\*\*\s+.+$"),
    re.compile(r"^\*\*Normative\*\*$"),
    re.compile(r"^\*\*Informative\*\*$"),
)


@dataclass
class Finding:
    path: Path
    message: str
    fixable: bool


@dataclass
class EditorialResult:
    findings: list[Finding] = field(default_factory=list)
    changed: list[Path] = field(default_factory=list)

    @property
    def errors(self) -> int:
        return len(self.findings)


def split_frontmatter(text: str) -> tuple[dict[str, Any], str]:
    if not text.startswith("---\n"):
        return {}, text

    end = text.find("\n---\n", 4)
    if end == -1:
        raise ValueError("Unterminated YAML frontmatter.")

    metadata = yaml.safe_load(text[4:end]) or {}
    if not isinstance(metadata, dict):
        raise ValueError("YAML frontmatter must be a mapping.")

    body = text[end + 5 :].removeprefix("\n")
    return metadata, body


def dump_frontmatter(metadata: dict[str, Any]) -> str:
    rendered = yaml.safe_dump(
        metadata,
        allow_unicode=True,
        sort_keys=False,
        default_flow_style=False,
        width=100,
    ).rstrip()
    return f"---\n{rendered}\n---\n\n"


def is_informative(metadata: dict[str, Any]) -> bool:
    value = metadata.get("Normative")
    if isinstance(value, bool):
        return not value
    return str(value).strip().lower() in {"no", "false", "informative"}


def demote_normative_keywords(text: str) -> str:
    """Lowercase RFC 2119 keywords outside fenced code blocks."""

    lines = text.splitlines()
    in_fence = False
    result: list[str] = []

    for line in lines:
        stripped = line.lstrip()
        if stripped.startswith("```"):
            in_fence = not in_fence
            result.append(line)
            continue

        if not in_fence:
            for keyword in NORMATIVE_KEYWORDS:
                line = re.sub(
                    rf"\b{re.escape(keyword)}\b",
                    keyword.lower(),
                    line,
                )

        result.append(line)

    return "\n".join(result)


def remove_duplicate_metadata_lines(text: str) -> str:
    lines = text.splitlines()
    result: list[str] = []
    skip_rule_after_badge = False

    for line in lines:
        if any(pattern.match(line) for pattern in DUPLICATE_METADATA_LINES):
            skip_rule_after_badge = True
            continue

        if skip_rule_after_badge and line.strip() == "---":
            skip_rule_after_badge = False
            continue

        if line.strip():
            skip_rule_after_badge = False

        result.append(line)

    return "\n".join(result)


def normalize_subheadings(text: str) -> str:
    """Convert numbered subsection H1 headings to H2."""

    lines = text.splitlines()
    result: list[str] = []

    for line in lines:
        if re.match(r"^# (?:\d+\.\d+|[A-Z]\.\d+)\b", line):
            line = "#" + line
        result.append(line)

    return "\n".join(result)


def normalize_whitespace(text: str) -> str:
    lines = [line.rstrip() for line in text.splitlines()]

    compacted: list[str] = []
    blank_count = 0
    for line in lines:
        if line == "":
            blank_count += 1
            if blank_count > 2:
                continue
        else:
            blank_count = 0
        compacted.append(line)

    return "\n".join(compacted).rstrip() + "\n"


def h1_count(text: str) -> int:
    return sum(1 for line in text.splitlines() if re.match(r"^# [^#]", line))


def find_normative_keywords(text: str) -> list[str]:
    """Find RFC 2119 keywords outside fenced code blocks."""

    found: list[str] = []
    in_fence = False

    for line in text.splitlines():
        stripped = line.lstrip()
        if stripped.startswith("```"):
            in_fence = not in_fence
            continue

        if in_fence:
            continue

        for keyword in NORMATIVE_KEYWORDS:
            if re.search(rf"\b{re.escape(keyword)}\b", line):
                found.append(keyword)

    return sorted(set(found))


def inspect_file(path: Path, fix: bool) -> tuple[list[Finding], bool]:
    findings: list[Finding] = []

    original = path.read_text(encoding="utf-8")

    try:
        metadata, body = split_frontmatter(original)
    except (ValueError, yaml.YAMLError) as exc:
        return [Finding(path, str(exc), False)], False

    if not metadata:
        findings.append(Finding(path, "Missing YAML frontmatter.", False))
        return findings, False

    normalized = body

    if any(
        pattern.match(line)
        for line in body.splitlines()
        for pattern in DUPLICATE_METADATA_LINES
    ):
        findings.append(
            Finding(path, "Contains duplicate visible metadata lines.", True)
        )
        if fix:
            normalized = remove_duplicate_metadata_lines(normalized)

    before_headings = normalized
    normalized = normalize_subheadings(normalized)
    if normalized != before_headings:
        findings.append(
            Finding(path, "Contains subsection headings at H1 level.", True)
        )

    if is_informative(metadata):
        keywords = find_normative_keywords(normalized)
        if keywords:
            findings.append(
                Finding(
                    path,
                    "Informative document contains RFC 2119 keywords: "
                    + ", ".join(keywords),
                    True,
                )
            )
            if fix:
                normalized = demote_normative_keywords(normalized)

    whitespace_normalized = normalize_whitespace(normalized)
    if whitespace_normalized != normalized:
        findings.append(
            Finding(path, "Whitespace or final newline is inconsistent.", True)
        )
        normalized = whitespace_normalized

    if h1_count(normalized) != 1:
        findings.append(
            Finding(
                path,
                f"Expected exactly one H1 heading, found {h1_count(normalized)}.",
                False,
            )
        )

    updated = dump_frontmatter(metadata) + normalized

    changed = updated != original
    if changed and fix:
        path.write_text(updated, encoding="utf-8")

    return findings, changed


def process(root: Path, fix: bool) -> EditorialResult:
    result = EditorialResult()
    directory = root / "standard" / "OHS-001"

    if not directory.exists():
        result.findings.append(
            Finding(directory, "standard/OHS-001 is missing.", False)
        )
        return result

    files = sorted(
        path
        for path in directory.glob("*.md")
        if path.name not in {"README.md", "CHANGELOG.md"}
    )

    for path in files:
        findings, changed = inspect_file(path, fix)
        result.findings.extend(findings)
        if changed and fix:
            result.changed.append(path)

    return result


def discover_root() -> Path:
    current = Path.cwd().resolve()
    for candidate in (current, *current.parents):
        if (candidate / ".git").exists() and (candidate / "pyproject.toml").exists():
            return candidate
    raise SystemExit("Run inside the Open Housing Standard repository.")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="ohs-editorial",
        description="Check or fix OHS editorial consistency.",
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--check", action="store_true")
    group.add_argument("--fix", action="store_true")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    root = discover_root()
    result = process(root, fix=args.fix)

    if result.findings:
        for finding in result.findings:
            relative = finding.path.relative_to(root)
            label = "FIXABLE" if finding.fixable else "ERROR"
            print(f"{label}: {relative}: {finding.message}")
    else:
        print("Editorial checks passed.")

    if result.changed:
        print("\nUpdated:")
        for path in result.changed:
            print(f"  - {path.relative_to(root)}")

    if result.findings and not args.fix:
        raise SystemExit(1)

    unfixable = [finding for finding in result.findings if not finding.fixable]
    if unfixable:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
PY

python - <<'PY'
from pathlib import Path

path = Path("pyproject.toml")
text = path.read_text(encoding="utf-8")
entry = 'ohs-editorial = "ohs.editorial:main"'

if entry not in text:
    if "[project.scripts]" in text:
        marker = "[project.scripts]"
        before, after = text.split(marker, 1)
        text = before + marker + "\n" + entry + "\n" + after.lstrip("\n")
    else:
        text = text.rstrip() + "\n\n[project.scripts]\n" + entry + "\n"

    path.write_text(text, encoding="utf-8")
    print("[+] Added ohs-editorial to pyproject.toml")
else:
    print("[=] ohs-editorial already configured")
PY

cat > tests/editorial/test_editorial.py <<'PY'
from ohs.editorial import (
    demote_normative_keywords,
    h1_count,
    normalize_subheadings,
    remove_duplicate_metadata_lines,
)


def test_demotes_keywords_in_informative_text() -> None:
    source = "References SHOULD include a version and SHALL NOT be ambiguous."
    result = demote_normative_keywords(source)

    assert "SHOULD" not in result
    assert "SHALL NOT" not in result
    assert "should" in result
    assert "shall not" in result


def test_preserves_keywords_inside_code_fence() -> None:
    source = "```text\nSHALL\n```\nOutside SHOULD."
    result = demote_normative_keywords(source)

    assert "SHALL" in result
    assert "Outside should." in result


def test_removes_duplicate_visible_metadata() -> None:
    source = "**Status:** Draft\n\n**Normative**\n\n---\n\n# 8. Governance\n"
    result = remove_duplicate_metadata_lines(source)

    assert "**Status:**" not in result
    assert "**Normative**" not in result


def test_normalizes_subsection_h1() -> None:
    source = "# 8. Governance\n\n# 8.1 Purpose\n"
    result = normalize_subheadings(source)

    assert "# 8. Governance" in result
    assert "## 8.1 Purpose" in result


def test_counts_h1() -> None:
    assert h1_count("# Title\n\n## Section\n") == 1
PY

cat > docs/project/EDITORIAL.md <<'EOF'
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
EOF

echo "[*] Synchronizing environment..."
uv sync

echo "[*] Running editorial tests..."
uv run pytest tests/editorial

echo
echo "[✓] ohs-editorial installed."
echo
echo "Preview:"
echo "  uv run ohs-editorial --check"
echo
echo "Apply safe fixes:"
echo "  uv run ohs-editorial --fix"
echo
echo "Validate everything:"
echo "  uv run ruff format ."
echo "  uv run ruff check ."
echo "  uv run pytest"
echo "  uv run ohs-maintain --check"
echo "  uv run ohs-editorial --check"
echo "  uv run ohs-build-docs --strict"
