#!/usr/bin/env bash
# File: setup.sh
# Purpose: Deploy HumanSpark engineering standards to user and project level.
# Project: HumanSpark Engineering Standards | Date: 2026-03-12
#
# Overview: Copies user-level CLAUDE.md to ~/.claude/ (applies to all projects).
# Optionally copies project template files into a target project directory.
# With --update, merges new deny/allow rules into existing settings.json and
# appends missing entries to .gitignore without overwriting project customizations.
# Checks for forgejo-mcp binary and env credentials.
# Never overwrites project-specific files (CLAUDE.md, HANDOFF.md, .mcp.json).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Parse flags ---
UPDATE_MODE=false
DRY_RUN=false
TARGET=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --update)
            UPDATE_MODE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -*)
            echo "Unknown flag: $1"
            echo "Usage: ./setup.sh [--update] [--dry-run] [/path/to/project]"
            exit 1
            ;;
        *)
            TARGET="$1"
            shift
            ;;
    esac
done

echo "=== HumanSpark Standards Setup ==="
if $UPDATE_MODE; then
    echo "    Mode: UPDATE (merge new rules into existing files)"
fi
if $DRY_RUN; then
    echo "    Mode: DRY RUN (show changes without applying)"
fi
echo ""

# --- User-level deployment ---
echo "1. Deploying user-level AI instructions..."
if $DRY_RUN; then
    if diff -q "$SCRIPT_DIR/user-level/CLAUDE.md" ~/.claude/CLAUDE.md &>/dev/null; then
        echo "   No changes to ~/.claude/CLAUDE.md"
    else
        echo "   Would update: ~/.claude/CLAUDE.md"
    fi
else
    mkdir -p ~/.claude
    cp "$SCRIPT_DIR/user-level/CLAUDE.md" ~/.claude/CLAUDE.md
    echo "   Installed: ~/.claude/CLAUDE.md"
fi
echo ""

# --- Forgejo MCP binary check ---
echo "2. Checking for forgejo-mcp..."
if command -v forgejo-mcp &>/dev/null; then
    echo "   Found: $(which forgejo-mcp)"
elif command -v go &>/dev/null; then
    if $DRY_RUN; then
        echo "   Not found. Would install via: go install github.com/raohwork/forgejo-mcp@latest"
    else
        echo "   Not found. Installing via: go install github.com/raohwork/forgejo-mcp@latest"
        go install github.com/raohwork/forgejo-mcp@latest
        echo "   Installed to: $(go env GOPATH)/bin/forgejo-mcp"
    fi
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

# --- Helper: merge settings.json (additive only) ---
merge_settings_json() {
    local target_file="$1"
    local template_file="$2"
    local dry_run="$3"

    MERGE_TARGET="$target_file" MERGE_TEMPLATE="$template_file" MERGE_DRY_RUN="$dry_run" python3 << 'PYEOF'
import json
import os

target_path = os.environ["MERGE_TARGET"]
template_path = os.environ["MERGE_TEMPLATE"]
dry_run = os.environ["MERGE_DRY_RUN"] == "true"

with open(target_path) as f:
    target = json.load(f)
with open(template_path) as f:
    template = json.load(f)

changes = []

# Merge permissions.deny (additive)
target_deny = set(target.get("permissions", {}).get("deny", []))
template_deny = set(template.get("permissions", {}).get("deny", []))
new_deny = template_deny - target_deny
if new_deny:
    changes.append(f"  + deny rules: {', '.join(sorted(new_deny))}")
    if "permissions" not in target:
        target["permissions"] = {}
    target["permissions"]["deny"] = sorted(target_deny | template_deny)

# Merge permissions.allow (additive)
target_allow = set(target.get("permissions", {}).get("allow", []))
template_allow = set(template.get("permissions", {}).get("allow", []))
new_allow = template_allow - target_allow
if new_allow:
    changes.append(f"  + allow rules: {', '.join(sorted(new_allow))}")
    if "permissions" not in target:
        target["permissions"] = {}
    target["permissions"]["allow"] = sorted(target_allow | template_allow)

if not changes:
    print("   No new rules to add to .claude/settings.json")
    raise SystemExit(0)

for change in changes:
    print(change)

if dry_run:
    print("   Would update: .claude/settings.json")
else:
    with open(target_path, "w") as f:
        json.dump(target, f, indent=2)
        f.write("\n")
    print("   Updated: .claude/settings.json")
PYEOF
}

