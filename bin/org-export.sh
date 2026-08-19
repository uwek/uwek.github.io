#!/bin/sh
# Export a single Org file to a Jekyll post markdown file.
# Usage: bin/org-export.sh _org/2026-08-18-example.org _posts/2026-08-18-example.markdown
set -e
cd "$(dirname "$0")/.."
emacs --batch -Q --load bin/org-export.el "$1" "$2"
