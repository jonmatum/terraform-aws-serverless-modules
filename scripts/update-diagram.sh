#!/bin/bash
set -e

DIAGRAM_FILE="docs/images/architecture.mmd"
OUTPUT_LIGHT="docs/images/architecture.png"
OUTPUT_DARK="docs/images/architecture-dark.png"

echo "Generating light mode diagram..."
npx -y -p @mermaid-js/mermaid-cli mmdc -i "$DIAGRAM_FILE" -o "$OUTPUT_LIGHT" -b white

echo "Generating dark mode diagram..."
npx -y -p @mermaid-js/mermaid-cli mmdc -i "$DIAGRAM_FILE" -o "$OUTPUT_DARK" -b "#0d1117" -t dark

echo "✓ Diagrams updated:"
echo "  - $OUTPUT_LIGHT (light mode)"
echo "  - $OUTPUT_DARK (dark mode)"
echo ""
echo "Don't forget to update the mermaid code block in README.md if you changed the diagram!"
