#!/bin/sh
# Sort _bibliography/references.bib by key and check for duplicate entries.
cd "$(dirname "$0")/.."

echo "--- duplicate check ---"
bibtool -- 'check.double = on' -- 'check.double.delete = off' _bibliography/references.bib > /dev/null

echo "--- sorted by key ---"
bibtool -s -- 'print.line.length = 9999' _bibliography/references.bib
