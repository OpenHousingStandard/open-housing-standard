#!/usr/bin/env bash
set -euo pipefail

# Upgrade Open Housing Standard repo to the agreed tech stack:
# - standard/ for OHS specification
# - reference/ for Ousdal Hus 90/120/150 reference models
# - FreeCAD / IFC / YAML / JSON / Markdown workflow
# - uv + pyproject.toml + Ruff + Pytest + MkDocs
#
# Run from the repository root.

ROOT="$(pwd)"

echo "[*] Upgrading OHS repo in: $ROOT"

# -----------------------------------------------------------------------------
# Safety checks
# -----------------------------------------------------------------------------
if [ ! -f "README.md" ]; then
  echo "[!] README.md not found. Run this script from the repo root."
  exit 1
fi

if [ -d ".git" ]; then
  echo "[*] Git repo detected. Current status:"
  git status --short || true
else
  echo "[!] No .git directory found. Continuing, but you may want to run this inside the Git repo."
fi

# -----------------------------------------------------------------------------
# Directory structure
# -----------------------------------------------------------------------------
echo "[*] Creating directory structure..."

mkdir -p \
  .github/workflows \
  .github/ISSUE_TEMPLATE \
  assets/{logo,icons,images,materials} \
  docs/{adr,examples,reference,images} \
  standard/{core,appendices} \
  reference/ousdal-hus-90/{config,model/source,model/ifc,exports/{glb,obj},drawings/{plan,facades,sections,details},bom,docs,assets} \
  reference/ousdal-hus-120/{config,model/source,model/ifc,exports/{glb,obj},drawings/{plan,facades,sections,details},bom,docs,assets} \
  reference/ousdal-hus-150/{config,model/source,model/ifc,exports/{glb,obj},drawings/{plan,facades,sections,details},bom,docs,assets} \
  scripts \
  templates \
  tests

# Preserve old standard file if present
if [ -f "standard/OHS-1.0.md" ] && [ ! -f "standard/core/ohs-1.0.md" ]; then
  cp standard/OHS-1.0.md standard/core/ohs-1.0.md
fi

# -----------------------------------------------------------------------------
# Python / uv project files
# -----------------------------------------------------------------------------
echo "[*] Writing pyproject.toml and tool config..."

cat > pyproject.toml <<'EOF'
[project]
name = "open-housing-standard"
version = "0.1.0"
description = "An open standard for robust, repairable, accessible and technology-friendly homes."
readme = "README.md"
requires-python = ">=3.11"
license = { text = "CC-BY-SA-4.0" }
authors = [
  { name = "Open Housing Standard contributors" }
]
keywords = ["housing", "architecture", "bim", "ifc", "freecad", "open-standard", "universal-design"]
dependencies = [
  "pyyaml>=6.0.2",
  "jinja2>=3.1.4",
  "rich>=13.7.1",
]

[project.optional-dependencies]
bim = [
  "ifcopenshell>=0.8.0",
]

[dependency-groups]
dev = [
  "pytest>=8.3.0",
  "ruff>=0.6.0",
  "mkdocs>=1.6.0",
  "mkdocs-material>=9.5.0",
]

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B"]
ignore = []

