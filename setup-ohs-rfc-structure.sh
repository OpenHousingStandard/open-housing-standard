#!/usr/bin/env bash
set -euo pipefail

# setup-ohs-rfc-structure.sh
# Creates an RFC/kernel-style document structure for the Open Housing Standard.
# Run from the repository root.

if [ ! -f "README.md" ] || [ ! -d "standard" ]; then
  echo "ERROR: Run this from the root of the open-housing-standard repository." >&2
  exit 1
fi

mkdir -p \
  standard/OHS-001 \
  standard/OHS-100 \
  standard/OHS-200 \
  standard/OHS-300 \
  standard/OHS-400 \
  standard/OHS-500 \
  standard/OHS-600 \
  standard/OHS-700 \
  standard/OHS-900 \
  standard/_template \
  docs/standards \
  docs/project \
  docs/adr

cat > standard/README.md <<'EOF'
# Open Housing Standard Documents

This directory contains the normative Open Housing Standard (OHS) document series.

## Document families

| Series | Purpose |
|---|---|
| OHS-001 | Core Open Housing Standard |
| OHS-100 | Architectural Rules |
| OHS-200 | Technical Core |
| OHS-300 | Universal Design |
| OHS-400 | Energy & Sustainability |
| OHS-500 | Documentation & Digital Assets |
| OHS-600 | Reference House Requirements |
| OHS-700 | Compliance & Certification |
| OHS-900 | Glossary and terminology |

Each standard is split into small Markdown sections to make review, discussion and pull requests easier.
EOF

cat > standard/_template/README.md <<'EOF'
# OHS-XXX: Title

**Document ID:** OHS-XXX  
**Title:** Title  
**Version:** 1.0.0-draft.1  
**Status:** Draft  
**Publisher:** Open Housing Standard  
**License:** CC BY-SA 4.0  

## Sections

1. [Introduction](01-introduction.md)
2. [Scope](02-scope.md)
3. [Normative References](03-normative-references.md)
4. [Terminology](04-terminology.md)
5. [Requirements](05-requirements.md)
6. [Conformance](06-conformance.md)
7. [Versioning](07-versioning.md)
8. [Appendix A](appendix-a.md)
EOF

for f in 01-introduction 02-scope 03-normative-references 04-terminology 05-requirements 06-conformance 07-versioning appendix-a; do
  title=$(echo "$f" | sed 's/^[0-9]*-//' | tr '-' ' ' | sed 's/.*/\u&/')
  cat > "standard/_template/${f}.md" <<EOF
# ${title}

Status: Draft

TODO.
EOF
done

cat > standard/OHS-001/README.md <<'EOF'
# OHS-001: Open Housing Standard

**Document ID:** OHS-001  
**Title:** Open Housing Standard  
**Version:** 1.0.0-draft.1  
**Status:** Draft  
**Publisher:** Open Housing Standard  
**License:** CC BY-SA 4.0  

OHS-001 defines the purpose, scope, principles, conformance model and governance structure for the Open Housing Standard.

## Sections

1. [Introduction](01-introduction.md)
2. [Scope](02-scope.md)
3. [Normative References](03-normative-references.md)
4. [Terminology](04-terminology.md)
5. [Design Principles](05-design-principles.md)
6. [Standard Architecture](06-standard-architecture.md)
7. [Conformance](07-conformance.md)
8. [Governance](08-governance.md)
9. [Versioning](09-versioning.md)
10. [Appendix A: Rationale](appendix-a-rationale.md)
11. [Appendix B: Citation Format](appendix-b-citation-format.md)
EOF

cat > standard/OHS-001/01-introduction.md <<'EOF'
# 1. Introduction

The Open Housing Standard (OHS) is an open, vendor-neutral standard for homes designed to be durable, accessible, repairable, resilient, energy-conscious and technology-friendly.

The goal of OHS is simple:

> Homes that still work well in 50 years.

OHS treats a home as both a physical building and a long-lived technical system. It therefore covers not only architectural principles, but also documentation, maintainability, technical infrastructure and digital assets.
EOF

cat > standard/OHS-001/02-scope.md <<'EOF'
# 2. Scope

OHS applies to residential buildings and reference house designs that seek to follow the Open Housing Standard.

OHS-001 defines the overall standard architecture, principles and conformance model.

OHS does not replace national building codes, local planning rules, structural engineering requirements, fire regulations or professional architectural review.
EOF

