#!/usr/bin/env node
/**
 * Skill Usage Tracker Hook
 *
 * Triggered after Skill tool is used (PostToolUse).
 * Tracks which skills have been used in the current session.
 * Used to determine if frontend-dev-guidelines was loaded.
 */

import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';

interface HookInput {
    session_id: string;
    tool_name: string;
    tool_input: {
        skill?: string;
    };
    tool_output?: string;
}

interface SessionState {
    session_id: string;
    skills_used: string[];
    frontend_guidelines_used: boolean;
    last_updated: string;
}

// Frontend dev guidelines skill name variants
const FRONTEND_SKILL_NAMES = [
    'frontend-dev-guidelines',
    'pb-frontend:frontend-dev-guidelines',
];

function ensureDir(dir: string): void {
    if (!existsSync(dir)) {
        mkdirSync(dir, { recursive: true });
    }
}

function readSessionState(statePath: string, currentSessionId: string): SessionState {
    const defaultState: SessionState = {
        session_id: currentSessionId,
        skills_used: [],
        frontend_guidelines_used: false,
        last_updated: new Date().toISOString(),
    };

    if (!existsSync(statePath)) {
        return defaultState;
    }

    try {
        const content = readFileSync(statePath, 'utf-8');
        const state: SessionState = JSON.parse(content);

        // Reset state if session ID changed
        if (state.session_id !== currentSessionId) {
            return defaultState;
        }

        return state;
    } catch {
        return defaultState;
    }
}

function writeSessionState(statePath: string, state: SessionState): void {
    const dir = dirname(statePath);
    ensureDir(dir);
    writeFileSync(statePath, JSON.stringify(state, null, 2));
}

async function main(): Promise<void> {
    try {
        // Read input from stdin
        let input = '';
        for await (const chunk of process.stdin) {
            input += chunk;
        }

        if (!input.trim()) {
            process.exit(0);
        }

        const data: HookInput = JSON.parse(input);

        // Only process Skill tool calls
        if (data.tool_name !== 'Skill') {
            process.exit(0);
        }

        // Get skill name
        const skillName = data.tool_input.skill;
        if (!skillName) {
            process.exit(0);
        }

        // Get state directory from environment
        const stateDir = process.env.STATE_DIR || join(process.cwd(), '.claude', 'hooks', 'state');
        ensureDir(stateDir);

        const statePath = join(stateDir, 'skill-session-state.json');
        const state = readSessionState(statePath, data.session_id);

        // Add skill to list if not already present
        if (!state.skills_used.includes(skillName)) {
            state.skills_used.push(skillName);
        }

        // Check if frontend-dev-guidelines was used
        const isFrontendSkill = FRONTEND_SKILL_NAMES.some(name =>
            skillName.toLowerCase().includes(name.toLowerCase()) ||
            name.toLowerCase().includes(skillName.toLowerCase())
        );

        if (isFrontendSkill) {
            state.frontend_guidelines_used = true;
        }

        // Update timestamp and save state
        state.last_updated = new Date().toISOString();
        writeSessionState(statePath, state);

        // Log for debugging
        const pluginRoot = process.env.PLUGIN_ROOT || process.env.CLAUDE_PLUGIN_ROOT || dirname(__dirname);
        const logDir = join(pluginRoot, 'hooks', 'logs');
        ensureDir(logDir);
        const logPath = join(logDir, 'skill-usage.log');
        const logEntry = `[${new Date().toISOString()}] Skill used: ${skillName}, Frontend: ${isFrontendSkill}\n`;
        require('fs').appendFileSync(logPath, logEntry);

        process.exit(0);
    } catch (err) {
        // Silent fail - don't interrupt Claude
        process.exit(0);
    }
}

main();
