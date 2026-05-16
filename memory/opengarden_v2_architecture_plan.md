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
- Pot height and pot insert depth are separate controls:
  - `pot_h` / `Pot_Height` defines the physical printed pot height.
  - `insert_depth` / `Pot_Insert_Depth` defines where the rim/seat lands on Z and therefore how far the pot sits into the shell.
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
- `ShellPlateWithComponents()` shell minus grid-placed subtractive component cuts.
- Component registry under `cad/openscad/v2/components/`.
- Reusable sloped `RectRim()` and matching `RectSeatCut()` primitives for print-friendly pot/deck seating.

Still missing:

- Validation for out-of-range row/col and oversized cuts.
- Richer component families and non-rectangular pot shapes.
- Real water-container/reservoir body below the shell.

## Current Files

```text
cad/openscad/v2/
├── main.scad              // preview wiring and parameters
├── shell.scad             // shell plate and shell subtraction entrypoint
├── grid.scad              // grid helpers
└── components/
    ├── registry.scad      // component dispatcher for cuts and references
    ├── rim.scad           // reusable sloped rim and seat-cut primitives
    ├── pot.scad           // standalone pot geometry
    ├── box.scad           // hollow box component reference
    └── fill_tube.scad     // fill-tube cut/reference helpers
```

## Contracts (Current)

`Pot()`:

```scad
module Pot(top_size, h, wall, floor, taper, chamfer, rim_width, rim_height, rim_z, rim_chamfer, hole_rows, hole_cols, hole_diameter, hole_padding)
```

`RectRim()` and `RectSeatCut()`:

```scad
module RectRim(outer_size, base_size, inner_size, h, chamfer)
module RectSeatCut(outer_size, through_size, shell_thickness, seat_depth, fit_clearance, chamfer, cut_epsilon)
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
- Split physical pot height from insert depth.
- Add sloped rim/seat primitives so pot inserts can rest in the top shell without support-heavy overhangs.

Step C (done):
- Add `box` subtractive component (simple rectangular cut profile).
- Add component selector per cut (`pot | box`).

Step D (done):
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
& 'C:\Program Files\OpenSCAD (Nightly)\openscad.com' -q -o artifacts\v2-seat-cut-epsilon-test.stl cad\openscad\v2\main.scad
```

PNG previews confirmed:
- one standalone tapered pot with hollow interior, visible wall thickness, and bottom drain holes
- one shell plate with pot-profile subtraction and clearance
## 2026-05-09 (quick update)

- Fixed v2 preview reference behavior for `box` in [`cad/openscad/v2/main.scad`](D:/Projects/OpenGarden/cad/openscad/v2/main.scad): it now renders via `BoxContainer(...)` (hollow cavity) instead of a solid `prismoid`.
- Added `Show_FillTube_Reference = false` toggle in `main.scad`; fill tube remains subtract-only by default in reference preview.
- Refactored v2 component structure into `cad/openscad/v2/components/` with one file per component:
  - `pot.scad`
  - `box.scad`
  - `fill_tube.scad`
  - plus shared `props.scad` and dispatcher `registry.scad`.
- Removed legacy `cad/openscad/v2/pot.scad` so component ownership is now fully under `components/`.

## 2026-05-16 (rim/seat update)

- Added a reusable rim/seat primitive in `cad/openscad/v2/components/rim.scad`.
- `RectRim()` is sloped from body size to rim size so the pot can print upright with little/no support.
- `RectSeatCut()` creates the matching shell recess and through-hole, with `cut_epsilon` to avoid coplanar preview/export artifacts.
- Pot references now use `pot_h` for physical pot height and `insert_depth` for rim Z position.
- Default rim proportions use `Pot_Rim_Width = 3` and `Pot_Rim_Height = 3` to stay near a 45-degree printable shoulder.
