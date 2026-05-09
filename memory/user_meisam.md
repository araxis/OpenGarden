---
name: User — Meisam
description: Developer working on OpenGarden (modular self-watering planter, OpenSCAD + Blazor designer + future ESP32). Windows. Hands-on, plan-first, architectural thinker.
type: user
---
Meisam is the developer building OpenGarden — a modular, OpenGrid-mounted, 3D-printed self-watering planter system at `D:\Projects\OpenGarden`.

**Environment**
- Windows 11
- OpenSCAD Nightly at `C:\Program Files\OpenSCAD (Nightly)`
- BOSL2 library installed globally
- Email: alifallahimeisam@gmail.com
- GitHub user: araxis

**Working style**
- **Plan-first** — wants to review architecture before code is written
- **Architectural thinker** — pushes back on incremental fixes when they signal a deeper structural problem ("we are spending a lot of effort to add a really simple feature, it is not good sign")
- **One step at a time when designing** — prefers focused exchanges, not big design dumps
- Keeps work on short-lived feature branches with PRs (per repo CONTRIBUTING.md)
- Comfortable with OpenSCAD, BOSL2 anchors, parametric design, .NET / Blazor
- Engaged with structural/architectural choices — asks for opinions on current design before extending; happy to redirect when an approach is wrong

**Project context (as of 2026-05-09)**
- Phase 1 (mechanical CAD + Blazor designer) complete
- v1 cell-features layered approach merged in PR #35 — but flagged as architecturally too rigid
- Active focus: v2 greenfield rewrite into clean grid/component/carrier layers — see [opengarden_v2_architecture_plan.md](opengarden_v2_architecture_plan.md)
- Plans to move into ESP32 firmware + .NET backend in later phases

**Preferences observed in conversation**
- Uses `fwd` instead of `front` in coordinate naming
- App is not running publicly — happy with breaking changes during pre-1.0 rewrite
- Wants memory folder in project root (`D:\Projects\OpenGarden\memory\`), not in user-level `.claude/`
