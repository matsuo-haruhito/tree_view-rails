# AGENTS.md

## Purpose
- This repository's active intent, constraints, and refactor direction are maintained in `context.md`.
- Before implementing changes, read `context.md` first and follow it as the primary project context.

## Working Rule
- If user intent or scope seems unclear, confirm against `context.md` and ask concise clarification questions.
- When updating implementation strategy, update `context.md` so the latest direction stays explicit.
- In `context.md`, keep durable design decisions and project goals as normal bullet points.
- Manage short-lived, transactional work items as Markdown checklists (`- [ ]` / `- [x]`).
- Remove or rewrite closed checklist items when they no longer help future work, instead of accumulating a long chronological log.

## Note for Future Agents
- Do not assume old conversational context is sufficient.
- Treat `context.md` as the canonical source for current goals and boundaries.

## Codex Common Operation
- Inherit the common skill definitions described in the root [AGENTS.md](/mnt/c/work/AGENTS.md), even when Codex is launched directly in this repository.
- Record user prompts for this repository in the root [codex_prompt_log.md](/mnt/c/work/codex_prompt_log.md), not in a local prompt log.
- Collect repeated request patterns and skillization candidates in the root [skill_backlog.md](/mnt/c/work/skill_backlog.md), not in a repo-local backlog.
- Keep repository-specific context in the local `context.md`, but treat workspace-wide Codex operation rules as inherited from the root.
