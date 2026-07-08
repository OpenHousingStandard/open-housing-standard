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