[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["."]

[tool.ohs]
standard_version = "0.1.0"
default_model = "ousdal-hus-120"
EOF

cat > .gitignore <<'EOF'
# Python
.venv/
__pycache__/
*.py[cod]
.pytest_cache/
.ruff_cache/

# Generated outputs
site/
dist/
build/
*.log

# FreeCAD backup files
*.FCStd1
*.FCBak

# OS/editor
.DS_Store
Thumbs.db
.vscode/
.idea/
EOF

cat > mkdocs.yml <<'EOF'
site_name: Open Housing Standard
site_description: Robust, repairable, accessible and technology-friendly homes.
repo_url: https://github.com/CHANGE-ME/open-housing-standard
repo_name: open-housing-standard

theme:
  name: material
  language: en
  features:
    - navigation.sections
    - navigation.expand
    - content.code.copy

nav:
  - Home: README.md
  - Standard:
      - OHS 1.0: standard/core/ohs-1.0.md
      - Principles: standard/core/principles.md
      - Requirements: standard/core/requirements.md
      - Certification: standard/core/certification-levels.md
      - Technical Zoning: standard/core/technical-zoning.md
  - Reference Models:
      - Overview: reference/README.md
      - Ousdal Hus 90: reference/ousdal-hus-90/docs/specification.md
      - Ousdal Hus 120: reference/ousdal-hus-120/docs/specification.md
      - Ousdal Hus 150: reference/ousdal-hus-150/docs/specification.md
  - Decisions: docs/adr/index.md
EOF

# -----------------------------------------------------------------------------
# Core documentation
# -----------------------------------------------------------------------------
echo "[*] Writing standard documentation..."

cat > standard/core/principles.md <<'EOF'
# OHS Principles

Status: Draft 0.1

Open Housing Standard exists to describe homes that are robust, understandable, repairable, accessible and technology-friendly.

## OHS-01 Universal design
Homes MUST be usable across life stages and SHOULD avoid thresholds, narrow passages and avoidable accessibility barriers.

## OHS-02 Robustness
Homes SHOULD continue to support basic living during power outages, internet outages and supply-chain delays.

## OHS-03 Repairability
Critical components MUST be replaceable without destructive work where practical.

## OHS-04 Standardisation
Standard component sizes SHOULD be preferred for doors, windows, electrical parts, network cabling, plumbing and interior modules.

## OHS-05 Documentation
A completed OHS home SHOULD be delivered with plans, component lists, maintenance notes and technical diagrams.

## OHS-06 Open technology
Open standards SHOULD be preferred over proprietary ecosystems.

## OHS-07 Local-first control
Critical functions MUST NOT require cloud services to operate.

## OHS-08 Low energy demand
The first energy strategy is to reduce demand; production and storage come after efficiency.

## OHS-09 Functional neutrality
Rooms SHOULD be designed so they can change use over time without structural changes.

## OHS-10 Maintainability
Service points MUST be accessible for inspection, maintenance and replacement.

## OHS-11 Technical room
Every OHS reference model MUST include a dedicated dry technical room.

## OHS-12 Resilience
Homes SHOULD support at least 72 hours of basic operation with planned fallback strategies.

## OHS-13 Timeless architecture
Simple forms, robust materials and proven construction methods SHOULD be preferred.

## OHS-14 Lifecycle cost
Design choices SHOULD be evaluated by total lifecycle cost, not only purchase price.

## OHS-15 Justification
Every significant design choice SHOULD have a functional justification.

## OHS-16 Separation of wet and dry technical zones
Water-carrying installations SHOULD be physically separated from electrical and digital infrastructure.

## OHS-17 Inspectability
Critical routes, pipes, drains, cables and service points SHOULD be inspectable.

## OHS-18 Standard components over novelty
Products and components SHOULD remain obtainable and replaceable over decades.
EOF

cat > standard/core/requirements.md <<'EOF'
# OHS Requirements

Status: Draft 0.1

The words MUST, SHOULD and MAY are used in the RFC 2119 sense.

## Required in all OHS reference homes

- One accessible main entrance.
- One dedicated dry technical room.
- One wet technical zone containing plumbing-related services.
- A compact service core with short technical runs.
- Structured network cabling to relevant rooms.
- Local-first smart-home readiness.
- A documented heating strategy including electric and non-electric fallback where practical.
- A documented maintenance and inspection plan.
- Standard internal door width target: minimum 90 cm.
- Threshold-free internal circulation where practical.

## Reference model assumptions

Ousdal Hus reference models are single-storey homes.

Optional modules:

- Basement.
- Carport.
- Garage.

The base models are:

- Ousdal Hus 90.
- Ousdal Hus 120.
- Ousdal Hus 150.
EOF

cat > standard/core/technical-zoning.md <<'EOF'
# OHS Technical Zoning

Status: Draft 0.1

OHS separates technical infrastructure into zones to reduce risk and improve maintainability.

## Dry technical zone

Contains:

- Electrical distribution.
- Fiber / internet termination.
- Patch panel.
- Router / firewall.
- Switches.
- UPS.
- Local smart-home controller.
- NAS or home server if used.

The dry technical zone MUST NOT contain a water heater or other water-carrying equipment where practical.

## Wet technical zone

Contains:

- Bathroom.
- WC.
- Laundry.
- Water heater.
- Pipe-in-pipe manifold.
- Water shutoff and leak detection.

## Climate technical zone

Contains:

- Ventilation unit.
- Filters.
- Heat recovery system.
- Heat-pump interfaces where relevant.

This MAY be placed in the dry technical room, basement, utility space or accessible attic depending on model and climate strategy.

## Red-zone rule

Water-carrying installations SHOULD NOT be placed above critical electrical or digital infrastructure. If unavoidable, leakage paths and inspection access MUST be considered.
EOF

cat > standard/core/certification-levels.md <<'EOF'
# OHS Certification Levels

Status: Draft 0.1

This is a draft certification model for design evaluation.

## Bronze

Meets the core OHS requirements.

## Silver

Includes Bronze plus:

- Solar-ready roof and conduit plan.
- Dedicated dry technical room.
- Documented local-first smart-home setup.
- Complete handover documentation.

## Gold

Includes Silver plus:

- 72-hour resilience plan.
- Battery-ready or battery-installed electrical design.
- Documented non-electric heating fallback.
- Enhanced universal design.

## Platinum

Includes Gold plus:

- Full digital twin / BIM handover.
- Full lifecycle maintenance plan.
- Expanded energy and water resilience.
- Independent professional quality review.
EOF

cat > standard/appendices/toolchain.md <<'EOF'
# OHS Open Toolchain

The preferred OHS toolchain is:

- YAML for configuration.
- JSON/CSV for data and bills of materials.
- Markdown for documentation.
- FreeCAD for parametric source models.
- IFC for open BIM exchange.
- Blender / BlenderBIM for visualisation.
- Git and GitHub for version control and collaboration.
- Python with uv for scripts and automation.
EOF

cat > docs/adr/index.md <<'EOF'
# Architecture Decision Records

This folder records important project decisions.

Start with:

- ADR-0001: Use open formats.
- ADR-0002: Use three reference house sizes.
EOF

cat > docs/adr/0001-open-formats.md <<'EOF'
# ADR-0001: Use open formats

Status: Accepted

## Decision

OHS uses open and inspectable formats where practical: Markdown, YAML, JSON, CSV, IFC and FreeCAD source files.

## Rationale

The project must remain accessible, repairable and vendor-neutral over decades.
EOF

cat > docs/adr/0002-three-reference-sizes.md <<'EOF'
# ADR-0002: Use three reference sizes

Status: Accepted

## Decision

Ousdal Hus reference models use three main sizes: 90, 120 and 150 m².

## Rationale

Three sizes keep the system simple while covering compact, standard and larger needs.
EOF

cat > reference/README.md <<'EOF'
# OHS Reference Models

This folder contains reference implementations of Open Housing Standard.

Current models:

- `ousdal-hus-90` — compact model.
- `ousdal-hus-120` — standard model.
- `ousdal-hus-150` — larger model.

Optional modules:

- Basement.
- Carport.
- Garage.
EOF

# -----------------------------------------------------------------------------
# Model YAML configs
# -----------------------------------------------------------------------------
echo "[*] Writing reference model configs..."

write_model_yaml() {
  local dir="$1"
  local name="$2"
  local area="$3"
  local length="$4"
  local width="$5"
  local bedrooms="$6"
  local flexible_rooms="$7"
  local living_area="$8"
  local main_bed="$9"
  local secondary_bed="${10}"
  local flex_area="${11}"

  cat > "reference/${dir}/config/house.yaml" <<EOF
house:
  name: "${name}"
  standard: "OHS"
  standard_version: "0.1.0"
  model_status: "concept"
  type: "single-storey detached house"
  floors: 1

areas:
  target_bra_m2: ${area}
  estimated_bya_m2: null

dimensions:
  length_m: ${length}
  width_m: ${width}
  ceiling_height_m: 2.4
  roof_type: "gable"
  roof_pitch_degrees: 22

rooms:
  living_kitchen_m2: ${living_area}
  bedrooms: ${bedrooms}
  flexible_rooms: ${flexible_rooms}
  main_bedroom_m2: ${main_bed}
  secondary_bedroom_m2: ${secondary_bed}
  flexible_room_m2: ${flex_area}
  bathroom_laundry_m2: 8.0
  guest_wc_m2: 2.5
  entrance_m2: 6.0
  hallway_m2: 7.0
  dry_technical_room_m2: 4.0
  storage_m2: 4.0

technical_zones:
  dry_technical_room:
    required: true
    water_installations_allowed: false
    rack_target: "24U minimum, 42U optional"
    contains:
      - electrical distribution
      - fiber termination
      - patch panel
      - router/firewall
      - switch
      - UPS
      - Home Assistant controller
      - NAS/server optional
  wet_zone:
    required: true
    contains:
      - bathroom/laundry
      - guest WC
      - water heater
      - pipe manifold
      - leak detection
  climate_zone:
    required: true
    contains:
      - balanced ventilation with heat recovery

features:
  universal_design: true
  threshold_free: true
  local_first_smart_home: true
  structured_network: true
  wood_stove: true
  heat_pump: true
  balanced_ventilation: true
  solar_ready: true
  battery_ready: true
  basement_optional: true
  carport_optional: true
  garage_optional: true
EOF
}

write_model_yaml "ousdal-hus-90"  "Ousdal Hus 90"  90  12.0 8.0 2 1 38.0 14.0 12.0 10.0
write_model_yaml "ousdal-hus-120" "Ousdal Hus 120" 120 13.8 9.2 3 1 48.0 14.0 12.0 11.0
write_model_yaml "ousdal-hus-150" "Ousdal Hus 150" 150 16.0 9.8 3 1 60.0 15.0 12.0 12.0

# Shared defaults
cat > reference/defaults.yaml <<'EOF'
oh_standard:
  version: "0.1.0"
  model_family: "Ousdal Hus"

construction:
  storeys: 1
  preferred_shape: "compact rectangle"
  roof: "gable"
  default_roof_pitch_degrees: 22

accessibility:
  internal_door_clear_width_cm: 90
  threshold_free: true
  accessible_shower: true

technical:
  dry_technical_room_m2: 4.0
  dry_wet_separation_required: true
  structured_cabling: "Cat6A or better"
  rack: "24U minimum, 42U optional"

optional_modules:
  basement: true
  carport: true
  garage: true
EOF

# -----------------------------------------------------------------------------
# Per-model docs and placeholders
# -----------------------------------------------------------------------------
echo "[*] Writing model documentation and placeholders..."

for model in ousdal-hus-90 ousdal-hus-120 ousdal-hus-150; do
  title="$(echo "$model" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')"
  cat > "reference/${model}/docs/specification.md" <<EOF
# ${title}

Status: Concept

This is a reference implementation of Open Housing Standard.

## Design intent

A single-storey, robust, accessible and technology-friendly home with:

- Compact rectangular form.
- Central living/kitchen zone.
- Bedrooms in quiet corners.
- Bathroom and WC in a wet technical zone.
- Separate dry technical room.
- Dedicated storage room with access independent of the technical room.
- Wood stove placed centrally on the living room wall.
- Optional basement, carport or garage.

## Files

- Configuration: \\`config/house.yaml\\`
- FreeCAD source model: \\`model/source/house.FCStd\\` (placeholder until model exists)
- IFC export: \\`model/ifc/house.ifc\\` (generated later)
- Drawings: \\`drawings/\\`
- Bill of materials: \\`bom/\\`
EOF

  touch "reference/${model}/model/source/.gitkeep"
  touch "reference/${model}/model/ifc/.gitkeep"
  touch "reference/${model}/exports/glb/.gitkeep"
  touch "reference/${model}/exports/obj/.gitkeep"
  touch "reference/${model}/drawings/plan/.gitkeep"
  touch "reference/${model}/drawings/facades/.gitkeep"
  touch "reference/${model}/drawings/sections/.gitkeep"
  touch "reference/${model}/drawings/details/.gitkeep"
  touch "reference/${model}/assets/.gitkeep"

  cat > "reference/${model}/bom/materials.csv" <<'EOF'
category,item,quantity,unit,notes
structure,TBD,0,pcs,Generated later from BIM/model
openings,TBD,0,pcs,Windows and doors
technical,TBD,0,pcs,Rack/network/electrical
EOF

done

# -----------------------------------------------------------------------------
# Templates and scripts
# -----------------------------------------------------------------------------
echo "[*] Writing scripts and templates..."

cat > templates/model_report.md.j2 <<'EOF'
# {{ house.name }}

Status: {{ house.model_status }}

## Key data

| Field | Value |
|---|---:|
| Target BRA | {{ areas.target_bra_m2 }} m² |
| Floors | {{ house.floors }} |
| Length | {{ dimensions.length_m }} m |
| Width | {{ dimensions.width_m }} m |
| Bedrooms | {{ rooms.bedrooms }} |
| Flexible rooms | {{ rooms.flexible_rooms }} |
| Dry technical room | {{ rooms.dry_technical_room_m2 }} m² |

## OHS features

{% for key, value in features.items() -%}
- {{ key | replace('_', ' ') }}: {{ value }}
{% endfor %}

## Technical zoning

### Dry technical room

{% for item in technical_zones.dry_technical_room.contains -%}
- {{ item }}
{% endfor %}

### Wet zone

{% for item in technical_zones.wet_zone.contains -%}
- {{ item }}
{% endfor %}
EOF

cat > scripts/validate_config.py <<'EOF'
#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys
import yaml

ROOT = Path(__file__).resolve().parents[1]
MODELS = ROOT / "reference"

REQUIRED_FEATURES = [
    "universal_design",
    "local_first_smart_home",
    "structured_network",
    "wood_stove",
]


def validate_house_config(path: Path) -> list[str]:
    errors: list[str] = []
    data = yaml.safe_load(path.read_text(encoding="utf-8"))

    if data["house"].get("floors") != 1:
        errors.append(f"{path}: Ousdal Hus reference models must be single-storey")

    tech = data.get("technical_zones", {}).get("dry_technical_room", {})
    if not tech.get("required"):
        errors.append(f"{path}: dry technical room is required")
    if tech.get("water_installations_allowed") is not False:
        errors.append(f"{path}: water installations must not be allowed in dry technical room")

    rooms = data.get("rooms", {})
    if float(rooms.get("dry_technical_room_m2", 0)) < 4.0:
        errors.append(f"{path}: dry technical room should be at least 4.0 m²")

    features = data.get("features", {})
    for feature in REQUIRED_FEATURES:
        if features.get(feature) is not True:
            errors.append(f"{path}: missing required feature {feature}")

    return errors


def main() -> int:
    paths = sorted(MODELS.glob("ousdal-hus-*/config/house.yaml"))
    if not paths:
        print("No model configs found", file=sys.stderr)
        return 1

    errors: list[str] = []
    for path in paths:
        errors.extend(validate_house_config(path))

    if errors:
        print("OHS validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"OHS validation passed for {len(paths)} models.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
EOF
chmod +x scripts/validate_config.py

cat > scripts/generate_model_report.py <<'EOF'
#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import yaml
from jinja2 import Environment, FileSystemLoader

ROOT = Path(__file__).resolve().parents[1]
TEMPLATES = ROOT / "templates"
REFERENCE = ROOT / "reference"


def main() -> int:
    env = Environment(loader=FileSystemLoader(TEMPLATES), autoescape=False)
    template = env.get_template("model_report.md.j2")

    for config in sorted(REFERENCE.glob("ousdal-hus-*/config/house.yaml")):
        data = yaml.safe_load(config.read_text(encoding="utf-8"))
        output = config.parents[1] / "docs" / "generated-report.md"
        output.write_text(template.render(**data), encoding="utf-8")
        print(f"Wrote {output}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
EOF
chmod +x scripts/generate_model_report.py

cat > scripts/generate_bom.py <<'EOF'
#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import csv
import yaml

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "reference"


def main() -> int:
    for config in sorted(REFERENCE.glob("ousdal-hus-*/config/house.yaml")):
        data = yaml.safe_load(config.read_text(encoding="utf-8"))
        model_dir = config.parents[1]
        output = model_dir / "bom" / "summary.csv"
        rows = [
            ["category", "item", "quantity", "unit", "notes"],
            ["area", "target_bra", data["areas"]["target_bra_m2"], "m2", "concept value"],
            ["technical", "dry_technical_room", data["rooms"]["dry_technical_room_m2"], "m2", "required"],
            ["energy", "wood_stove", 1, "pcs", "standard"],
            ["energy", "heat_pump", 1, "pcs", "standard"],
            ["network", "structured_cabling", 1, "lot", "Cat6A or better"],
        ]
        with output.open("w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerows(rows)
        print(f"Wrote {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
EOF
chmod +x scripts/generate_bom.py

# Keep old generate_report.py name as convenience wrapper if absent
cat > scripts/generate_report.py <<'EOF'
#!/usr/bin/env python3
from generate_model_report import main

if __name__ == "__main__":
    raise SystemExit(main())
EOF
chmod +x scripts/generate_report.py

# Tests
cat > tests/test_configs.py <<'EOF'
from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[1]


def test_reference_models_have_dry_technical_room():
    configs = sorted(ROOT.glob("reference/ousdal-hus-*/config/house.yaml"))
    assert configs
    for config in configs:
        data = yaml.safe_load(config.read_text())
        assert data["rooms"]["dry_technical_room_m2"] >= 4.0
        assert data["technical_zones"]["dry_technical_room"]["water_installations_allowed"] is False


def test_reference_models_are_single_storey():
    for config in ROOT.glob("reference/ousdal-hus-*/config/house.yaml"):
        data = yaml.safe_load(config.read_text())
        assert data["house"]["floors"] == 1
EOF

# -----------------------------------------------------------------------------
# GitHub Actions
# -----------------------------------------------------------------------------
echo "[*] Writing GitHub Actions workflow..."

cat > .github/workflows/ci.yml <<'EOF'
name: CI

on:
  push:
  pull_request:

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install uv
        uses: astral-sh/setup-uv@v4
      - name: Set up Python
        run: uv python install 3.12
      - name: Install dependencies
        run: uv sync --all-extras --dev
      - name: Lint
        run: uv run ruff check .
      - name: Test
        run: uv run pytest
      - name: Validate OHS configs
        run: uv run python scripts/validate_config.py
      - name: Generate reports and BOMs
        run: |
          uv run python scripts/generate_model_report.py
          uv run python scripts/generate_bom.py
EOF

cat > .github/ISSUE_TEMPLATE/bug_report.md <<'EOF'
---
name: Bug report
about: Report an issue in the standard, tooling or reference models
labels: bug
---

## What happened?

## Expected result

## Files / model affected
EOF

cat > .github/ISSUE_TEMPLATE/feature_request.md <<'EOF'
---
name: Feature request
about: Suggest an improvement to OHS
labels: enhancement
---

## Proposal

## Why this belongs in OHS

## Alternatives considered
EOF

# -----------------------------------------------------------------------------
# Update README carefully: append if not already present
# -----------------------------------------------------------------------------
echo "[*] Updating README with tech stack section..."

if ! grep -q "## Technology stack" README.md; then
  cat >> README.md <<'EOF'

## Technology stack

OHS uses an open, version-controlled toolchain:

- **Markdown** for documentation.
- **YAML** for house model configuration.
- **JSON/CSV** for structured data and material lists.
- **FreeCAD** for parametric source models.
- **IFC** for open BIM exchange.
- **Blender / BlenderBIM** for visualisation.
- **Python + uv** for automation.
- **GitHub Actions** for validation.

## Repository layout

```text
standard/      The Open Housing Standard specification.
reference/     Reference implementations: Ousdal Hus 90, 120 and 150.
scripts/       Validation and generation scripts.
templates/     Report templates.
docs/          Architecture decisions and supporting documentation.
assets/        Logos, icons, images and material references.
```

## Quick start

```bash
uv sync --all-extras --dev
uv run python scripts/validate_config.py
uv run python scripts/generate_model_report.py
uv run python scripts/generate_bom.py
uv run pytest
```
EOF
fi

# -----------------------------------------------------------------------------
# Finish
# -----------------------------------------------------------------------------
echo "[*] Done."
echo
cat <<'EOF'
Next steps:

1. Install uv if needed:
   curl -LsSf https://astral.sh/uv/install.sh | sh
   source ~/.bashrc

2. Sync dependencies:
   uv sync --all-extras --dev

3. Validate and generate:
   uv run python scripts/validate_config.py
   uv run python scripts/generate_model_report.py
   uv run python scripts/generate_bom.py
   uv run pytest

4. Review changes:
   git status
   git diff
EOF
