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
