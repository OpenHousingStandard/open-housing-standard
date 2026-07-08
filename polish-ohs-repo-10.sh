#!/usr/bin/env bash
set -euo pipefail

# polish-ohs-repo-10.sh
# Final repository polish for Open Housing Standard.
# Run from repository root.

if [ ! -f "README.md" ] || [ ! -d "standard" ] || [ ! -d "reference" ]; then
  echo "ERROR: Run this script from the open-housing-standard repository root." >&2
  exit 1
fi

echo "[*] Polishing OHS repository structure..."

# -----------------------------------------------------------------------------
# 1. Clean root: move project/manifest documents into docs/project
# -----------------------------------------------------------------------------
mkdir -p docs/project docs/checklists docs/images docs/reference docs/workflows docs/adr

move_if_exists() {
  local src="$1"
  local dst="$2"
  if [ -e "$src" ]; then
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ]; then
      echo "[=] Keeping existing $dst; removing duplicate $src"
      rm -rf "$src"
    else
      echo "[>] $src -> $dst"
      mv "$src" "$dst"
    fi
  fi
}

move_if_exists CHARTER.md docs/project/CHARTER.md
move_if_exists TENETS.md docs/project/TENETS.md
move_if_exists DESIGN_PHILOSOPHY.md docs/project/DESIGN_PHILOSOPHY.md
move_if_exists DECISIONS.md docs/project/DECISIONS.md
move_if_exists NON_GOALS.md docs/project/NON_GOALS.md

