#!/usr/bin/env bash
set -euo pipefail

# update-ohs-structure.sh
# Run from the root of the open-housing-standard repository.
# It adds an OHS/Ousdal Hus tech-stack structure based on:
# FreeCAD, BlenderBIM, IFC, YAML/JSON, Markdown, CSV and GitHub CI.

ROOT="$(pwd)"

if [[ ! -f "README.md" ]]; then
  echo "ERROR: Run this script from the repository root, where README.md exists." >&2
  exit 1
fi

mkdir -p \
  .github/workflows \
  .github/ISSUE_TEMPLATE \
  assets/icons \
  assets/images \
  bom \
  checklists \
  config \
  docs \
  docs/adr \
  docs/examples \
  docs/workflows \
  drawings/house-90/plan drawings/house-90/facades drawings/house-90/sections drawings/house-90/details \
  drawings/house-120/plan drawings/house-120/facades drawings/house-120/sections drawings/house-120/details \
  drawings/house-150/plan drawings/house-150/facades drawings/house-150/sections drawings/house-150/details \
  exports/house-90/glb exports/house-90/obj \
  exports/house-120/glb exports/house-120/obj \
  exports/house-150/glb exports/house-150/obj \
  ifc/house-90 ifc/house-120 ifc/house-150 \
  model/house-90/source model/house-120/source model/house-150/source model/shared \
  models \
  scripts \
  standard

cat > .gitignore <<'EOF_GITIGNORE'
# OS/editor
.DS_Store
Thumbs.db
.vscode/
.idea/

# Python
__pycache__/
*.py[cod]
.venv/
venv/

# Generated outputs / caches
build/
dist/
.tmp/
*.log

# Large generated CAD exports can be committed intentionally,
# but keep temporary backups out of git.
*.FCStd1
*.bak
*.tmp
EOF_GITIGNORE

cat > docs/tech-stack.md <<'EOF_TECH'
# Technology Stack

OHS uses open tools and open formats wherever practical.

## Authoring and modelling

- **Markdown** for the standard, documentation, checklists and model descriptions.
- **YAML** for human-editable house configuration.
- **JSON** for generated machine-readable metadata.
- **FreeCAD** for parametric/BIM modelling.
- **IFC** as the primary open BIM exchange format.
- **Blender + BlenderBIM** for visualisation, review and presentation renders.
- **CSV/JSON** for material lists and quantities.
- **Git/GitHub** for version control, review and issues.

## Intended workflow

```text
YAML configuration
  -> validation
  -> FreeCAD model
  -> IFC export
  -> drawings: PDF/DXF
  -> material list: CSV/JSON
  -> visualisation: GLB/OBJ/Blender
```

## Design intent

The repo should remain useful even without proprietary CAD software. Professional architects and engineers may use commercial tools later, but the project source should remain open and inspectable.
EOF_TECH

cat > docs/workflows/open-design-workflow.md <<'EOF_WORKFLOW'
# Open Design Workflow

1. Edit the relevant YAML file in `config/`.
2. Validate the configuration with `scripts/validate_config.py`.
3. Update or regenerate the FreeCAD model in `model/`.
4. Export IFC to `ifc/`.
5. Export drawings to `drawings/`.
6. Export material lists to `bom/`.
7. Use Blender/BlenderBIM for visual review and presentation renders.
8. Submit changes through pull requests.

## Quality gate

A model is not considered ready for practical use until it has been reviewed by qualified professionals for:

- Norwegian building regulations.
- Fire safety.
- Structural safety.
- Accessibility/universal design.
- Moisture and ventilation.
- Energy performance.
- Local planning rules and site conditions.
EOF_WORKFLOW

cat > docs/disclaimer.md <<'EOF_DISCLAIMER'
# Disclaimer

OHS documents and models are conceptual open design material.

They are **not** construction-ready drawings, engineering calculations, building applications or a replacement for qualified professional advice.

Before construction, all drawings and specifications must be reviewed and adapted by relevant professionals, normally including an architect/responsible applicant and the required engineering disciplines.
EOF_DISCLAIMER

cat > standard/architectural-rules.md <<'EOF_RULES'
# OHS Architectural Rules

Status: Draft 0.1

## Core principles

- OHS houses SHOULD use simple compact forms.
- The default roof form SHOULD be a simple pitched roof.
- The main floor SHOULD be step-free and universally accessible.
- Internal doors SHOULD be at least 90 cm where practical.
- Wet technical functions and dry technical functions SHOULD be separated.
- The wood stove SHOULD be placed centrally in the living area for useful heat distribution.
- The entrance, storage, technical room and wet zone SHOULD be arranged so daily use is practical and service access is simple.

