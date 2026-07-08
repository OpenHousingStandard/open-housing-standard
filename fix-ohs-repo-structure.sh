#!/usr/bin/env bash
set -euo pipefail

# OHS repository cleanup / normalization script
# Run from the root of the open-housing-standard repository.

say() { printf '\n[*] %s\n' "$*"; }
warn() { printf '\n[!] %s\n' "$*" >&2; }

if [[ ! -f README.md || ! -d standard ]]; then
  warn "This does not look like the open-housing-standard repo root."
  warn "Run this script from the repository root."
  exit 1
fi

say "Normalizing Open Housing Standard repository structure..."

# -----------------------------------------------------------------------------
# 1. Canonical top-level directories
# -----------------------------------------------------------------------------
mkdir -p \
  assets/{logo,icons,renders,textures,images} \
  cad/{freecad,blender,shared,templates} \
  community/{houses,plugins,examples} \
  config \
  docs/{adr,examples,workflows} \
  reference \
  schemas \
  scripts \
  standard/{core,appendices,examples} \
  templates \
  tests

# -----------------------------------------------------------------------------
# 2. Rename official reference models to short IDs: oh90, oh120, oh150
# -----------------------------------------------------------------------------
declare -A MODEL_MAP=(
  [ousdal-hus-90]=oh90
  [ousdal-hus-120]=oh120
  [ousdal-hus-150]=oh150
)

declare -A HOUSE_NUM=(
  [oh90]=90
  [oh120]=120
  [oh150]=150
)

for old in "${!MODEL_MAP[@]}"; do
  new="${MODEL_MAP[$old]}"
  if [[ -d "reference/$old" && ! -d "reference/$new" ]]; then
    say "Renaming reference/$old -> reference/$new"
    mv "reference/$old" "reference/$new"
  elif [[ -d "reference/$old" && -d "reference/$new" ]]; then
    say "Merging reference/$old into reference/$new"
    cp -a "reference/$old/." "reference/$new/"
    rm -rf "reference/$old"
  fi

done

# Ensure each reference model has the canonical internal structure.
for model in oh90 oh120 oh150; do
  mkdir -p \
    "reference/$model/assets" \
    "reference/$model/bom" \
    "reference/$model/cad/source" \
    "reference/$model/cad/ifc" \
    "reference/$model/config" \
    "reference/$model/docs" \
    "reference/$model/drawings/plan" \
    "reference/$model/drawings/sections" \
    "reference/$model/drawings/facades" \
    "reference/$model/drawings/details" \
    "reference/$model/exports/glb" \
    "reference/$model/exports/obj" \
    "reference/$model/renders"

  # Rename per-model model/ -> cad/ if present.
  if [[ -d "reference/$model/model" ]]; then
    if [[ -d "reference/$model/cad" ]]; then
      cp -a "reference/$model/model/." "reference/$model/cad/" 2>/dev/null || true
      rm -rf "reference/$model/model"
    else
      mv "reference/$model/model" "reference/$model/cad"
    fi
  fi

  # Keep directories in git.
  find "reference/$model" -type d -empty -exec sh -c 'touch "$1/.gitkeep"' _ {} \;
done

# -----------------------------------------------------------------------------
# 3. Move old top-level house-specific folders into their canonical model folders
# -----------------------------------------------------------------------------
move_tree_if_exists() {
  local src="$1"
  local dst="$2"
  if [[ -d "$src" ]]; then
    mkdir -p "$dst"
    cp -a "$src/." "$dst/" 2>/dev/null || true
    rm -rf "$src"
  fi
}

for n in 90 120 150; do
  model="oh$n"
  move_tree_if_exists "drawings/house-$n" "reference/$model/drawings"
  move_tree_if_exists "exports/house-$n" "reference/$model/exports"
  move_tree_if_exists "ifc/house-$n" "reference/$model/cad/ifc"
  move_tree_if_exists "model/house-$n/source" "reference/$model/cad/source"
  move_tree_if_exists "model/house-$n" "reference/$model/cad"

  if [[ -f "config/house-$n.yaml" && ! -f "reference/$model/config/house.yaml" ]]; then
    mv "config/house-$n.yaml" "reference/$model/config/house.yaml"
  elif [[ -f "config/house-$n.yaml" ]]; then
    rm -f "config/house-$n.yaml"
  fi

  if [[ -f "models/ousdal-hus-$n.md" ]]; then
    mkdir -p "reference/$model/docs"
    if [[ ! -f "reference/$model/docs/overview.md" ]]; then
      mv "models/ousdal-hus-$n.md" "reference/$model/docs/overview.md"
    else
      rm -f "models/ousdal-hus-$n.md"
    fi
  fi
done

# Move model options into docs if present.
if [[ -f models/options.md ]]; then
  mv models/options.md docs/reference-options.md
fi

# Move global BOM template into templates.
if [[ -f bom/materials-template.csv ]]; then
  mv bom/materials-template.csv templates/materials-template.csv
fi

