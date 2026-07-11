from pathlib import Path

from ohs.maintenance import Maintainer


def test_duplicate_chapter_detection(tmp_path: Path) -> None:
    directory = tmp_path / "standard" / "OHS-001"
    directory.mkdir(parents=True)
    (directory / "06-a.md").write_text("# 6. A\n", encoding="utf-8")
    (directory / "06-b.md").write_text("# 6. B\n", encoding="utf-8")

    duplicates = Maintainer._duplicate_chapter_numbers(directory)

    assert duplicates == {"06": ["06-a.md", "06-b.md"]}


def test_deep_merge_preserves_nested_values() -> None:
    merged = Maintainer._deep_merge(
        {"standard": {"version": "0.1.0"}, "principles": {"open": True}},
        {"defaults": {"floors": 1}},
    )

    assert merged["standard"]["version"] == "0.1.0"
    assert merged["principles"]["open"] is True
    assert merged["defaults"]["floors"] == 1
