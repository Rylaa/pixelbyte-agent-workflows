#!/usr/bin/env node
/**
 * Skill Activation Prompt Hook
 *
 * Triggered on every UserPromptSubmit event.
 * Analyzes user prompt and suggests relevant skills based on skill-rules.json.
 * Also checks for pending code reviews from previous sessions.
 */

import { readFileSync, existsSync, unlinkSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';

interface HookInput {
    session_id: string;
    transcript_path: string;
    cwd: string;
    permission_mode: string;
    prompt: string;
}

interface CodingState {
    hasCodeChanges: boolean;
    lastFile: string;
    timestamp: string;
    tool: string;
}

interface PromptTriggers {
    keywords?: string[];
    intentPatterns?: string[];
}

interface SkillRule {
    type: 'guardrail' | 'domain';
    enforcement: 'block' | 'suggest' | 'warn';
    priority: 'critical' | 'high' | 'medium' | 'low';
    alwaysActive?: boolean;
    promptTriggers?: PromptTriggers;
    blockMessage?: string;
}

interface SkillRules {
    version: string;
    skills: Record<string, SkillRule>;
}

interface MatchedSkill {
    name: string;
    matchType: 'keyword' | 'intent';
    config: SkillRule;
}

function ensureDir(dir: string): void {
    if (!existsSync(dir)) {
        mkdirSync(dir, { recursive: true });
    }
}

async function main(): Promise<void> {
    try {
        // Read input from stdin
        const input = readFileSync(0, 'utf-8');
        const data: HookInput = JSON.parse(input);
        const prompt = data.prompt.toLowerCase();

        // Get directories from environment
        const pluginRoot = process.env.PLUGIN_ROOT || process.env.CLAUDE_PLUGIN_ROOT || dirname(__dirname);
        const stateDir = process.env.STATE_DIR || join(data.cwd, '.claude', 'hooks', 'state');

        ensureDir(stateDir);

        // Load skill rules from plugin config
        const rulesPath = join(pluginRoot, 'config', 'skill-rules.json');

        if (!existsSync(rulesPath)) {
            // No rules file, skip activation check
            process.exit(0);
        }

        const rules: SkillRules = JSON.parse(readFileSync(rulesPath, 'utf-8'));
        const matchedSkills: MatchedSkill[] = [];
        const alreadyAdded = new Set<string>();

        // FIRST: Add always-active skills (mandatory on every prompt)
        for (const [skillName, config] of Object.entries(rules.skills)) {
            if (config.alwaysActive) {
                matchedSkills.push({ name: skillName, matchType: 'keyword', config });
                alreadyAdded.add(skillName);
            }
        }

        // THEN: Check each skill for keyword/intent matches
        for (const [skillName, config] of Object.entries(rules.skills)) {
            if (alreadyAdded.has(skillName)) {
                continue;
            }

            const triggers = config.promptTriggers;
            if (!triggers) {
                continue;
            }

            // Keyword matching
            if (triggers.keywords) {
                const keywordMatch = triggers.keywords.some(kw =>
                    prompt.includes(kw.toLowerCase())
                );
                if (keywordMatch) {
                    matchedSkills.push({ name: skillName, matchType: 'keyword', config });
                    continue;
                }
            }

            // Intent pattern matching (regex)
            if (triggers.intentPatterns) {
                const intentMatch = triggers.intentPatterns.some(pattern => {
                    try {
                        const regex = new RegExp(pattern, 'i');
                        return regex.test(prompt);
                    } catch {
                        return false;
                    }
                });
                if (intentMatch) {
                    matchedSkills.push({ name: skillName, matchType: 'intent', config });
                }
            }
        }

        // Generate output if matches found
        if (matchedSkills.length > 0) {
            let output = '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
            output += '🎯 SKILL ACTIVATION CHECK\n';
            output += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n';

            // Group by priority
            const critical = matchedSkills.filter(s => s.config.priority === 'critical');
            const high = matchedSkills.filter(s => s.config.priority === 'high');
            const medium = matchedSkills.filter(s => s.config.priority === 'medium');
            const low = matchedSkills.filter(s => s.config.priority === 'low');

            if (critical.length > 0) {
                output += '⚠️ MANDATORY SKILLS (LOAD BEFORE RESPONDING):\n';
                critical.forEach(s => {
                    const alwaysTag = s.config.alwaysActive ? ' [ALWAYS]' : '';
                    output += `  → ${s.name}${alwaysTag}\n`;
                });
                output += '\n';
            }

            if (high.length > 0) {
                output += '📚 RECOMMENDED SKILLS:\n';
                high.forEach(s => output += `  → ${s.name}\n`);
                output += '\n';
            }

            if (medium.length > 0) {
                output += '💡 SUGGESTED SKILLS:\n';
                medium.forEach(s => output += `  → ${s.name}\n`);
                output += '\n';
            }

            if (low.length > 0) {
                output += '📌 OPTIONAL SKILLS:\n';
                low.forEach(s => output += `  → ${s.name}\n`);
                output += '\n';
            }

            output += 'ACTION: Use Skill tool BEFORE responding\n';
            output += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';

            console.log(output);
        }

        // Check for pending code review from previous session
        const stateFile = join(stateDir, 'coding-session.json');
        if (existsSync(stateFile)) {
            try {
                const stateContent = readFileSync(stateFile, 'utf-8');
                const state: CodingState = JSON.parse(stateContent);

                if (state.hasCodeChanges) {
                    // Clear state file after reading
                    unlinkSync(stateFile);

                    // Output review reminder
                    let reviewOutput = '\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
                    reviewOutput += '🔍 CODE REVIEW REMINDER\n';
                    reviewOutput += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n';
                    reviewOutput += `📁 Last modified: ${state.lastFile}\n`;
                    reviewOutput += `🔧 Tool used: ${state.tool}\n\n`;
                    reviewOutput += '💡 Ask user: "Would you like me to review the changes?"\n';
                    reviewOutput += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';

                    console.log(reviewOutput);
                }
            } catch {
                // Ignore errors reading state file
            }
        }

        process.exit(0);
    } catch (err) {
        // Log error but don't block Claude
        const pluginRoot = process.env.PLUGIN_ROOT || process.env.CLAUDE_PLUGIN_ROOT || dirname(__dirname);
        const logDir = join(pluginRoot, 'hooks', 'logs');
        ensureDir(logDir);
        const logFile = join(logDir, 'skill-activation-error.log');
        require('fs').appendFileSync(logFile, `[${new Date().toISOString()}] Error: ${err}\n`);
        process.exit(0);
    }
}

main();
