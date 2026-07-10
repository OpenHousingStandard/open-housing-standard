#!/usr/bin/env bash
set -euo pipefail

echo "==> Migrating repository to OHS-000..."

###############################################################################
# Create OHS-000
###############################################################################

mkdir -p standard/OHS-000

###############################################################################
# Move style guide if it exists
###############################################################################

if [ -f docs/style-guide.md ]; then
    mv docs/style-guide.md standard/OHS-000/README.md
fi

###############################################################################
# Create README if missing
###############################################################################

if [ ! -f standard/OHS-000/README.md ]; then

cat > standard/OHS-000/README.md <<'EOF'
---
Document ID: OHS-000
Title: Editorial and Documentation Style Guide
Chapter: Complete Specification

Version: 1.0.0-draft.1
Status: Draft

Category: Editorial Standard

Normative: Yes

Depends On: []

Referenced By:
  - OHS-001
  - OHS-100
  - OHS-200
  - OHS-300
  - OHS-400
  - OHS-500
  - OHS-600
  - OHS-700
  - OHS-900

Publisher: Open Housing Standard

License: CC BY-SA 4.0

Language: English

Last Updated: 2026-07-10
Next Review: Before 1.0.0-rc.1
---

# OHS-000

Editorial and Documentation Style Guide

This specification defines the editorial rules used throughout the Open Housing Standard specification series.

See subsequent sections for normative requirements.
EOF

fi

###############################################################################
# Ensure OHS-000 is referenced from standard index
###############################################################################

if [ -f standard/README.md ]; then

if ! grep -q "OHS-000" standard/README.md; then

sed -i '/# Open Housing Standard Documents/a\
\
## Editorial\
\
- [OHS-000 — Editorial and Documentation Style Guide](OHS-000/README.md)\
' standard/README.md

fi

fi

###############################################################################
# Create changelog
###############################################################################

if [ ! -f standard/OHS-000/CHANGELOG.md ]; then

cat > standard/OHS-000/CHANGELOG.md <<EOF
# Changelog

## 1.0.0-draft.1

- Initial editorial specification.
EOF

fi

###############################################################################
# Git status
###############################################################################

echo
echo "Migration complete."
echo
git status

echo
echo "Next:"
echo "git add -A"
echo 'git commit -m "Add OHS-000 Editorial Standard"'
echo "git push"
