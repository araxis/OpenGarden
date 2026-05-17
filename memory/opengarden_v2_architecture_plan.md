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
- Add multiple cut entries (list of operations).
- Components may use `row_span` / `col_span` to occupy a merged grid footprint.
- Components may use local subgrid props (`sub_row_sizes`, `sub_col_sizes`, `sub_row`, `sub_col`, `sub_row_span`, `sub_col_span`, `sub_padding`) to split their resolved footprint without mutating root grid topology.
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

## 2026-05-16 (pot-type architecture lock)

- Locked new component direction: separate pot-type components instead of one generic pot shape flag.
- Pot family now moves toward:
  - `pot_rect`
  - `pot_circle`
  - `pot_oval`
- Rim/seat ownership is moved into each pot-type component contract.
- Shell no longer needs separate top-level seat controls for pot features; seat cut is derived from pot component parameters.
- Registry remains host/orchestrator only (placement + dispatch), while pot-type modules own interface geometry details.

## 2026-05-16 (oval + epsilon follow-up)

- Added real `pot_oval` geometry module (no longer a rectangular wrapper), including:
  - tapered oval body/cavity
  - oval rim ring
  - oval drain hole placement bounded by ellipse
  - oval shell cut path
- Added `geom_epsilon` support as a per-component override in registry and passed it through circular/oval references.
- Wrapped circular and oval reference previews with `render(convexity=12)` to reduce OpenCSG preview artifacts that were not present in STL manifold exports.

## 2026-05-16 (simple drain-hole policy)

- Drain-hole mechanism simplified for day-to-day pot behavior.
- Removed dependence on user-tuned row/column hole grids for pot variants.
- New default patterns:
  - `pot_rect`: two edge rows + center drain.
  - `pot_circle`: center drain + circular ring.
  - `pot_oval`: center drain + elliptical ring.
- Goal: predictable "standard pot-like" output with minimal configuration.

## 2026-05-16 (reservoir container baseline)

- Added `cad/openscad/v2/components/container.scad` with a prismoid-based reservoir body.
- Container is hollowed by inner prismoid subtraction, exposing simple controls:
  - `top_size`, `bottom_size`, `h`
  - `wall`, `floor`
  - `chamfer`, `rounding`
- Wired baseline preview in `v2/main.scad`:
  - shell preview remains at top
  - container preview can be shown below shell (`Container_Show`, `Container_Preview_Gap`).

## 2026-05-16 (container seat support direction locked)

- Replaced the earlier floating-post style seat supports with wall-attached curved corbels in `cad/openscad/v2/components/container.scad`.
- New support behavior:
  - corner corbels are generated from curved quarter-profile braces (squinch-like)
  - optional mid-edge corbels remain controlled by `gusset_edge_supports`
  - thin top seat rails bridge between corners for continuity
- Kept existing public parameter names for now (`Gusset_*`) to avoid breaking current test presets while geometry behavior changed to the new printable direction.

## 2026-05-16 (seat profile clarification)

- User confirmed a **quarter-cove style profile** as reference for seat support shaping (sample file: `C:/Users/meisa/AppData/Local/Temp/quarter_cove.scad`).
- The sample is reference-only (not copied verbatim): we should adapt its concave quarter-arc profile logic for container corner supports.
- Implementation intent:
  - keep supports wall-attached and printable without internal support
  - use the quarter-cove curve language for smoother, cleaner load path
  - avoid adding extra mechanisms unless explicitly requested

## 2026-05-16 (container load pads)

- Added the next support rule for v2: **shell locates pots, container carries pot weight**.
- `ReservoirContainer()` now accepts the component list and grid settings so it can generate internal support pads beneath inserted pot components.
- Support pad behavior:
  - generated only for pot components (`pot_rect`, `pot_circle`, `pot_oval`)
  - XY placement and shape are derived from the same grid/component footprint used by the shell
  - top height is driven by `container_h - insert_depth - support_clearance`
  - pads start from the container floor and stop just below the inserted pot bottom
- Pads are now same-shape frames/rings by default instead of solid blocks, preserving water volume while still transferring load.
- This keeps pot weight moving into the reservoir floor instead of relying on the thin shell plate.

## 2026-05-16 (shared slatted support deck experiment)

- Added an alternate support strategy: a shared internal slatted deck inside `ReservoirContainer()`.
- The deck is intentionally implemented as vertical ribs rising from the reservoir floor, not as a floating horizontal plate. This keeps it printable in the same orientation as the container.
- Deck top height follows the fixed insert-depth contract:
  - `deck_top_z = container_h - insert_depth - support_clearance`
- For the current experiment, `main.scad` enables the shared deck and disables per-pot ring supports so the deck can be inspected clearly.
- Intent: test whether one common support plane is cleaner than per-pot support rings when all pots share one `Pot_Insert_Depth`.

## 2026-05-16 (grid-cell support deck replaces shape pads)

- Shape-aware pot support rings/pads are now superseded by the slatted deck approach.
- `ReservoirContainer()` support logic no longer depends on pot geometry shape.
- Each component gets a rectangular slat support zone from its grid cell footprint.
- Insert depth is fixed globally for now:
  - `zone_top_z = container_h - default_insert_depth - support_clearance`
- This keeps the support deck at one predictable height so one pot cannot accidentally sit lower and drown while neighboring pots stay dry.
- Pot total height may vary later, but v2 baseline assumes a fixed insertion depth for all pot components.
- Added triangular feet at the bottom of each slat to avoid fragile 90-degree rib-to-floor joints in FDM prints.
- Added a small deck embed value so support slats overlap into the floor/adjacent material instead of merely touching surfaces.
- Refined the slat foot so its ramp also embeds below the floor plane, making the bottom transition intentionally fused rather than relying on chamfer alone.
- Replaced the over-shaped arch support with a simpler fused rail: a normal vertical support rib plus a wider low base shoe.
- `support_deck_embed` controls how far the rail assembly overlaps into the reservoir floor; `support_deck_foot` controls the visible extra shoe width. This keeps the floor joint strong and predictable without relying on hidden curved geometry.
- Support rail material reduction is now done by subtracting a single horizontal cylindrical bite from the rib body while leaving the fused floor shoe intact.
- The cylindrical bite is positioned low, below the rib body, so it carves an underside arch only and leaves a continuous top beam.