# Remove now-obsolete duplicate top-level directories if empty or only .gitkeep.
for d in drawings exports ifc model models bom; do
  if [[ -d "$d" ]]; then
    find "$d" -type f -name .gitkeep -delete || true
    rmdir "$d" 2>/dev/null || true
    if [[ -d "$d" ]]; then
      warn "Left non-empty directory: $d (review manually)"
    fi
  fi
done

# Remove old helper scripts from repo if they were accidentally committed.
rm -f update-ohs-structure.sh upgrade-ohs-tech-stack.sh

# -----------------------------------------------------------------------------
# 4. Add/overwrite core schemas
# -----------------------------------------------------------------------------
cat > schemas/house.schema.json <<'EOF'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://openhousingstandard.org/schemas/house.schema.json",
  "title": "OHS House Configuration",
  "type": "object",
  "required": ["house", "areas", "rooms", "features", "technical_zones"],
  "properties": {
    "house": {
      "type": "object",
      "required": ["id", "name", "floors"],
      "properties": {
        "id": { "type": "string" },
        "name": { "type": "string" },
        "floors": { "type": "integer", "minimum": 1 }
      }
    },
    "areas": {
      "type": "object",
      "required": ["target_bra_m2"],
      "properties": {
        "target_bra_m2": { "type": "number", "minimum": 1 }
      }
    },
    "rooms": { "type": "object" },
    "features": { "type": "object" },
    "technical_zones": { "type": "object" }
  }
}
EOF

cat > schemas/material.schema.json <<'EOF'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://openhousingstandard.org/schemas/material.schema.json",
  "title": "OHS Material",
  "type": "object",
  "required": ["category", "item"],
  "properties": {
    "category": { "type": "string" },
    "item": { "type": "string" },
    "unit": { "type": "string" },
    "notes": { "type": "string" }
  }
}
EOF

cat > schemas/room.schema.json <<'EOF'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://openhousingstandard.org/schemas/room.schema.json",
  "title": "OHS Room Definition",
  "type": "object",
  "required": ["name", "area_m2"],
  "properties": {
    "name": { "type": "string" },
    "area_m2": { "type": "number", "minimum": 0 },
    "function_neutral": { "type": "boolean" },
    "wet_zone": { "type": "boolean" },
    "dry_technical_zone": { "type": "boolean" }
  }
}
EOF

# -----------------------------------------------------------------------------
# 5. Add documentation for canonical repository map
# -----------------------------------------------------------------------------
cat > docs/repository-map.md <<'EOF'
# Repository Map

The repository is split into a standard, official reference houses, community contributions and tooling.

```text
open-housing-standard/
├── standard/      # The OHS specification
├── reference/     # Official reference houses: OH90, OH120, OH150
├── community/     # Community houses, examples and plugins
├── cad/           # Shared CAD/BIM templates and assets
├── config/        # Global configuration defaults
├── schemas/       # JSON schemas for YAML/JSON validation
├── scripts/       # Generation and validation scripts
├── templates/     # Jinja/CSV/Markdown templates
├── docs/          # Project documentation and ADRs
├── assets/        # Logos, icons, renders and textures
└── tests/         # Automated tests
```

Each official house model keeps all model-specific files under its own folder:

```text
reference/oh120/
├── config/house.yaml
├── cad/source/
├── cad/ifc/
├── drawings/
├── exports/
├── bom/
├── renders/
└── docs/
```
EOF

cat > reference/README.md <<'EOF'
# Reference Houses

Official OHS reference implementations:

- `oh90` — Ousdal Hus 90
- `oh120` — Ousdal Hus 120
- `oh150` — Ousdal Hus 150

Reference houses demonstrate how the Open Housing Standard can be implemented in practical, buildable designs.
EOF

cat > community/README.md <<'EOF'
# Community

Community contributions live here.

Examples:

- Alternative house models that follow OHS
- Experimental modules
- Tooling plugins
- Regional adaptations

Community designs are not official reference houses unless promoted into `reference/`.
EOF

cat > cad/README.md <<'EOF'
# CAD and BIM

Shared CAD/BIM resources for OHS.

Canonical stack:

- FreeCAD for parametric source models
- IFC for BIM exchange
- Blender / BlenderBIM for visualization
- YAML for model configuration
- Markdown for documentation
EOF

