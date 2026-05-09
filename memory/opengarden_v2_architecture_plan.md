---
name: OpenGarden v2 architecture plan
description: ACTIVE v2 architecture where shell is the base and grid-placed components are subtractive tools.
type: project
---
# OpenGarden v2 — shell-first subtractive architecture

**Status as of 2026-05-09:** The architecture direction is now explicit: shell is the base part, and components are subtractive tools positioned by grid cells. Pot remains a real standalone part for validation and print tests, but shell generation is driven by subtraction mapping.

## Core Idea

1. Build a thin shell plate (lid-like body).
2. Define a 2D grid on shell surface.
3. For each addressed cell (row, col), place a selected subtractive component.
4. Apply subtraction to shell and produce a printable lid/shell part.
5. Keep components reusable and independent from shell ownership logic.

Typical usage:

- "Put pot cut in row 1, col 2"
- "Put box cut in row 2, col 1"
- "Use clearance X for pot cut"
- Result: one shell with multiple positioned subtractions

Sizing rule (locked):
- Grid cell defines component footprint (`x/y`) for shell subtraction.
- Pot width/depth are not primary controls in grid-subtraction flow.
- Pot-related control in this flow is mainly `Cavity_Height` (z) plus fit/clearance.
- Track spec syntax supports mixed tokens per axis:
  - `N` = fixed size (mm), example `50`
  - `N%` = percent of usable span, example `25%`
  - `N*` or `*` = weighted star share, example `2*`, `*`

## Why This Architecture

- The shell is the real parent part.
- Grid gives predictable placement and scaling.
- Components stay modular and testable.
- Same system can target water-container lids and future variants.

## Current Implemented Building Blocks

Implemented now:

- Real standalone `Pot()`.
- `ShellPlate()` thin shell body.
- `ShellPlateWithPotCut()` shell minus one pot-profile cut with clearance.

Still missing:

- Grid-to-cut mapping (`row,col -> component`).
- Multiple cuts in one shell build pass.
- Component registry for `pot`, `box`, and upcoming tools.

## Current Files

```text
cad/openscad/v2/
├── main.scad   // preview wiring and parameters
├── pot.scad    // standalone pot geometry
├── shell.scad  // shell plate and shell subtraction entrypoint
└── grid.scad   // grid helpers (next integration target)
```

## Contracts (Current)

`Pot()`:

```scad
module Pot(top_size, h, wall, floor, taper, chamfer, hole_rows, hole_cols, hole_diameter, hole_padding)
```

`ShellPlate()` and `ShellPlateWithPotCut()`:

```scad
module ShellPlate(top_size, bottom_size, thickness, chamfer, rounding)
module ShellPlateWithPotCut(top_size, bottom_size, thickness, chamfer, rounding, pot_top_size, pot_taper, fit_clearance, cut_offset)
```

## Development Plan (Small Steps)

Step A (done):
- Standalone pot and shell-with-single-pot-cut validated.

Step B (done):
- Integrate grid sizing and center-position helpers for shell surface.
- Add one cell selector (`Cut_Row`, `Cut_Col`) and place one pot cut by grid address.
- Remove manual XY offset addressing for this path.
- Use grid for cut placement and footprint (`x/y`) in this flow.
- Use `Cavity_Height` for vertical pot-cut behavior.

Step C:
- Add `box` subtractive component (simple rectangular cut profile).
- Add component selector per cut (`pot | box`).

Step D:
- Add multiple cut entries (list of operations), still no spans yet.
- Stable deterministic order: operations apply in listed order.

Step E:
- Add per-operation parameters (`clearance`, `padding`, local offsets).
- Add validation for out-of-range row/col and oversized cuts.

Step F:
- Expand into richer components (drain layouts, fill-tube tools, etc.) after grid subtraction is stable.

## Locked Rules For This Phase

- Keep the model simple.
- Shell owns subtraction orchestration.
- Components provide geometry templates.
- `Pot()` remains independent geometry.
- Grid controls placement.
- Use small validated increments only; no large leap refactors.
- Do not add carrier, drain pan, OpenGrid back plate, feature stacking, or UI wiring yet.

## Verified

OpenSCAD Nightly export passed:

```powershell
& 'C:\Program Files\OpenSCAD (Nightly)\openscad.com' -q -o tmp_v2_real_pot.stl cad\openscad\v2\main.scad
```

PNG previews confirmed:
- one standalone tapered pot with hollow interior, visible wall thickness, and bottom drain holes
- one shell plate with pot-profile subtraction and clearance
## 2026-05-09 (quick update)

- Fixed v2 preview reference behavior for `box` in [`cad/openscad/v2/main.scad`](D:/Projects/OpenGarden/cad/openscad/v2/main.scad): it now renders via `BoxContainer(...)` (hollow cavity) instead of a solid `prismoid`.
- Added `Show_FillTube_Reference = false` toggle in `main.scad`; fill tube remains subtract-only by default in reference preview.