## Technical zoning

OHS distinguishes between:

- **Dry technical zone:** rack, networking, electrical distribution, UPS, automation and digital infrastructure.
- **Wet technical zone:** bathroom, WC, washing, hot water cylinder, pipe manifolds and other water-bearing systems.
- **Climate zone:** ventilation unit, heat recovery, heat pump interfaces and related service access.

Water-bearing systems SHOULD NOT pass through or above the dry technical zone unless unavoidable and specifically protected.
EOF_RULES

cat > standard/technical-core.md <<'EOF_CORE'
# OHS Technical Core

Status: Draft 0.1

The technical core is a standardised service concept used across Ousdal Hus 90, 120 and 150.

## Dry technical room

Recommended minimum:

- 4.0 m², typically around 2.0 m × 2.0 m.
- Space for 19-inch rack, typically 18U–24U.
- Fiber/ONT.
- Patch panel.
- Router/firewall.
- Switch.
- UPS.
- Home Assistant or equivalent local controller.
- NAS/server shelf.
- Electrical distribution where permitted and appropriate.
- Service clearance in front of rack and panels.

## Wet technical area

The hot water cylinder, pipe manifolds and washing functions SHOULD be placed in a wet zone with suitable drainage, typically bathroom/laundry.

## Separation rule

Dry technical equipment and water-bearing installations SHOULD be physically separated to reduce risk from leaks and condensation.
EOF_CORE

cat > standard/open-formats.md <<'EOF_FORMATS'
# OHS Open Formats

Status: Draft 0.1

OHS source material SHOULD be stored in open or widely documented formats.

## Preferred formats

| Purpose | Preferred format |
|---|---|
| Documentation | Markdown |
| Configuration | YAML |
| Generated metadata | JSON |
| BIM exchange | IFC |
| 2D drawings | PDF + DXF |
| Material lists | CSV + JSON |
| Visualisation | GLB/OBJ |
| Source CAD/BIM | FreeCAD `.FCStd` |

## Naming convention

Use lowercase names with hyphens where practical:

```text
house-100.ifc
house-100-plan.pdf
materials-house-100.csv
```
EOF_FORMATS

cat > models/ousdal-hus-90.md <<'EOF_90'
# Ousdal Hus 90

Status: Concept

Compact one-level OHS reference house for one or two people.

## Target

- Approx. 90 m² BRA main floor.
- 2 bedrooms or 1 bedroom + flexible room.
- Open living/kitchen area.
- Bathroom/laundry.
- Guest WC where practical.
- Dedicated dry technical room.
- Separate storage room.
- Wood stove in living area.
- Step-free main floor.

## Optional modules

- Basement.
- Carport.
- Garage.
EOF_90

cat > models/ousdal-hus-120.md <<'EOF_120'
# Ousdal Hus 120

Status: Concept

Standard OHS reference house for couples, small families and home office use.

## Target

- Approx. 120 m² BRA main floor.
- 3 bedrooms, where one may function as office/flexible room.
- Open living/kitchen area.
- Bathroom/laundry.
- Guest WC.
- Dedicated dry technical room.
- Separate storage/pantry.
- Wood stove placed centrally in the living area.
- Step-free main floor.

## Optional modules

- Basement.
- Carport.
- Garage.
EOF_120

cat > models/ousdal-hus-150.md <<'EOF_150'
# Ousdal Hus 150

Status: Concept

Larger OHS reference house for families or households needing generous work and storage space.

## Target

- Approx. 150 m² BRA main floor.
- 3 bedrooms + large flexible room, or 4 bedrooms depending on internal use.
- Large open living/kitchen area.
- Bathroom/laundry.
- Guest WC.
- Dedicated dry technical room.
- Pantry/storage.
- Wood stove placed centrally in the living area.
- Step-free main floor.

## Optional modules

- Basement.
- Carport.
- Garage.
EOF_150

cat > models/options.md <<'EOF_OPTIONS'
# Ousdal Hus Options

Ousdal Hus keeps options deliberately limited to reduce complexity.

## Option A: Basement

A robust basement may provide:

- Storage.
- Workshop.
- Technical expansion.
- Battery and energy systems.
- Preparedness storage.

## Option B: Carport

Simple weather protection for one or two cars.

## Option C: Garage

Enclosed vehicle and workshop space.
EOF_OPTIONS

cat > config/defaults.yaml <<'EOF_DEFAULTS'
ohs:
  version: "0.1"
  standard: "OHS draft"