# Move checklists under docs.
if [ -d checklists ]; then
  echo "[>] checklists/ -> docs/checklists/"
  mkdir -p docs/checklists
  shopt -s dotglob nullglob
  for item in checklists/*; do
    base="$(basename "$item")"
    if [ -e "docs/checklists/$base" ]; then
      rm -rf "$item"
    else
      mv "$item" docs/checklists/
    fi
  done
  rmdir checklists 2>/dev/null || true
  shopt -u dotglob nullglob
fi

# Remove uv's default main.py if present.
if [ -f main.py ]; then
  echo "[-] Removing main.py (not needed for this repository)"
  rm main.py
fi

# -----------------------------------------------------------------------------
# 2. CAD / BIM directories
# -----------------------------------------------------------------------------
mkdir -p cad/freecad cad/blender cad/ifc cad/shared cad/templates
for d in cad/freecad cad/blender cad/ifc cad/shared cad/templates; do
  touch "$d/.gitkeep"
done

cat > cad/README.md <<'EOM'
# CAD and BIM Workspace

This directory contains shared CAD/BIM resources for Open Housing Standard.

- `freecad/` — FreeCAD source models and shared parametric components.
- `blender/` — Blender scenes and visualisation assets.
- `ifc/` — shared IFC exports and exchange models.
- `shared/` — reusable geometry, symbols and common resources.
- `templates/` — starter CAD/BIM templates.

Model-specific CAD files live under `reference/oh90`, `reference/oh120` and `reference/oh150`.
EOM

# -----------------------------------------------------------------------------
# 3. Config hierarchy
# -----------------------------------------------------------------------------
mkdir -p config/defaults config/materials config/windows config/doors config/wall-types

# Preserve existing defaults.yaml but add a clearer defaults index.
cat > config/README.md <<'EOM'
# Configuration

Global configuration used by OHS tools and reference models.

- `defaults/` — global OHS defaults.
- `materials/` — material definitions and lifecycle metadata.
- `windows/` — standard window families and dimensions.
- `doors/` — standard door families and dimensions.
- `wall-types/` — standard wall, roof and floor assemblies.

House-specific configuration belongs in `reference/<model>/config/house.yaml`.
EOM

touch config/defaults/.gitkeep config/materials/.gitkeep config/windows/.gitkeep config/doors/.gitkeep config/wall-types/.gitkeep

cat > config/defaults/ohs-defaults.yaml <<'EOM'
standard:
  name: Open Housing Standard
  version: 0.1.0
  status: draft

reference_models:
  - oh90
  - oh120
  - oh150

principles:
  local_first: true
  universal_design: true
  dry_wet_technical_separation: true
  open_formats: true
  repairability: true
EOM

cat > config/doors/standard-doors.yaml <<'EOM'
# Draft default door family for OHS reference models.
# Final dimensions must be verified by a qualified architect/building professional.
interior_accessible:
  clear_width_mm_min: 900
  threshold: none_or_low_accessible

exterior_main:
  clear_width_mm_min: 900
  threshold: accessible_weatherproof
EOM

cat > config/windows/standard-windows.yaml <<'EOM'
# Draft default window family for OHS reference models.
# Final sizes and U-values must be adapted to climate, facade and energy calculations.
default:
  glazing: triple
  openable: true
  standardized_sizes_required: true
EOM

cat > config/wall-types/standard-wall-types.yaml <<'EOM'
# Draft construction assemblies.
# These are placeholders, not approved construction drawings.
external_wall:
  type: timber_frame
  target: low_energy_tek17_or_better

internal_wall:
  type: lightweight_partition
  repairable: true
EOM

# -----------------------------------------------------------------------------
# 4. Schemas: extend beyond house/material/room
# -----------------------------------------------------------------------------
mkdir -p schemas
cat > schemas/door.schema.json <<'EOM'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://openhousingstandard.org/schemas/door.schema.json",
  "title": "OHS Door",
  "type": "object",
  "required": ["id", "type", "clear_width_mm"],
  "properties": {
    "id": { "type": "string" },
    "type": { "type": "string" },
    "clear_width_mm": { "type": "number", "minimum": 600 },
    "threshold": { "type": "string" },
    "notes": { "type": "string" }
  },
  "additionalProperties": true
}
EOM

cat > schemas/window.schema.json <<'EOM'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://openhousingstandard.org/schemas/window.schema.json",
  "title": "OHS Window",
  "type": "object",
  "required": ["id", "type"],
  "properties": {
    "id": { "type": "string" },
    "type": { "type": "string" },
    "width_mm": { "type": "number", "minimum": 100 },
    "height_mm": { "type": "number", "minimum": 100 },
    "glazing": { "type": "string" },
    "u_value": { "type": "number" },
    "notes": { "type": "string" }
  },
  "additionalProperties": true
}
EOM

cat > schemas/wall.schema.json <<'EOM'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://openhousingstandard.org/schemas/wall.schema.json",
  "title": "OHS Wall Assembly",
  "type": "object",
  "required": ["id", "type"],
  "properties": {
    "id": { "type": "string" },
    "type": { "type": "string" },
    "assembly": { "type": "array", "items": { "type": "string" } },
    "fire_rating": { "type": "string" },
    "sound_rating": { "type": "string" },
    "notes": { "type": "string" }
  },
  "additionalProperties": true
}
EOM

cat > schemas/README.md <<'EOM'
# Schemas

JSON Schemas for validating OHS configuration files.

The goal is to make the standard machine-readable enough that tools can validate
reference houses, generate documentation, and later export CAD/BIM data.
EOM

# -----------------------------------------------------------------------------
# 5. Source package skeleton for future generator/validator code
# -----------------------------------------------------------------------------
mkdir -p src/ohs
cat > src/ohs/__init__.py <<'EOM'
"""Open Housing Standard tooling package."""

__version__ = "0.1.0"
EOM

cat > src/ohs/config.py <<'EOM'
"""Configuration loading helpers for OHS tools."""

from __future__ import annotations

from pathlib import Path
from typing import Any

import yaml


def load_yaml(path: str | Path) -> dict[str, Any]:
    """Load a YAML file and return a dictionary."""
    with Path(path).open("r", encoding="utf-8") as handle:
        data = yaml.safe_load(handle) or {}
    if not isinstance(data, dict):
        raise TypeError(f"Expected mapping in {path}")
    return data
EOM

cat > src/ohs/validator.py <<'EOM'
"""Validation helpers for OHS reference models."""

from __future__ import annotations

from pathlib import Path

from .config import load_yaml


REQUIRED_FEATURES = {
    "universal_design",
    "technical_room",
    "wood_stove",
    "local_smart_home",
}


def validate_house_config(path: str | Path) -> list[str]:
    """Return a list of validation issues for a house config."""
    config = load_yaml(path)
    issues: list[str] = []

    if not config.get("name"):
        issues.append("Missing house name")
    if not config.get("gross_area_m2") and not config.get("area_m2"):
        issues.append("Missing gross_area_m2 or area_m2")

    features = config.get("features", {})
    if isinstance(features, dict):
        missing = sorted(feature for feature in REQUIRED_FEATURES if not features.get(feature))
        for feature in missing:
            issues.append(f"Missing required OHS feature: {feature}")

    return issues
EOM

cat > src/ohs/generator.py <<'EOM'
"""Placeholder for future OHS report/CAD generation logic."""

from __future__ import annotations


def project_name() -> str:
    return "Open Housing Standard"
EOM

cat > src/ohs/cad.py <<'EOM'
"""CAD/BIM integration placeholders.

Future work:
- Generate FreeCAD geometry from YAML.
- Export IFC.
- Generate SVG floor-plan previews.
"""

from __future__ import annotations
EOM

# Add package configuration if missing in pyproject.
if [ -f pyproject.toml ]; then
  python3 - <<'PY'
from pathlib import Path
p = Path('pyproject.toml')
text = p.read_text(encoding='utf-8')
if '[tool.uv]' not in text:
    text += '\n[tool.uv]\npackage = true\n'
if '[tool.ruff]' not in text:
    text += '''\n[tool.ruff]\nline-length = 100\ntarget-version = "py313"\n\n[tool.ruff.lint]\nselect = ["E", "F", "I", "UP", "B"]\n'''
if '[tool.pytest.ini_options]' not in text:
    text += '''\n[tool.pytest.ini_options]\npythonpath = ["src"]\ntestpaths = ["tests"]\n'''
p.write_text(text, encoding='utf-8')
PY
fi

# -----------------------------------------------------------------------------
# 6. ARCHITECTURE.md
# -----------------------------------------------------------------------------
cat > ARCHITECTURE.md <<'EOM'
# Architecture

Status: Draft  
Version: 0.1.0

This document describes the repository architecture for **Open Housing Standard (OHS)**.
It is about the project structure and toolchain, not the architectural design of a
specific house.

OHS is intentionally organized like a serious open source engineering project:
there is a standard, reference implementations, machine-readable configuration,
CAD/BIM assets, generated documentation and automated validation.

---

## Design goals

The repository should make it easy to:

1. Maintain the Open Housing Standard as a readable specification.
2. Keep reference houses separate from the standard itself.
3. Store all model-specific files in one predictable location.
4. Use open formats: Markdown, YAML, JSON Schema, FreeCAD, IFC and CSV.
5. Validate configuration automatically.
6. Generate reports, material lists and later CAD/BIM exports.
7. Allow community house models without weakening the official reference models.

---

## Top-level layout

```text
open-housing-standard/
├── standard/          # The OHS specification
├── reference/         # Official OHS reference houses: OH90, OH120, OH150
├── community/         # Community-contributed examples and extensions
├── cad/               # Shared CAD/BIM workspace and templates
├── config/            # Global defaults, materials and construction families
├── schemas/           # JSON Schemas for machine-readable validation
├── src/ohs/           # Python package for future generator/validator logic
├── scripts/           # Command-line helper scripts
├── templates/         # Jinja/CSV/Markdown templates
├── tests/             # Automated tests
├── docs/              # Human-readable project documentation
├── assets/            # Logos, icons, renders, textures and images
├── .github/           # GitHub Actions, issue templates and project metadata
├── ARCHITECTURE.md    # This file
├── README.md          # Project overview
├── ROADMAP.md         # Development roadmap
├── pyproject.toml     # Python/uv project configuration
└── uv.lock            # Locked Python dependencies
```

---

## Standard vs reference houses

The repository separates **what OHS requires** from **examples of how to implement it**.

### `standard/`

The standard defines principles, requirements and rules.

Examples:

```text
standard/core/principles.md
standard/core/requirements.md
standard/core/technical-zoning.md
standard/architectural-rules.md
standard/open-formats.md
```

The standard should avoid product-specific choices where possible. It should define
requirements such as repairability, accessibility, technical zoning, open formats and
local-first operation.

### `reference/`

Reference houses are official implementations of the standard.

```text
reference/oh90/
reference/oh120/
reference/oh150/
```

These are not the standard itself. They are maintained examples that show how the
standard can be applied to real house sizes.

---

## Reference house structure

Every official reference model should use the same internal structure:

```text
reference/oh120/
├── README.md
├── config/
│   └── house.yaml
├── docs/
│   ├── overview.md
│   ├── specification.md
│   └── generated-report.md
├── cad/
│   ├── source/        # FreeCAD source files, e.g. house.FCStd
│   └── ifc/           # IFC exports
├── drawings/
│   ├── plan/
│   ├── sections/
│   ├── facades/
│   └── details/
├── bom/
│   ├── materials.csv
│   └── summary.csv
├── renders/
├── exports/
│   ├── glb/
│   └── obj/
└── assets/
```

This makes each model self-contained. A builder, architect or contributor can open
one model folder and find the configuration, drawings, CAD files, reports and BOM for
that house.

---

## Official reference models

The official Ousdal Hus reference series currently has three sizes:

| Model | Purpose |
|---|---|
| OH90 | Compact home for one person, two people, seniors or first-time buyers |
| OH120 | Main reference model and likely default OHS house |
| OH150 | Larger home for family use, more storage and flexible rooms |

Each model should follow the same design DNA:

- One main floor.
- Universal design.
- Dedicated dry technical room.
- Separate wet technical zone.
- Wood stove as a robust non-electric heating source.
- Local-first smart home infrastructure.
- Standardized components and open documentation.

Optional physical additions should be limited to:

- Basement.
- Carport.
- Garage.

---

## Technical zoning

OHS uses technical zoning to reduce risk and improve maintainability.

### Dry technical zone

The dry technical room contains:

- Fiber/ONT.
- Network rack.
- Patch panel.
- Router/firewall.
- Switch.
- UPS.
- Home Assistant/local automation.
- NAS or small home server.
- Low-voltage and digital infrastructure.

Water-bearing installations should not pass through this zone unless there is no
practical alternative. If crossings are unavoidable, they must be visible, inspectable
and designed so leaks cannot run into critical electrical or digital equipment.

### Wet technical zone

The wet zone contains:

- Bathroom.
- WC.
- Laundry.
- Water heater.
- Pipe manifolds.
- Drainage and water-bearing installations.

### Climate technical zone

Ventilation and climate equipment may be placed in a technical room, basement or
accessible loft depending on noise, serviceability and model size.

---

## Data flow

The intended long-term workflow is:

```text
YAML configuration
        ↓
Validation using JSON Schema and Python checks
        ↓
Generated Markdown reports and BOM files
        ↓
FreeCAD source model generation or update
        ↓
IFC export
        ↓
PDF/SVG drawings and Blender renders
```

The first versions of the project focus on Markdown/YAML documentation and simple
validation. CAD/BIM generation can be added gradually.

---

## Technology stack

| Layer | Tool / format |
|---|---|
| Standard text | Markdown |
| Configuration | YAML |
| Validation | JSON Schema + Python |
| Python environment | uv + pyproject.toml |
| CAD source | FreeCAD |
| BIM exchange | IFC |
| Visualization | Blender / BlenderBIM |
| Reports | Markdown templates / Jinja |
| Material lists | CSV |
| Version control | Git / GitHub |
| Automation | GitHub Actions |

---

## Python layout

The Python package lives in:

```text
src/ohs/
```

This package is reserved for reusable library code:

- configuration loading,
- validation,
- report generation,
- CAD/BIM helpers,
- future generator logic.

The `scripts/` directory should contain command-line entry points and small wrappers.
Reusable logic should gradually move into `src/ohs/` as the project grows.

---

## Scripts

Scripts should be safe to run from the repository root and should avoid modifying
source files unless the script name clearly says that it generates or updates files.

Current script categories:

- Validation: check YAML files and required OHS features.
- Generation: create reports and BOM files.
- CAD/BIM placeholders: future IFC/SVG/Blender generation.

As scripts grow, they may be grouped into subdirectories, but stable wrapper commands
should remain available so CI and users do not break.

---

## Schemas

The `schemas/` directory contains machine-readable definitions for OHS data.

Examples:

```text
schemas/house.schema.json
schemas/room.schema.json
schemas/material.schema.json
schemas/door.schema.json
schemas/window.schema.json
schemas/wall.schema.json
```

Schemas make it possible to validate reference models automatically and build future
tools around a stable data model.

---

## Community contributions

Community models should live under:

```text
community/houses/
```

A community model may follow OHS without being an official reference model. This keeps
experimentation possible while protecting the quality and stability of the official
OH90/OH120/OH150 reference series.

---

## Documentation policy

The root directory should stay clean. Keep only project-critical entry points in the
root, such as:

```text
README.md
ROADMAP.md
ARCHITECTURE.md
LICENSE
CONTRIBUTING.md
CODE_OF_CONDUCT.md
CHANGELOG.md
pyproject.toml
uv.lock
mkdocs.yml
```

Project philosophy and background documents belong in:

```text
docs/project/
```

Checklists belong in:

```text
docs/checklists/
```

---

## Architectural and legal disclaimer

OHS files are design documentation and open source reference material. They are not
approved construction drawings. Any real-world building project must be reviewed and
adapted by qualified professionals, including relevant architects, engineers,
contractors and local building authorities.

---

## Current direction

The project should stay simple:

1. Maintain OHS as an open standard.
2. Maintain three official reference houses.
3. Use open, inspectable, repairable technical choices.
4. Add automation only when it makes the project easier to maintain.
5. Avoid turning OHS into a complex house configurator too early.

The goal is not to create infinitely many house variants. The goal is to create a
small, understandable, robust and well-documented reference system that others can
trust and build upon.
EOM

# Also make it visible in docs.
cat > docs/project/README.md <<'EOM'
# Project Documents

This directory contains project-level background documents:

- Charter
- Tenets
- Design philosophy
- Non-goals
- Decision log

The root directory is reserved for the main entry points such as `README.md`,
`ROADMAP.md` and `ARCHITECTURE.md`.
EOM

# -----------------------------------------------------------------------------
# 7. Update repository map
# -----------------------------------------------------------------------------
cat > docs/repository-map.md <<'EOM'
# Repository Map

```text
open-housing-standard/
├── standard/          # OHS specification
├── reference/         # Official reference houses: OH90, OH120, OH150
├── community/         # Community models, examples and plugins
├── cad/               # Shared CAD/BIM resources
├── config/            # Global defaults and component families
├── schemas/           # JSON Schemas for machine-readable validation
├── src/ohs/           # Python package for OHS tooling
├── scripts/           # Helper scripts and command-line wrappers
├── templates/         # Markdown/CSV/Jinja templates
├── tests/             # Automated tests
├── docs/              # Project documentation
├── assets/            # Logos, renders, images and textures
└── .github/           # GitHub workflows and templates
```

See `ARCHITECTURE.md` for the full repository architecture.
EOM

# -----------------------------------------------------------------------------
# 8. Update .gitignore sensibly
# -----------------------------------------------------------------------------
touch .gitignore
for entry in ".venv/" "__pycache__/" "*.pyc" ".pytest_cache/" ".ruff_cache/" "site/" "dist/" "build/" "*.FCStd1"; do
  grep -qxF "$entry" .gitignore || echo "$entry" >> .gitignore
done

# -----------------------------------------------------------------------------
# 9. Ensure model folders have identical expected subdirectories
# -----------------------------------------------------------------------------
for model in oh90 oh120 oh150; do
  base="reference/$model"
  mkdir -p "$base"/{assets,bom,cad/source,cad/ifc,config,docs,drawings/plan,drawings/sections,drawings/facades,drawings/details,exports/glb,exports/obj,renders}
  find "$base" -type d -empty -exec touch {}/.gitkeep \;
  if [ ! -f "$base/README.md" ]; then
    cat > "$base/README.md" <<EOM
# ${model^^}

Official OHS reference house model.

See \\`config/house.yaml\\` and \\`docs/specification.md\\`.
EOM
  fi
done

# -----------------------------------------------------------------------------
# 10. Final note
# -----------------------------------------------------------------------------

echo "[✓] Repository polish complete."
echo
echo "Next commands:"
echo "  uv sync --all-extras --dev"
echo "  uv run pytest"
echo "  git status"
echo "  git add -A"
echo "  git commit -m 'Polish repository architecture'"
echo "  git push"
