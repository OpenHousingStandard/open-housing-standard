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