defaults:
  floors: 1
  main_floor_step_free: true
  internal_door_clear_width_cm: 90
  ceiling_height_m: 2.4
  roof_type: "pitched"
  wood_stove: true
  dry_technical_room: true
  wet_dry_separation: true
  local_smart_home_ready: true
  network_cabling: "Cat6A"
  primary_bim_format: "IFC"
  source_model_tool: "FreeCAD"
  visualisation_tool: "BlenderBIM"
EOF_DEFAULTS

cat > config/house-90.yaml <<'EOF_H90'
house:
  id: "ousdal-hus-90"
  name: "Ousdal Hus 90"
  type: "one-level detached house"
  target_bra_m2: 90
  bedrooms: 2
  flexible_room: true
  bathroom_laundry: true
  guest_wc: true
  dry_technical_room_m2: 4.0
  storage_m2: 4.0
  wood_stove: true
  basement_option: true
  carport_option: true
  garage_option: true
EOF_H90

cat > config/house-120.yaml <<'EOF_H120'
house:
  id: "ousdal-hus-120"
  name: "Ousdal Hus 120"
  type: "one-level detached house"
  target_bra_m2: 120
  bedrooms: 3
  flexible_room: true
  bathroom_laundry: true
  guest_wc: true
  dry_technical_room_m2: 4.0
  pantry_storage: true
  wood_stove: true
  basement_option: true
  carport_option: true
  garage_option: true
EOF_H120

cat > config/house-150.yaml <<'EOF_H150'
house:
  id: "ousdal-hus-150"
  name: "Ousdal Hus 150"
  type: "one-level detached house"
  target_bra_m2: 150
  bedrooms: 3
  large_flexible_room: true
  alternative_use: "4 bedrooms"
  bathroom_laundry: true
  guest_wc: true
  dry_technical_room_m2: 4.0
  pantry_storage: true
  wood_stove: true
  basement_option: true
  carport_option: true
  garage_option: true
EOF_H150

cat > bom/materials-template.csv <<'EOF_BOM'
category,item,quantity,unit,notes
structure,foundation,0,m2,To be calculated
structure,external walls,0,m2,To be calculated
roof,pitched roof,0,m2,To be calculated
openings,windows,0,pcs,Standard sizes preferred
openings,external doors,0,pcs,Step-free access
interior,internal doors,0,pcs,Minimum 90 cm where practical
technical,19-inch rack,1,pcs,18U-24U typical
technical,network cabling,0,points,Cat6A preferred
heating,wood stove,1,pcs,Central living area placement
EOF_BOM

cat > checklists/design-checklist.md <<'EOF_DESIGN_CHECK'
# Design Checklist

- [ ] One-level main floor.
- [ ] Step-free entrance.
- [ ] Internal doors minimum 90 cm where practical.
- [ ] Dedicated dry technical room.
- [ ] Wet and dry technical zones separated.
- [ ] Direct access to storage without passing through technical room.
- [ ] Wood stove placed centrally and safely.
- [ ] Door to living area does not conflict with stove safety zone.
- [ ] Bathroom/laundry sized for accessibility.
- [ ] Kitchen, bathroom and WC arranged for short service runs where practical.
- [ ] All major components documented.
- [ ] Drawings reviewed by qualified professionals before use.
EOF_DESIGN_CHECK

cat > checklists/handover-documentation.md <<'EOF_HANDOVER'
# Handover Documentation Checklist

- [ ] Final floor plan.
- [ ] Facades.
- [ ] Sections.
- [ ] Site plan.
- [ ] Electrical plan.
- [ ] Network plan.
- [ ] Plumbing plan.
- [ ] Ventilation plan.
- [ ] IFC model.
- [ ] Material list.
- [ ] Product documentation.
- [ ] Maintenance plan.
- [ ] Photos of hidden installations before closing walls/floors.
EOF_HANDOVER

cat > scripts/validate_config.py <<'EOF_VALIDATE'
#!/usr/bin/env python3
"""Validate basic OHS YAML configuration files."""
from __future__ import annotations

import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("Missing dependency: pyyaml. Install with: pip install pyyaml", file=sys.stderr)
    sys.exit(2)

REQUIRED_HOUSE_KEYS = {
    "id",
    "name",
    "target_bra_m2",
    "wood_stove",
    "dry_technical_room_m2",
}


def validate_house_config(path: Path) -> bool:
    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    house = data.get("house")
    if not isinstance(house, dict):
        print(f"FAIL {path}: missing top-level 'house' object")
        return False

    missing = sorted(REQUIRED_HOUSE_KEYS - set(house))
    if missing:
        print(f"FAIL {path}: missing keys: {', '.join(missing)}")
        return False

    if float(house.get("dry_technical_room_m2", 0)) < 3.0:
        print(f"FAIL {path}: dry_technical_room_m2 should be at least 3.0")
        return False

    print(f"OK   {path}")
    return True


