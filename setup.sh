#!/usr/bin/env bash
# File: setup.sh
# Purpose: Deploy HumanSpark engineering standards to user and project level.
# Project: HumanSpark Engineering Standards | Date: 2026-03-12
#
# Overview: Copies user-level CLAUDE.md to ~/.claude/ (applies to all projects).
# Optionally copies project template files into a target project directory.
# Checks for forgejo-mcp binary and env credentials.
# Never overwrites existing files in target projects.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== HumanSpark Standards Setup ==="
echo ""

# --- User-level deployment ---
echo "1. Deploying user-level AI instructions..."
mkdir -p ~/.claude
cp "$SCRIPT_DIR/user-level/CLAUDE.md" ~/.claude/CLAUDE.md
echo "   Installed: ~/.claude/CLAUDE.md"
echo ""

# --- Forgejo MCP binary check ---
echo "2. Checking for forgejo-mcp..."
if command -v forgejo-mcp &>/dev/null; then
    echo "   Found: $(which forgejo-mcp)"
elif command -v go &>/dev/null; then
    echo "   Not found. Installing via: go install github.com/raohwork/forgejo-mcp@latest"
    go install github.com/raohwork/forgejo-mcp@latest
    echo "   Installed to: $(go env GOPATH)/bin/forgejo-mcp"
else
    echo "   Not found. Go not installed. Install manually:"
    echo "   https://github.com/raohwork/forgejo-mcp/releases"
fi
echo ""

# --- Environment variable check ---
echo "3. Checking Forgejo credentials..."
if [ -f ~/.env.shared ]; then
    if grep -qi "FORGEJO_URL\|GITEA_URL" ~/.env.shared; then
        echo "   Found URL in ~/.env.shared"
    else
        echo "   WARNING: No FORGEJO_URL in ~/.env.shared"
        echo "   Add: FORGEJO_URL=https://your-forgejo-instance.com"
    fi
    if grep -qi "FORGEJO_TOKEN\|GITEA_TOKEN" ~/.env.shared; then
        echo "   Found TOKEN in ~/.env.shared"
    else
        echo "   WARNING: No FORGEJO_TOKEN in ~/.env.shared"
        echo "   Generate at: Settings > Applications > Access Tokens on your Forgejo instance"
    fi
else
    echo "   WARNING: ~/.env.shared not found"
fi
echo ""

