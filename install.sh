#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}Noir Circuit Audit Skill for Claude Code${NC}\n"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Claude config directories
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills/noir-audit"

# Help
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: ./install.sh"
    echo ""
    echo "Installs the Noir audit skill for Claude Code by creating"
    echo "symlinks in ~/.claude/skills/"
    echo ""
    echo "To uninstall, run: ./uninstall.sh"
    exit 0
fi

# Create directories
echo -e "${YELLOW}Setting up skill directories...${NC}"
mkdir -p "$SKILLS_DIR/resources"

# Symlink skill files
echo -e "${YELLOW}Linking skill files...${NC}"
ln -sf "$SCRIPT_DIR/skill/SKILL.md" "$SKILLS_DIR/SKILL.md"
ln -sf "$SCRIPT_DIR/skill/resources/checklist.md" "$SKILLS_DIR/resources/checklist.md"
ln -sf "$SCRIPT_DIR/skill/resources/severity-rubric.md" "$SKILLS_DIR/resources/severity-rubric.md"
ln -sf "$SCRIPT_DIR/skill/resources/report-template.md" "$SKILLS_DIR/resources/report-template.md"

echo -e "${GREEN}✓ Skill files linked${NC}\n"

# Done
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "Restart Claude Code, then try:"
echo -e "  ${YELLOW}\"Audit my Noir circuits\"${NC}"
echo -e "  ${YELLOW}/noir-audit${NC}\n"
