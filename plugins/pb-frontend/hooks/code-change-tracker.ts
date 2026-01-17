#!/usr/bin/env node
/**
 * Code Change Tracker Hook
 *
 * Triggered after Write, Edit, or MultiEdit tools are used (PostToolUse).
 * Tracks when code files are modified to trigger code review reminder.
 * State is read by skill-activation-prompt hook on next user prompt.
 */

import { readFileSync, writeFileSync, appendFileSync, existsSync, mkdirSync } from 'fs';
import { join, dirname, extname } from 'path';

interface ToolUseInput {
    tool_name: string;
    tool_input: {
        file_path?: string;
        content?: string;
    };
    tool_response?: {
        success?: boolean;
        filePath?: string;
    };
}

interface CodingState {
    hasCodeChanges: boolean;
    lastFile: string;
    timestamp: string;
    tool: string;
}

// Code file extensions to track
const CODE_EXTENSIONS = ['.ts', '.tsx', '.js', '.jsx', '.css', '.scss', '.json', '.vue', '.svelte'];

// Files/patterns to ignore
const IGNORE_PATTERNS = [
    'package-lock.json',
    'yarn.lock',
    'pnpm-lock.yaml',
    'node_modules',
    '.claude/',
    '.next/',
    'dist/',
    'build/',
    '.git/',
];

function ensureDir(dir: string): void {
    if (!existsSync(dir)) {
        mkdirSync(dir, { recursive: true });
    }
}

function shouldTrackFile(filePath: string): boolean {
    // Check extension
    const ext = extname(filePath).toLowerCase();
    if (!CODE_EXTENSIONS.includes(ext)) {
        return false;
    }

    // Check ignore patterns
    for (const pattern of IGNORE_PATTERNS) {
        if (filePath.includes(pattern)) {
            return false;
        }
    }

    return true;
}

async function main(): Promise<void> {
    try {
        // Read stdin for hook input
        let input = '';
        for await (const chunk of process.stdin) {
            input += chunk;
        }

        if (!input.trim()) {
            process.exit(0);
        }

        const data: ToolUseInput = JSON.parse(input);
        const filePath = data.tool_input?.file_path || data.tool_response?.filePath;

        if (!filePath || !shouldTrackFile(filePath)) {
            process.exit(0);
        }

        // Get state directory from environment
        const stateDir = process.env.STATE_DIR || join(process.cwd(), '.claude', 'hooks', 'state');
        ensureDir(stateDir);

        // Write state file
        const stateFile = join(stateDir, 'coding-session.json');
        const state: CodingState = {
            hasCodeChanges: true,
            lastFile: filePath,
            timestamp: new Date().toISOString(),
            tool: data.tool_name,
        };

        writeFileSync(stateFile, JSON.stringify(state, null, 2));

        // Log for debugging
        const pluginRoot = process.env.PLUGIN_ROOT || process.env.CLAUDE_PLUGIN_ROOT || dirname(__dirname);
        const logDir = join(pluginRoot, 'hooks', 'logs');
        ensureDir(logDir);
        const logFile = join(logDir, 'code-tracker.log');
        appendFileSync(logFile, `[${new Date().toISOString()}] Tracked: ${filePath} (${data.tool_name})\n`);

    } catch (err) {
        // Silent fail - don't interrupt Claude
        const pluginRoot = process.env.PLUGIN_ROOT || process.env.CLAUDE_PLUGIN_ROOT || dirname(__dirname);
        const logDir = join(pluginRoot, 'hooks', 'logs');
        ensureDir(logDir);
        appendFileSync(join(logDir, 'code-tracker-error.log'), `[${new Date().toISOString()}] Error: ${err}\n`);
    }

    process.exit(0);
}

main();
