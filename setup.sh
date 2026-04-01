#!/usr/bin/env bash
# File: setup.sh
# Purpose: Deploy HumanSpark engineering standards to user and project level.
# Project: HumanSpark Engineering Standards | Date: 2026-03-12
#
# Overview: Deploys user-level CLAUDE.md and rules to ~/.claude/. Syncs all
# project-level template-managed files (skills, agents, rules, docs templates)
# by default - creates missing files and updates stale ones. With --init,
# also creates project-specific files (CLAUDE.md, HANDOFF.md) that
# are never touched during normal sync. With no target, auto-discovers all
# projects in home directory.
#
# Usage:
#   ./setup.sh                           Sync user-level + all projects
#   ./setup.sh ~/project                 Sync user-level + one project
#   ./setup.sh --init ~/new-project      Sync + create project-specific files
#   ./setup.sh --dry-run                 Preview changes without applying

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/project-template"

# --- Parse flags ---
INIT_MODE=false
DRY_RUN=false
TARGETS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --init)
            INIT_MODE=true
            shift
            ;;
        --update|--sync)
            # Backwards compat - sync is now the default, these are no-ops
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -*)
            echo "Unknown flag: $1"
            echo "Usage: ./setup.sh [--init] [--dry-run] [/path/to/project ...]"
            exit 1
            ;;
        *)
            TARGETS+=("$1")
            shift
            ;;
    esac
done

