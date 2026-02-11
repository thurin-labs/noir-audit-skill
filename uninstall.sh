#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Uninstalling Noir Circuit Audit Skill...${NC}\n"

# Claude config directories
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills/noir-audit"

# Remove skill directory
if [ -d "$SKILLS_DIR" ]; then
    rm -rf "$SKILLS_DIR"
    echo -e "${GREEN}✓ Removed skill directory${NC}"
else
    echo -e "${YELLOW}⚠ Skill directory not found${NC}"
fi

echo -e "\n${GREEN}Uninstall complete!${NC}\n"