cat > standard/OHS-001/03-normative-references.md <<'EOF'
# 3. Normative References

The following documents are part of the OHS document family:

- OHS-100: Architectural Rules
- OHS-200: Technical Core
- OHS-300: Universal Design
- OHS-400: Energy & Sustainability
- OHS-500: Documentation & Digital Assets
- OHS-600: Reference House Requirements
- OHS-700: Compliance & Certification
- OHS-900: Glossary

External laws, building codes and standards remain authoritative within their jurisdictions.
EOF

cat > standard/OHS-001/04-terminology.md <<'EOF'
# 4. Terminology

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **MAY** and **OPTIONAL** are to be interpreted as normative requirement levels.

## Core terms

- **OHS-compliant house:** A house that satisfies the applicable OHS requirements.
- **Reference house:** An official example design maintained by the OHS project.
- **Technical core:** The planned location for critical technical infrastructure.
- **Technical zone:** A functional separation between wet, dry and climate-related technical systems.
- **Local-first technology:** Technology that continues to perform critical functions without dependency on external cloud services.
EOF

cat > standard/OHS-001/05-design-principles.md <<'EOF'
# 5. Design Principles

An OHS design SHOULD be guided by the following principles:

1. Durability
2. Universal accessibility
3. Repairability
4. Standardization
5. Low lifecycle cost
6. Energy consciousness
7. Local-first technology
8. Technical resilience
9. Documentation
10. Functional flexibility

Every major design decision SHOULD be explainable in terms of these principles.
EOF

cat > standard/OHS-001/06-standard-architecture.md <<'EOF'
# 6. Standard Architecture

The OHS standard is organized as a document family.

OHS-001 defines the core model. More specific documents define requirements for architecture, technical infrastructure, universal design, energy, documentation, reference houses and certification.

This structure allows individual parts of the standard to evolve without rewriting the entire standard.
EOF

cat > standard/OHS-001/07-conformance.md <<'EOF'
# 7. Conformance

A house or design MAY claim conformance with OHS only when it documents which OHS documents and versions it follows.

Example:

> This design targets OHS-001 v1.0.0-draft.1 and OHS-100 v1.0.0-draft.1.

A conformance claim MUST state whether the claim applies to a concept design, a reference design, construction documentation or a completed building.
EOF

cat > standard/OHS-001/08-governance.md <<'EOF'
# 8. Governance

OHS is developed as an open standard. Changes SHOULD be proposed through issues, discussions and pull requests.

Substantial design decisions SHOULD be recorded as Architecture Decision Records (ADRs).

The project SHOULD prefer open formats, public rationale and reproducible documentation.
EOF

cat > standard/OHS-001/09-versioning.md <<'EOF'
# 9. Versioning

OHS documents use semantic versioning where practical.

Draft documents SHOULD use the suffix `-draft.N`.

Stable documents SHOULD use version numbers such as `1.0.0`.

Breaking changes to normative requirements MUST result in a new major version.
EOF

cat > standard/OHS-001/appendix-a-rationale.md <<'EOF'
# Appendix A: Rationale

OHS is intended to be readable by homeowners, architects, builders, technologists and maintainers.

The standard therefore separates normative requirements from explanatory design handbook material.
EOF

cat > standard/OHS-001/appendix-b-citation-format.md <<'EOF'
# Appendix B: Citation Format

Recommended citation format:

> Open Housing Standard. OHS-001: Open Housing Standard, version 1.0.0-draft.1. Open Housing Standard Project.

Specific sections may be cited as:

> OHS-001 §5 Design Principles.
EOF

# Create skeletons for the remaining document families
create_family() {
  local dir="$1"
  local title="$2"
  cat > "standard/${dir}/README.md" <<EOF
# ${dir}: ${title}

**Document ID:** ${dir}  
**Title:** ${title}  
**Version:** 1.0.0-draft.1  
**Status:** Draft  
**Publisher:** Open Housing Standard  
**License:** CC BY-SA 4.0  

## Sections

1. [Introduction](01-introduction.md)
2. [Scope](02-scope.md)
3. [Requirements](03-requirements.md)
4. [Conformance](04-conformance.md)
5. [Rationale](appendix-a-rationale.md)
EOF
  cat > "standard/${dir}/01-introduction.md" <<EOF
# 1. Introduction

${title} defines requirements and guidance for this part of the Open Housing Standard.
EOF
  cat > "standard/${dir}/02-scope.md" <<EOF
# 2. Scope

TODO: Define what this document covers and does not cover.
EOF
  cat > "standard/${dir}/03-requirements.md" <<EOF
# 3. Requirements

TODO: Add normative MUST/SHOULD/MAY requirements.
EOF
  cat > "standard/${dir}/04-conformance.md" <<EOF
# 4. Conformance

TODO: Define how compliance with this document is evaluated.
EOF
  cat > "standard/${dir}/appendix-a-rationale.md" <<EOF
# Appendix A: Rationale

TODO: Explain design reasoning and tradeoffs.
EOF
}

