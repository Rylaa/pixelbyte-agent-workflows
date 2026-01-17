#!/bin/bash
set -e

# Get plugin root directory
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
HOOKS_DIR="$PLUGIN_ROOT/hooks"

# State files go to project directory (not plugin)
STATE_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/state"
mkdir -p "$STATE_DIR"

# Logs go to plugin directory
LOG_DIR="$HOOKS_DIR/logs"
mkdir -p "$LOG_DIR"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Skill usage tracker triggered" >> "$LOG_DIR/skill-usage.log"

cd "$HOOKS_DIR"
cat | PLUGIN_ROOT="$PLUGIN_ROOT" STATE_DIR="$STATE_DIR" npx tsx skill-usage-tracker.ts
