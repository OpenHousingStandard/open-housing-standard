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