create_family "OHS-100" "Architectural Rules"
create_family "OHS-200" "Technical Core"
create_family "OHS-300" "Universal Design"
create_family "OHS-400" "Energy & Sustainability"
create_family "OHS-500" "Documentation & Digital Assets"
create_family "OHS-600" "Reference House Requirements"
create_family "OHS-700" "Compliance & Certification"
create_family "OHS-900" "Glossary"

cat > docs/standards/README.md <<'EOF'
# Standards Guide

The OHS standard is written as a family of small, citable documents.

Start with:

- `standard/OHS-001/` — the core Open Housing Standard
- `standard/OHS-100/` — architectural rules
- `standard/OHS-200/` — technical core

Each document is split into sections to make review and pull requests manageable.
EOF

cat > docs/adr/0001-rfc-style-standard-documents.md <<'EOF'
# ADR-0001: RFC-style standard documents

## Status

Accepted

## Context

OHS should be citable, reviewable and maintainable over many years. A single large Markdown file would be difficult to review and evolve.

## Decision

OHS standard documents are organized as numbered document families such as OHS-001, OHS-100 and OHS-200. Each document is split into small Markdown sections.

## Consequences

- Sections can be reviewed independently.
- Documents can be cited by document ID and section.
- Future standards can be added without renumbering the entire series.
EOF

# Update mkdocs.yml if it exists, but do not destroy custom content.
if [ -f mkdocs.yml ]; then
  cp mkdocs.yml mkdocs.yml.bak.$(date +%Y%m%d%H%M%S)
  cat > mkdocs.yml <<'EOF'
site_name: Open Housing Standard
site_description: An open, vendor-neutral housing standard for durable, accessible and technology-friendly homes.
repo_url: https://github.com/OpenHousingStandard/open-housing-standard

theme:
  name: material

nav:
  - Home: README.md
  - Architecture: ARCHITECTURE.md
  - Standards:
      - Overview: standard/README.md
      - OHS-001 Open Housing Standard:
          - Overview: standard/OHS-001/README.md
          - Introduction: standard/OHS-001/01-introduction.md
          - Scope: standard/OHS-001/02-scope.md
          - Normative References: standard/OHS-001/03-normative-references.md
          - Terminology: standard/OHS-001/04-terminology.md
          - Design Principles: standard/OHS-001/05-design-principles.md
          - Standard Architecture: standard/OHS-001/06-standard-architecture.md
          - Conformance: standard/OHS-001/07-conformance.md
          - Governance: standard/OHS-001/08-governance.md
          - Versioning: standard/OHS-001/09-versioning.md
          - Appendix A: standard/OHS-001/appendix-a-rationale.md
          - Appendix B: standard/OHS-001/appendix-b-citation-format.md
      - OHS-100 Architectural Rules: standard/OHS-100/README.md
      - OHS-200 Technical Core: standard/OHS-200/README.md
      - OHS-300 Universal Design: standard/OHS-300/README.md
      - OHS-400 Energy & Sustainability: standard/OHS-400/README.md
      - OHS-500 Documentation & Digital Assets: standard/OHS-500/README.md
      - OHS-600 Reference Houses: standard/OHS-600/README.md
      - OHS-700 Compliance & Certification: standard/OHS-700/README.md
      - OHS-900 Glossary: standard/OHS-900/README.md
  - Project:
      - Standards Guide: docs/standards/README.md
      - ADR-0001: docs/adr/0001-rfc-style-standard-documents.md
EOF
fi

echo "OHS RFC-style standard structure created."
echo "Next steps:"
echo "  git status"
echo "  uv run mkdocs serve   # optional"
echo "  git add -A && git commit -m 'Add RFC-style OHS standard structure'"