echo "=== HumanSpark Standards Setup ==="
if $INIT_MODE; then
    echo "    Mode: INIT (sync + create project-specific files)"
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
    if [ -d "$SCRIPT_DIR/user-level/rules" ]; then
        for rule in "$SCRIPT_DIR"/user-level/rules/*.md; do
            [ -f "$rule" ] || continue
            rule_name=$(basename "$rule")
            if diff -q "$rule" ~/.claude/rules/"$rule_name" &>/dev/null 2>&1; then
                echo "   No changes to ~/.claude/rules/$rule_name"
            else
                echo "   Would update: ~/.claude/rules/$rule_name"
            fi
        done
    fi
else
    mkdir -p ~/.claude
    cp "$SCRIPT_DIR/user-level/CLAUDE.md" ~/.claude/CLAUDE.md
    echo "   Installed: ~/.claude/CLAUDE.md"
    if [ -d "$SCRIPT_DIR/user-level/rules" ]; then
        mkdir -p ~/.claude/rules
        for rule in "$SCRIPT_DIR"/user-level/rules/*.md; do
            [ -f "$rule" ] || continue
            rule_name=$(basename "$rule")
            cp "$rule" ~/.claude/rules/"$rule_name"
            echo "   Installed: ~/.claude/rules/$rule_name"
        done
    fi
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

# --- Helper: create or sync a file ---
# Creates the file if missing, updates it if stale. Reports action taken.
create_or_sync() {
    local template="$1"
    local target="$2"
    local label="$3"
    local dry_run="$4"

    if [ ! -f "$target" ]; then
        if $dry_run; then
            echo "   Would create: $label"
        else
            mkdir -p "$(dirname "$target")"
            cp "$template" "$target"
            echo "   Created: $label"
        fi
    elif ! diff -q "$template" "$target" &>/dev/null; then
        if $dry_run; then
            echo "   Would sync: $label"
        else
            cp "$template" "$target"
            echo "   Synced: $label"
        fi
    fi
}

# --- Helper: sync one project ---
sync_project() {
    local target="$1"
    local dry_run="$2"

    # Ensure directories exist
    if ! $dry_run; then
        mkdir -p "$target/.claude/skills" "$target/.claude/agents" "$target/.claude/rules"
    fi

    # settings.json: merge if exists, create if missing
    if [ -f "$target/.claude/settings.json" ]; then
        merge_settings_json \
            "$target/.claude/settings.json" \
            "$TEMPLATE_DIR/.claude/settings.json" \
            "$dry_run"
    else
        create_or_sync "$TEMPLATE_DIR/.claude/settings.json" \
            "$target/.claude/settings.json" ".claude/settings.json" "$dry_run"
    fi

    # .gitignore: merge if exists, create if missing
    if [ -f "$target/.gitignore" ]; then
        merge_gitignore "$target/.gitignore" "$TEMPLATE_DIR/.gitignore" "$dry_run"
    else
        create_or_sync "$TEMPLATE_DIR/.gitignore" "$target/.gitignore" ".gitignore" "$dry_run"
    fi

    # Skills: create missing + update stale
    for skill_dir in "$TEMPLATE_DIR"/.claude/skills/*/; do
        skill_name=$(basename "$skill_dir")
        template="$skill_dir/SKILL.md"
        skill_target="$target/.claude/skills/$skill_name/SKILL.md"
        [ -f "$template" ] || continue
        create_or_sync "$template" "$skill_target" \
            ".claude/skills/$skill_name/SKILL.md" "$dry_run"
    done

    # Agents: create missing + update stale
    for agent in "$TEMPLATE_DIR"/.claude/agents/*.md; do
        [ -f "$agent" ] || continue
        agent_name=$(basename "$agent")
        create_or_sync "$agent" "$target/.claude/agents/$agent_name" \
            ".claude/agents/$agent_name" "$dry_run"
    done

    # Rules: create missing + update stale (guard deployment.md if customized)
    for rule in "$TEMPLATE_DIR"/.claude/rules/*.md; do
        [ -f "$rule" ] || continue
        rule_name=$(basename "$rule")
        rule_target="$target/.claude/rules/$rule_name"

        if [ "$rule_name" = "deployment.md" ] && [ -f "$rule_target" ]; then
            # Only sync deployment.md if it still contains template placeholders
            if grep -q '{describe production' "$rule_target" 2>/dev/null; then
                create_or_sync "$rule" "$rule_target" \
                    ".claude/rules/$rule_name (uncustomized)" "$dry_run"
            fi
        else
            create_or_sync "$rule" "$rule_target" \
                ".claude/rules/$rule_name" "$dry_run"
        fi
    done

    # Docs templates: create missing + update stale
    if ! $dry_run; then
        mkdir -p "$target/docs/plans"
    fi
    if [ ! -f "$target/docs/plans/.gitkeep" ]; then
        if $dry_run; then
            echo "   Would create: docs/plans/.gitkeep"
        else
            mkdir -p "$target/docs/plans"
            touch "$target/docs/plans/.gitkeep"
            echo "   Created: docs/plans/.gitkeep"
        fi
    fi

    for doc_template in MODULE-README-TEMPLATE.md SPEC-TEMPLATE.md; do
        if [ -f "$TEMPLATE_DIR/docs/$doc_template" ]; then
            create_or_sync "$TEMPLATE_DIR/docs/$doc_template" \
                "$target/docs/$doc_template" "docs/$doc_template" "$dry_run"
        fi
    done
}

# --- Helper: init a new project (sync + project-specific files) ---
init_project() {
    local target="$1"
    local dry_run="$2"

    # Run full sync first
    sync_project "$target" "$dry_run"

    # Then create project-specific files (never overwrites)
    for file in HANDOFF.md; do
        if [ ! -f "$target/$file" ]; then
            create_or_sync "$TEMPLATE_DIR/$file" "$target/$file" "$file" "$dry_run"
        else
            echo "   Exists:  $file (skipped)"
        fi
    done

    # CLAUDE.md template
    if [ ! -f "$target/CLAUDE.md" ]; then
        if $dry_run; then
            echo "   Would create: CLAUDE.md"
        else
            cp "$TEMPLATE_DIR/CLAUDE.md" "$target/CLAUDE.md"
            echo "   Created: CLAUDE.md (template - fill in project details)"
        fi
    else
        echo "   Exists:  CLAUDE.md (skipped)"
    fi

    # Starter source templates (only if src/ exists)
    if [ -d "$target/src" ]; then
        for src_file in models.py config.py; do
            if [ ! -f "$target/src/$src_file" ]; then
                if ! find "$target/src" -name "$src_file" -print -quit 2>/dev/null | grep -q .; then
                    create_or_sync "$TEMPLATE_DIR/src/$src_file" \
                        "$target/src/$src_file" "src/$src_file (starter template)" "$dry_run"
                else
                    echo "   Exists:  $src_file found in src/ tree (skipped)"
                fi
            else
                echo "   Exists:  src/$src_file (skipped)"
            fi
        done
    else
        echo "   Note:    No src/ directory - skipping models.py and config.py templates"
        echo "            Create src/ and re-run to deploy, or copy from project-template/src/"
    fi
}

# --- Helper: discover all projects in home directory ---
discover_projects() {
    local found=()
    for dir in "$HOME"/*/; do
        [ -d "$dir" ] || continue
        # Must have .claude/ directory (sign of a managed project)
        [ -d "$dir/.claude" ] || continue
        # Skip the standards repo itself
        [ "$(cd "$dir" && pwd)" = "$SCRIPT_DIR" ] && continue
        found+=("$(cd "$dir" && pwd)")
    done
    printf '%s\n' "${found[@]}"
}

# --- Project-level deployment ---
echo "2. Project-level sync..."

if [ ${#TARGETS[@]} -gt 0 ]; then
    # Explicit target(s) provided
    for target in "${TARGETS[@]}"; do
        if [ ! -d "$target" ]; then
            echo "   ERROR: $target is not a directory"
            exit 1
        fi
        target="$(cd "$target" && pwd)"
        echo ""
        if $INIT_MODE; then
            echo "   --- Initialising: $target ---"
            init_project "$target" "$DRY_RUN"
            echo ""
            echo "   Project initialised. Review and fill in CLAUDE.md template."
        else
            echo "   --- Syncing: $target ---"
            sync_project "$target" "$DRY_RUN"
        fi
    done
elif $INIT_MODE; then
    echo "   ERROR: --init requires a target directory"
    echo "   Usage: ./setup.sh --init /path/to/new-project"
    exit 1
else
    # No target - auto-discover and sync all projects
    projects=$(discover_projects)
    if [ -z "$projects" ]; then
        echo "   No projects found in $HOME with .claude/ directories"
    else
        count=$(echo "$projects" | wc -l)
        echo "   Found $count projects to sync"
        while IFS= read -r project; do
            echo ""
            echo "   --- Syncing: $project ---"
            sync_project "$project" "$DRY_RUN"
        done <<< "$projects"
    fi
fi

echo ""
echo "=== Done ==="