def main() -> int:
    paths = [Path(p) for p in sys.argv[1:]]
    if not paths:
        paths = sorted(Path("config").glob("house-*.yaml"))
    if not paths:
        print("No config files found.", file=sys.stderr)
        return 1
    return 0 if all(validate_house_config(p) for p in paths) else 1


if __name__ == "__main__":
    raise SystemExit(main())
EOF_VALIDATE
chmod +x scripts/validate_config.py

cat > scripts/generate_report.py <<'EOF_REPORT'
#!/usr/bin/env python3
"""Generate simple Markdown model reports from OHS YAML configs."""
from __future__ import annotations

import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("Missing dependency: pyyaml. Install with: pip install pyyaml", file=sys.stderr)
    sys.exit(2)


def render(path: Path) -> str:
    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    h = data["house"]
    lines = [
        f"# {h['name']}",
        "",
        "Generated from YAML configuration.",
        "",
        "## Key data",
        "",
        f"- ID: `{h['id']}`",
        f"- Target BRA: {h['target_bra_m2']} m²",
        f"- Bedrooms: {h.get('bedrooms', 'TBD')}",
        f"- Wood stove: {h.get('wood_stove', False)}",
        f"- Dry technical room: {h.get('dry_technical_room_m2', 'TBD')} m²",
        f"- Basement option: {h.get('basement_option', False)}",
        f"- Carport option: {h.get('carport_option', False)}",
        f"- Garage option: {h.get('garage_option', False)}",
        "",
        "## Professional review",
        "",
        "This concept must be reviewed by qualified professionals before construction or building application.",
    ]
    return "\n".join(lines) + "\n"


def main() -> int:
    out_dir = Path("docs/generated")
    out_dir.mkdir(parents=True, exist_ok=True)
    for path in sorted(Path("config").glob("house-*.yaml")):
        data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
        hid = data["house"]["id"]
        out = out_dir / f"{hid}.md"
        out.write_text(render(path), encoding="utf-8")
        print(f"wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
EOF_REPORT
chmod +x scripts/generate_report.py

cat > .github/workflows/validate.yml <<'EOF_CI'
name: Validate OHS repository

on:
  push:
  pull_request:

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.x'
      - name: Install dependencies
        run: python -m pip install pyyaml
      - name: Validate YAML configs
        run: python scripts/validate_config.py
      - name: Generate reports
        run: python scripts/generate_report.py
EOF_CI

cat > .github/ISSUE_TEMPLATE/design_review.md <<'EOF_ISSUE'
---
name: Design review
description: Review a model, rule, drawing or design decision
title: "Design review: "
labels: [design-review]
---

## What should be reviewed?


## Relevant files


## Concern or proposal


## OHS principles affected

- [ ] Universal design
- [ ] Robustness
- [ ] Repairability
- [ ] Open technology
- [ ] Energy
- [ ] Technical zoning
- [ ] Documentation
EOF_ISSUE

cat > docs/repository-map.md <<'EOF_MAP'
# Repository Map

```text
.github/          GitHub CI and issue templates
assets/           Images, icons and visual material
bom/              Material lists and quantity templates
checklists/       Design and handover checklists
config/           YAML configuration for reference houses
docs/             General documentation and workflows
drawings/         Exported drawings: PDF/DXF by model
exports/          Visualisation exports: GLB/OBJ by model
ifc/              IFC exports by model
model/            FreeCAD source models and shared parts
models/           Markdown descriptions of reference houses
scripts/          Validation and generation tools
standard/         OHS standard documents
```
EOF_MAP

# Create placeholder files so empty CAD/export dirs are committed.
find model ifc drawings exports assets/icons assets/images docs/examples docs/adr -type d -exec sh -c 'touch "$0/.gitkeep"' {} \;

# Add README section if not already present.
if ! grep -q "## Technology stack" README.md; then
cat >> README.md <<'EOF_README_APPEND'

## Technology stack

OHS uses open tools and formats:

- FreeCAD for parametric/BIM source models.
- IFC for open BIM exchange.
- Blender + BlenderBIM for visualisation.
- YAML/JSON for configuration and generated metadata.
- Markdown for documentation.
- CSV/JSON for material lists.
- GitHub for version control, review and collaboration.

See `docs/tech-stack.md` and `docs/repository-map.md`.
EOF_README_APPEND
fi

echo "OHS repository structure updated."
echo "Next steps:"
echo "  1. git status"
echo "  2. python -m pip install pyyaml"
echo "  3. python scripts/validate_config.py"
echo "  4. python scripts/generate_report.py"
echo "  5. git add . && git commit -m 'Add OHS tech stack structure'"
