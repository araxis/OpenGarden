---
name: OpenGarden collaboration workflow
description: How Claude and the user collaborate on this repo — what runs where, hand-off protocol.
type: reference
---
# OpenGarden workflow

## Tool capabilities (current)

When operating directly on `D:\Projects\OpenGarden` (the actual repo, not a worktree mount):
- **Bash tool** — can run `git` commands (status, log, diff, fetch, checkout, pull, push, branch, commit, merge) and `gh` commands (PR view/edit/merge). Confirmed working as of 2026-05-09.
- **PowerShell tool** — for Windows-specific commands (file moves, OpenSCAD invocation)
- **Read/Edit/Write/Glob/Grep** — file operations, all working
- **OpenSCAD** — Claude **cannot** run OpenSCAD directly (it's a Windows GUI binary). User runs `openscad.com` from PowerShell for STL exports / verification renders.

## Historical note (no longer applies)

Earlier sessions ran inside a `.claude/worktrees/` git worktree where bash had broken access to `.git/`. That worktree was deleted on 2026-05-09. We now work on the origin repo directly — no sandbox limitations on git.

## Hand-off protocol for OpenSCAD renders

When Claude needs the user to verify a CAD change:
1. Claude provides the exact PowerShell command (see `reference_openscad_env.md`)
2. User runs it, opens the STL in OpenSCAD GUI to inspect
3. User pastes screenshot or describes the result
4. Claude proceeds with next edits

## Branching / commit conventions

- `master` is the main branch — never push directly
- Feature branches `feat/*`, fixes `fix/*`, refactors `refactor/*`, chores `chore/*`
- PRs go through GitHub (`gh pr create`, `gh pr merge`)
- Repo uses **merge commits** (not squash) — observed pattern in recent merges
- Commit messages follow conventional-commit prefixes (`fix(scad):`, `ui:`, `chore(cad):`, etc.)
- `git config core.autocrlf=input` was set locally on 2026-05-02 to silence CRLF phantom diff on Windows checkouts

## CI

GitHub Actions runs `Render OpenSCAD STL previews` on PRs touching `.scad` files. The check is currently **informational, not required** — PRs can be merged before it completes (and have been).
