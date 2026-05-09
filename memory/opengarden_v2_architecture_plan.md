---
name: OpenGarden v2 architecture plan
description: ACTIVE restart of the OpenSCAD v2 model. Current step is a real standalone pot before shell/grid subtraction.
type: project
---
# OpenGarden v2 — restart plan

**Status as of 2026-05-09:** v2 was restarted from scratch on `refactor/v2-architecture`. The current step is intentionally smaller than shell/grid composition: build a real standalone pot first. Do not connect the pot to shell/grid subtraction until the pot itself is correct.

## Current Step: Real Pot First

Imagine there is no shell.

`Pot()` must be a real printable pot:

- positive geometry
- tapered outer body
- hollow interior
- configurable wall thickness
- configurable floor thickness
- bottom drain holes
- no shell dependency
- no tag/diff dependency

Current parameters:

- `Pot_Top_Size`
- `Pot_Height`
- `Pot_Wall`
- `Pot_Floor`
- `Pot_Taper`
- `Pot_Chamfer`
- `Pot_Hole_Rows`
- `Pot_Hole_Columns`
- `Pot_Hole_Diameter`
- `Pot_Hole_Padding`

## Later Idea: Shell/Grid/Subtract

After the standalone pot is correct, then return to:

- `TopShell()` as a BOSL2 `prismoid`
- grid layout on the shell top surface
- use row/column to place a pot-derived subtraction tool
- use BOSL2 `diff()`/`tag()` for shell subtraction

Do not mix this later step back into `Pot()` itself.

## Current Files

```text
cad/openscad/v2/
├── main.scad   // parameter wiring and first proof scene
├── pot.scad    // Pot(), real standalone pot
├── shell.scad  // parked for later shell/subtract work
└── grid.scad   // parked for later grid placement work
```

All older v2 files were removed.

## Current Contract

`Pot()`:

```scad
module Pot(top_size, h, wall, floor, taper, chamfer, hole_rows, hole_cols, hole_diameter, hole_padding)
```

## Locked Rules For This Phase

- Keep the model simple.
- Prove the pot first.
- `Pot()` is not a cut tool.
- `Pot()` must not know about shell thickness or grid cell placement.
- Do not add carrier, drain pan, OpenGrid back plate, lid generation, feature stacking, shell subtraction, or UI wiring yet.

## Verified

OpenSCAD Nightly export passed:

```powershell
& 'C:\Program Files\OpenSCAD (Nightly)\openscad.com' -q -o tmp_v2_real_pot.stl cad\openscad\v2\main.scad
```

PNG previews confirmed: one standalone tapered pot with hollow interior, visible wall thickness, a floor, and bottom drain holes.