# --- Project-level deployment (optional) ---
if [ -n "${1:-}" ]; then
    TARGET="$1"
    echo "4. Initialising project: $TARGET"

    if [ ! -d "$TARGET" ]; then
        echo "   ERROR: $TARGET is not a directory"
        exit 1
    fi

    # Create directories
    mkdir -p "$TARGET/.claude/skills" "$TARGET/.claude/agents" "$TARGET/.claude/rules"

    # Copy settings.json
    if [ ! -f "$TARGET/.claude/settings.json" ]; then
        cp "$SCRIPT_DIR/project-template/.claude/settings.json" "$TARGET/.claude/settings.json"
        echo "   Created: .claude/settings.json"
    else
        echo "   Exists:  .claude/settings.json (skipped)"
    fi

    # Copy skills
    for skill_dir in "$SCRIPT_DIR"/project-template/.claude/skills/*/; do
        skill_name=$(basename "$skill_dir")
        if [ ! -d "$TARGET/.claude/skills/$skill_name" ]; then
            cp -r "$skill_dir" "$TARGET/.claude/skills/$skill_name"
            echo "   Created: .claude/skills/$skill_name/"
        else
            echo "   Exists:  .claude/skills/$skill_name/ (skipped)"
        fi
    done

    # Copy rules
    for rule in "$SCRIPT_DIR"/project-template/.claude/rules/*.md; do
        rule_name=$(basename "$rule")
        if [ ! -f "$TARGET/.claude/rules/$rule_name" ]; then
            cp "$rule" "$TARGET/.claude/rules/$rule_name"
            echo "   Created: .claude/rules/$rule_name"
        else
            echo "   Exists:  .claude/rules/$rule_name (skipped)"
        fi
    done

    # Copy agents
    for agent in "$SCRIPT_DIR"/project-template/.claude/agents/*.md; do
        agent_name=$(basename "$agent")
        if [ ! -f "$TARGET/.claude/agents/$agent_name" ]; then
            cp "$agent" "$TARGET/.claude/agents/$agent_name"
            echo "   Created: .claude/agents/$agent_name"
        else
            echo "   Exists:  .claude/agents/$agent_name (skipped)"
        fi
    done

    # Copy .mcp.json
    if [ ! -f "$TARGET/.mcp.json" ]; then
        cp "$SCRIPT_DIR/project-template/.mcp.json" "$TARGET/.mcp.json"
        echo "   Created: .mcp.json"
    else
        echo "   Exists:  .mcp.json (skipped)"
    fi

    # Copy .gitignore
    if [ ! -f "$TARGET/.gitignore" ]; then
        cp "$SCRIPT_DIR/project-template/.gitignore" "$TARGET/.gitignore"
        echo "   Created: .gitignore"
    else
        echo "   Exists:  .gitignore (skipped)"
    fi

    # Copy HANDOFF.md
    if [ ! -f "$TARGET/HANDOFF.md" ]; then
        cp "$SCRIPT_DIR/project-template/HANDOFF.md" "$TARGET/HANDOFF.md"
        echo "   Created: HANDOFF.md"
    else
        echo "   Exists:  HANDOFF.md (skipped)"
    fi

    # Copy CLAUDE.md template only if none exists
    if [ ! -f "$TARGET/CLAUDE.md" ]; then
        cp "$SCRIPT_DIR/project-template/CLAUDE.md" "$TARGET/CLAUDE.md"
        echo "   Created: CLAUDE.md (template - fill in project details)"
    else
        echo "   Exists:  CLAUDE.md (skipped)"
    fi

    # Copy docs directory templates
    mkdir -p "$TARGET/docs"
    if [ ! -f "$TARGET/docs/MODULE-README-TEMPLATE.md" ]; then
        cp "$SCRIPT_DIR/project-template/docs/MODULE-README-TEMPLATE.md" "$TARGET/docs/MODULE-README-TEMPLATE.md"
        echo "   Created: docs/MODULE-README-TEMPLATE.md"
    else
        echo "   Exists:  docs/MODULE-README-TEMPLATE.md (skipped)"
    fi

    # Copy starter source templates (only if src/ exists or is being created)
    # These are reference files - the developer renames projectname/ to match
    # their actual project and fills in the TODO sections.
    if [ -d "$TARGET/src" ]; then
        if [ ! -f "$TARGET/src/models.py" ]; then
            # Only deploy to src/ root if no models.py exists anywhere in src/
            if ! find "$TARGET/src" -name "models.py" -print -quit 2>/dev/null | grep -q .; then
                cp "$SCRIPT_DIR/project-template/src/models.py" "$TARGET/src/models.py"
                echo "   Created: src/models.py (starter template)"
            else
                echo "   Exists:  models.py found in src/ tree (skipped)"
            fi
        else
            echo "   Exists:  src/models.py (skipped)"
        fi
        if [ ! -f "$TARGET/src/config.py" ]; then
            if ! find "$TARGET/src" -name "config.py" -print -quit 2>/dev/null | grep -q .; then
                cp "$SCRIPT_DIR/project-template/src/config.py" "$TARGET/src/config.py"
                echo "   Created: src/config.py (starter template)"
            else
                echo "   Exists:  config.py found in src/ tree (skipped)"
            fi
        else
            echo "   Exists:  src/config.py (skipped)"
        fi
    else
        echo "   Note:    No src/ directory - skipping models.py and config.py templates"
        echo "            Create src/ and re-run to deploy, or copy from project-template/src/"
    fi

    echo ""
    echo "   Project initialised. Review and fill in CLAUDE.md template."
else
    echo "4. Project-level setup: skipped (no target directory provided)"
    echo "   To initialise a project: ./setup.sh /path/to/project"
fi

echo ""
echo "=== Done ==="
