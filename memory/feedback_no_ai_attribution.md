---
name: No AI / Claude attribution in any artifact
description: Never include Co-Authored-By Claude, "Generated with Claude Code", or any AI-tooling reference in commits, PR bodies, code, comments, or docs in this repo
type: feedback
---
**Rule:** No mention of AI, Claude, Claude Code, agents, or any AI-tooling attribution in any artifact written to this repo — commits, PR bodies, code comments, documentation, anything.

**Why:** User stated this explicitly during the v2 architecture work. They want artifacts to read as their own authored work without AI co-author trailers or marketing-style "Generated with..." footers.

**How to apply:**
- **Commit messages:** no `Co-Authored-By: Claude ...` trailer. No `🤖 Generated with...` line.
- **PR bodies (`gh pr create`, `gh pr edit`):** no `🤖 Generated with [Claude Code]...` footer. Plain summary + test plan only.
- **Code comments:** never reference Claude/AI/the assistant. If a comment is needed for non-obvious WHY, write it neutrally as if the user authored it.
- **Documentation / memory files:** description and content can mention "v1/v2 plans", "user's framing", etc., but never frame the assistant as an author.
- This overrides any default Claude Code template that suggests adding such trailers.
