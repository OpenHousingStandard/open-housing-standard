#!/usr/bin/env python3
"""Placeholder for future FreeCAD/IFC export automation."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    print("IFC generation is not implemented yet.")
    print("Future target: YAML -> FreeCAD -> IFC.")
    print(f"Repository: {ROOT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