# --- Helper: merge .gitignore (append missing entries) ---
merge_gitignore() {
    local target_file="$1"
    local template_file="$2"
    local dry_run="$3"

    local added=0
    local new_entries=""

    while IFS= read -r line; do
        # Skip empty lines and comments for matching
        if [[ -z "$line" ]] || [[ "$line" == \#* ]]; then
            continue
        fi
        if ! grep -qxF "$line" "$target_file" 2>/dev/null; then
            new_entries+="$line"$'\n'
            added=$((added + 1))
        fi
    done < "$template_file"

    if [ "$added" -eq 0 ]; then
        echo "   No new entries to add to .gitignore"
        return
    fi

    echo "   + $added new .gitignore entries"
    if $dry_run; then
        echo "   Would update: .gitignore"
        while IFS= read -r entry; do
            [ -n "$entry" ] && echo "     $entry" || true
        done <<< "$new_entries"
    else
        {
            echo ""
            echo "# HumanSpark standards (auto-added)"
            echo "$new_entries"
        } >> "$target_file"
        echo "   Updated: .gitignore"
    fi
}

# --- Project-level deployment ---
if [ -n "$TARGET" ]; then
    if [ ! -d "$TARGET" ]; then
        echo "   ERROR: $TARGET is not a directory"
        exit 1
    fi

    if $UPDATE_MODE; then
        # === UPDATE MODE: merge into existing files ===
        echo "4. Updating project: $TARGET"

        # Ensure directories exist
        if ! $DRY_RUN; then
            mkdir -p "$TARGET/.claude/skills" "$TARGET/.claude/agents" "$TARGET/.claude/rules"
        fi

        # Merge settings.json
        if [ -f "$TARGET/.claude/settings.json" ]; then
            merge_settings_json \
                "$TARGET/.claude/settings.json" \
                "$SCRIPT_DIR/project-template/.claude/settings.json" \
                "$DRY_RUN"
        else
            if $DRY_RUN; then
                echo "   Would create: .claude/settings.json"
            else
                cp "$SCRIPT_DIR/project-template/.claude/settings.json" "$TARGET/.claude/settings.json"
                echo "   Created: .claude/settings.json"
            fi
        fi

        # Merge .gitignore
        if [ -f "$TARGET/.gitignore" ]; then
            merge_gitignore \
                "$TARGET/.gitignore" \
                "$SCRIPT_DIR/project-template/.gitignore" \
                "$DRY_RUN"
        else
            if $DRY_RUN; then
                echo "   Would create: .gitignore"
            else
                cp "$SCRIPT_DIR/project-template/.gitignore" "$TARGET/.gitignore"
                echo "   Created: .gitignore"
            fi
        fi

        # Create missing rules (same as init - never overwrites)
        for rule in "$SCRIPT_DIR"/project-template/.claude/rules/*.md; do
            rule_name=$(basename "$rule")
            if [ ! -f "$TARGET/.claude/rules/$rule_name" ]; then
                if $DRY_RUN; then
                    echo "   Would create: .claude/rules/$rule_name"
                else
                    cp "$rule" "$TARGET/.claude/rules/$rule_name"
                    echo "   Created: .claude/rules/$rule_name"
                fi
            fi
        done

        # Create missing skills (same as init - never overwrites)
        for skill_dir in "$SCRIPT_DIR"/project-template/.claude/skills/*/; do
            skill_name=$(basename "$skill_dir")
            if [ ! -d "$TARGET/.claude/skills/$skill_name" ]; then
                if $DRY_RUN; then
                    echo "   Would create: .claude/skills/$skill_name/"
                else
                    cp -r "$skill_dir" "$TARGET/.claude/skills/$skill_name"
                    echo "   Created: .claude/skills/$skill_name/"
                fi
            fi
        done

        # Create missing agents (same as init - never overwrites)
        for agent in "$SCRIPT_DIR"/project-template/.claude/agents/*.md; do
            agent_name=$(basename "$agent")
            if [ ! -f "$TARGET/.claude/agents/$agent_name" ]; then
                if $DRY_RUN; then
                    echo "   Would create: .claude/agents/$agent_name"
                else
                    cp "$agent" "$TARGET/.claude/agents/$agent_name"
                    echo "   Created: .claude/agents/$agent_name"
                fi
            fi
        done

        echo ""
        echo "   Project updated. Skipped: CLAUDE.md, HANDOFF.md, .mcp.json (project-specific)"
    else
        # === INIT MODE: create missing files only ===
        echo "4. Initialising project: $TARGET"

        # Create directories
        if ! $DRY_RUN; then
            mkdir -p "$TARGET/.claude/skills" "$TARGET/.claude/agents" "$TARGET/.claude/rules"
        fi

        # Copy settings.json
        if [ ! -f "$TARGET/.claude/settings.json" ]; then
            if $DRY_RUN; then
                echo "   Would create: .claude/settings.json"
            else
                cp "$SCRIPT_DIR/project-template/.claude/settings.json" "$TARGET/.claude/settings.json"
                echo "   Created: .claude/settings.json"
            fi
        else
            echo "   Exists:  .claude/settings.json (skipped)"
        fi

        # Copy skills
        for skill_dir in "$SCRIPT_DIR"/project-template/.claude/skills/*/; do
            skill_name=$(basename "$skill_dir")
            if [ ! -d "$TARGET/.claude/skills/$skill_name" ]; then
                if $DRY_RUN; then
                    echo "   Would create: .claude/skills/$skill_name/"
                else
                    cp -r "$skill_dir" "$TARGET/.claude/skills/$skill_name"
                    echo "   Created: .claude/skills/$skill_name/"
                fi
            else
                echo "   Exists:  .claude/skills/$skill_name/ (skipped)"
            fi
        done

        # Copy rules
        for rule in "$SCRIPT_DIR"/project-template/.claude/rules/*.md; do
            rule_name=$(basename "$rule")
            if [ ! -f "$TARGET/.claude/rules/$rule_name" ]; then
                if $DRY_RUN; then
                    echo "   Would create: .claude/rules/$rule_name"
                else
                    cp "$rule" "$TARGET/.claude/rules/$rule_name"
                    echo "   Created: .claude/rules/$rule_name"
                fi
            else
                echo "   Exists:  .claude/rules/$rule_name (skipped)"
            fi
        done

        # Copy agents
        for agent in "$SCRIPT_DIR"/project-template/.claude/agents/*.md; do
            agent_name=$(basename "$agent")
            if [ ! -f "$TARGET/.claude/agents/$agent_name" ]; then
                if $DRY_RUN; then
                    echo "   Would create: .claude/agents/$agent_name"
                else
                    cp "$agent" "$TARGET/.claude/agents/$agent_name"
                    echo "   Created: .claude/agents/$agent_name"
                fi
            else
                echo "   Exists:  .claude/agents/$agent_name (skipped)"
            fi
        done

        # Copy .mcp.json
        if [ ! -f "$TARGET/.mcp.json" ]; then
            if $DRY_RUN; then
                echo "   Would create: .mcp.json"
            else
                cp "$SCRIPT_DIR/project-template/.mcp.json" "$TARGET/.mcp.json"
                echo "   Created: .mcp.json"
            fi
        else
            echo "   Exists:  .mcp.json (skipped)"
        fi

        # Copy .gitignore
        if [ ! -f "$TARGET/.gitignore" ]; then
            if $DRY_RUN; then
                echo "   Would create: .gitignore"
            else
                cp "$SCRIPT_DIR/project-template/.gitignore" "$TARGET/.gitignore"
                echo "   Created: .gitignore"
            fi
        else
            echo "   Exists:  .gitignore (skipped)"
        fi

        # Copy HANDOFF.md
        if [ ! -f "$TARGET/HANDOFF.md" ]; then
            if $DRY_RUN; then
                echo "   Would create: HANDOFF.md"
            else
                cp "$SCRIPT_DIR/project-template/HANDOFF.md" "$TARGET/HANDOFF.md"
                echo "   Created: HANDOFF.md"
            fi
        else
            echo "   Exists:  HANDOFF.md (skipped)"
        fi

        # Copy CLAUDE.md template only if none exists
        if [ ! -f "$TARGET/CLAUDE.md" ]; then
            if $DRY_RUN; then
                echo "   Would create: CLAUDE.md"
            else
                cp "$SCRIPT_DIR/project-template/CLAUDE.md" "$TARGET/CLAUDE.md"
                echo "   Created: CLAUDE.md (template - fill in project details)"
            fi
        else
            echo "   Exists:  CLAUDE.md (skipped)"
        fi

        # Copy docs directory templates
        if ! $DRY_RUN; then
            mkdir -p "$TARGET/docs"
        fi
        if [ ! -f "$TARGET/docs/MODULE-README-TEMPLATE.md" ]; then
            if $DRY_RUN; then
                echo "   Would create: docs/MODULE-README-TEMPLATE.md"
            else
                cp "$SCRIPT_DIR/project-template/docs/MODULE-README-TEMPLATE.md" "$TARGET/docs/MODULE-README-TEMPLATE.md"
                echo "   Created: docs/MODULE-README-TEMPLATE.md"
            fi
        else
            echo "   Exists:  docs/MODULE-README-TEMPLATE.md (skipped)"
        fi

        # Copy starter source templates (only if src/ exists or is being created)
        if [ -d "$TARGET/src" ]; then
            if [ ! -f "$TARGET/src/models.py" ]; then
                if ! find "$TARGET/src" -name "models.py" -print -quit 2>/dev/null | grep -q .; then
                    if $DRY_RUN; then
                        echo "   Would create: src/models.py"
                    else
                        cp "$SCRIPT_DIR/project-template/src/models.py" "$TARGET/src/models.py"
                        echo "   Created: src/models.py (starter template)"
                    fi
                else
                    echo "   Exists:  models.py found in src/ tree (skipped)"
                fi
            else
                echo "   Exists:  src/models.py (skipped)"
            fi
            if [ ! -f "$TARGET/src/config.py" ]; then
                if ! find "$TARGET/src" -name "config.py" -print -quit 2>/dev/null | grep -q .; then
                    if $DRY_RUN; then
                        echo "   Would create: src/config.py"
                    else
                        cp "$SCRIPT_DIR/project-template/src/config.py" "$TARGET/src/config.py"
                        echo "   Created: src/config.py (starter template)"
                    fi
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
    fi
else
    echo "4. Project-level setup: skipped (no target directory provided)"
    echo "   To initialise a project:  ./setup.sh /path/to/project"
    echo "   To update a project:      ./setup.sh --update /path/to/project"
fi

echo ""
echo "=== Done ==="