# -----------------------------------------------------------------------------
# 6. Rewrite scripts to use canonical oh* paths
# -----------------------------------------------------------------------------
cat > scripts/validate_config.py <<'EOF'
#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys
import yaml

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "reference"

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
        errors.append(f"{path}: OHS reference houses must be single-storey")

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
    paths = sorted(REFERENCE.glob("oh*/config/house.yaml"))
    if not paths:
        print("No reference house configs found", file=sys.stderr)
        return 1

    errors: list[str] = []
    for path in paths:
        errors.extend(validate_house_config(path))

    if errors:
        print("OHS validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"OHS validation passed for {len(paths)} reference houses.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
EOF

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

    for config in sorted(REFERENCE.glob("oh*/config/house.yaml")):
        data = yaml.safe_load(config.read_text(encoding="utf-8"))
        output = config.parents[1] / "docs" / "generated-report.md"
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(template.render(**data), encoding="utf-8")
        print(f"Wrote {output}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
EOF

cat > scripts/generate_bom.py <<'EOF'
#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import csv
import yaml

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "reference"


def main() -> int:
    for config in sorted(REFERENCE.glob("oh*/config/house.yaml")):
        data = yaml.safe_load(config.read_text(encoding="utf-8"))
        model_dir = config.parents[1]
        output = model_dir / "bom" / "summary.csv"
        output.parent.mkdir(parents=True, exist_ok=True)
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

cat > scripts/generate_ifc.py <<'EOF'
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
EOF

cat > scripts/generate_svg.py <<'EOF'
#!/usr/bin/env python3
"""Placeholder for future SVG floorplan generation."""


def main() -> int:
    print("SVG floorplan generation is not implemented yet.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
EOF

cat > scripts/render_blender.py <<'EOF'
#!/usr/bin/env python3
"""Placeholder for future Blender rendering automation."""


def main() -> int:
    print("Blender rendering is not implemented yet.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
EOF

chmod +x scripts/*.py

# -----------------------------------------------------------------------------
# 7. Rewrite tests for canonical paths
# -----------------------------------------------------------------------------
cat > tests/test_configs.py <<'EOF'
from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[1]


def _configs():
    return sorted(ROOT.glob("reference/oh*/config/house.yaml"))


def test_reference_models_exist():
    configs = _configs()
    assert {path.parents[1].name for path in configs} == {"oh90", "oh120", "oh150"}


def test_reference_models_have_dry_technical_room():
    for config in _configs():
        data = yaml.safe_load(config.read_text())
        assert data["rooms"]["dry_technical_room_m2"] >= 4.0
        assert data["technical_zones"]["dry_technical_room"]["water_installations_allowed"] is False


def test_reference_models_are_single_storey():
    for config in _configs():
        data = yaml.safe_load(config.read_text())
        assert data["house"]["floors"] == 1
EOF

# -----------------------------------------------------------------------------
# 8. Patch pyproject default model if present
# -----------------------------------------------------------------------------
if [[ -f pyproject.toml ]]; then
  python3 - <<'PY'
from pathlib import Path
p = Path('pyproject.toml')
s = p.read_text(encoding='utf-8')
s = s.replace('default_model = "ousdal-hus-120"', 'default_model = "oh120"')
p.write_text(s, encoding='utf-8')
PY
fi

# -----------------------------------------------------------------------------
# 9. Add README files for reference models if missing and patch configs IDs/names
# -----------------------------------------------------------------------------
for model in oh90 oh120 oh150; do
  n="${HOUSE_NUM[$model]}"
  if [[ ! -f "reference/$model/README.md" ]]; then
    cat > "reference/$model/README.md" <<EOF
# Ousdal Hus $n

Official OHS reference house.

- Short ID: \\`$model\\`
- Target BRA: approximately $n m²
- Storeys: one
- Standard options: basement, carport, garage
EOF
  fi

  if [[ -f "reference/$model/config/house.yaml" ]]; then
    python3 - "$model" "$n" <<'PY'
from pathlib import Path
import sys
model, n = sys.argv[1], sys.argv[2]
p = Path(f"reference/{model}/config/house.yaml")
s = p.read_text(encoding="utf-8")
s = s.replace(f"id: ousdal-hus-{n}", f"id: {model}")
s = s.replace(f"model_id: ousdal-hus-{n}", f"model_id: {model}")
p.write_text(s, encoding="utf-8")
PY
  fi
done

# -----------------------------------------------------------------------------
# 10. Update .gitignore for generated/cache files while keeping design artifacts possible
# -----------------------------------------------------------------------------
cat > .gitignore <<'EOF'
# Python
.venv/
__pycache__/
*.py[cod]
.pytest_cache/
.ruff_cache/

# OS/editor
.DS_Store
Thumbs.db
.vscode/
.idea/

# Generated temporary files
*.tmp
*.log

# Large exported/generated artifacts can be tracked deliberately if needed.
# Prefer Git LFS later for large CAD/BIM/binary assets.
EOF

# Keep empty directories visible to git.
find assets cad community docs reference schemas standard templates tests -type d -empty -exec sh -c 'touch "$1/.gitkeep"' _ {} \;

say "Done. Canonical structure is now: standard/, reference/oh90|oh120|oh150/, cad/, config/, schemas/, scripts/, templates/, docs/, assets/, tests/."
say "Next commands:"
printf '  uv sync --all-extras --dev\n'
printf '  uv run python scripts/validate_config.py\n'
printf '  uv run python scripts/generate_model_report.py\n'
printf '  uv run python scripts/generate_bom.py\n'
printf '  uv run pytest\n'
printf '  git status\n'
