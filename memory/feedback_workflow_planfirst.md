---
name: Workflow preference — plan-first then implement
description: For non-trivial OpenGarden work, write a plan and wait for review before touching code or CAD
type: feedback
---
For any non-trivial change in OpenGarden, write a written plan and wait for explicit approval before implementing.

**Why:** Confirmed across multiple sessions, including the v1 cell-features work and the v2 architectural discussion. User wants to review architecture decisions and DSL/contract shapes before code is written, because reversing a partial CAD/code change is costlier than discussing the plan.

**How to apply:**
- Open-ended prompts like "develop and extend" → ask scope first, then write a plan, then wait
- During architectural design, work **one decision at a time** — user explicitly said "lets go one by one" when given a multi-question dump. Surface 1–2 focused questions per round, lock the answer, move on.
- Plan format: prose with light structure (sections for goals, locked decisions, open questions, files affected)
- Always include an explicit OPEN QUESTIONS section — user reviews and answers before code starts
- Once plan is approved, implementation goes on a feature branch (per `CONTRIBUTING.md`), not on `master`
- Keep the active project memory file (e.g. `opengarden_v2_architecture_plan.md`) updated as decisions lock, so future sessions can resume
- After each architectural exchange, update memory with the locked decisions before moving to the next question
