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
