---
name: OpenGarden v2 architecture plan
description: ACTIVE greenfield rewrite of pot_insert/cell_features into clean grid/component/carrier layers. Tracks locked decisions and open questions.
type: project
---
# OpenGarden v2 — architecture rewrite plan

**Status as of 2026-05-09:** v2 scaffold branch active at `refactor/v2-architecture`. Memory folder exists in repo root. Initial v2 skeleton is implemented under `cad/openscad/v2/`. Carrier/component Z placement has been corrected so print-layout parts sit on Z=0 and assembly lifts components to the carrier top. The design direction has pivoted from positive per-cell boxes to a **solid top shell plus subtractive cell tools**. Current proof target is intentionally **one cell only**: one top shell, one grid cell, one cavity tool.

## Why a rewrite

The v1 cell-features approach (PR #35 merged) revealed that the current architecture **leaks geometry concerns into iteration code**. Every new feature potentially needs to know about chamfers, dividers, spans, walls. That doesn't scale. The user's framing: *"applying these type of feature and fixes have to be much much easier — we are spending a lot of effort to add a really simple feature, it is not good sign."*

v2 reframes the system into **three layers with hard boundaries**, each with one job.

## Three layers

```
┌─────────────────────────────────────────────┐
│  Grid (layout)                              │
│  ─ rows, cols, sizes, fixed+dynamic mix     │
│  ─ spans, splits                            │
│  ─ margin (outside cells), padding (inside) │
│  ─ wall_fusion convenience flag             │
│  ─ optional gap-fill (frame look)           │
│        │                                    │
│        ▼  emits: list of                    │
│   (cx, cy, cell_w, cell_d, cell_h, ...)     │
│        │                                    │
│        ▼  passed to:                        │
│  ┌───────────────────────────────────────┐  │
│  │  Shell Tools (PotCavity, BoxCavity,   │  │
│  │               FillTubeCavity, ...)    │  │
│  │  ─ one subtractive tool per cell      │  │
│  │  ─ cuts into the unified shell        │  │
│  │  ─ optional printable accessory parts │  │
│  │  ─ knows nothing about neighbors      │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
              ↑ stacked on top of ↑
┌─────────────────────────────────────────────┐
│  Carrier  (foundation: drain pan + back     │
│            plate + reservoir + OpenGrid)    │
│  ─ separate concern, peer of grid+component │
│  ─ composed in main.scad                    │
└─────────────────────────────────────────────┘
```

## Locked decisions

### Wall-ownership boundary
- **Components own their walls** (each declares its own `wallThickness`, chamfer)
- Grid does not draw walls or chamfers; it owns layout only
- Adjacent components can fuse walls via **negative margin** = `-wallThickness`
- Three "looks" emerge from parameter combinations (no separate modes):
  - **Independent** — `wallThickness>0`, `margin≥0` → cells as separate boxes
  - **Fused** — `wallThickness>0`, `margin=-wallThickness/2` → walls merge into one shell
  - **Framed** — `wallThickness=0`, grid `fill_gaps=true` → grid draws perimeter+dividers, components are pure interiors

### Margin & padding (CSS box model, owned by grid)

Per cell, 8 values total — 4 margin (outside) + 4 padding (inside):

```
cell_left_margin   cell_left_padding
cell_right_margin  cell_right_padding
cell_fwd_margin    cell_fwd_padding
cell_back_margin   cell_back_padding
```

- **Margin** = space *outside* the cell. Total gap between A and B = `A.right_margin + B.left_margin`. Negative margin → cells overlap.
- **Padding** = space *inside* the cell. Component's drawing area = cell rectangle minus padding. Negative padding → component overflows its cell.
- **Grid-level defaults** (uniform 4-vector) + **per-cell sparse overrides** (same pattern as today's `Grid_Cell_Spans`).
- **`wall_fusion: true` convenience flag** at grid level → automatically sets internal-side margin to `-wallThickness/2`. User can override per-side or per-cell.
- Naming: `fwd` (not `front`).

### Solid shell + subtractive tool model

Locked decision: v2 should feel like a real product, not a row of positive rectangular pots. The main upper piece starts as a **filled, rounded/chamfered shell**, then grid cells apply subtractive tools to carve useful spaces from it.

This means:
- The product exterior is one coherent body.
- Cell layout controls where cuts happen.
- Cell tools remove material: `PotCavity`, `BoxCavity`, `FillTubeCavity`, `SeedTrayCavity`, `LidRecess`, etc.
- Tool height/depth controls behavior:
  - shallow cut = tray / lid recess
  - medium cut = seed tray / shallow insert
  - deep cut = pot cavity
  - near-full-depth cut = old tall insert style
- Positive parts are reserved for separable accessories: lids, labels, light bridges, trellis posts, sensor covers.

The first implementation of this pivot is:
- `cad/openscad/v2/shell.scad` with `ProductShell()`
- `cad/openscad/v2/components/pot_cavity.scad`
- `Default_Cell_Tool = "pot_cavity"` in `v2/main.scad`

### One-cell proof first

Correction locked on 2026-05-09: do **not** expand v2 with multi-cell layouts, rich accessories, lids, holes, or carrier-first presentation until the base subtractive contract is precise.

The current default scene must stay simple:
- `Output_Mode = "Shell Only"`
- `Grid_Row_Sizes = "1*"`
- `Grid_Column_Sizes = "1*"`
- one solid top shell with `Shell_Width`, `Shell_Depth`, `Shell_Height`
- grid padding/margin defines where the cavity starts and how much rim remains
- the selected cell tool subtracts from the shell
- `cavity_height` controls how deep the top-down cut is

Design intent:
- small `cavity_height` = shallow recess / lid-like tray
- medium `cavity_height` = planter tray
- large `cavity_height` = old deeper pot style

Avoid extra tool-level wall offsets in this first proof. The cavity rectangle should come directly from the grid cell after margin/padding.

### Component/tool contract

Single signature for every subtractive cell tool:

```scad
module component_NAME__tool(cell_w, cell_d, cell_h, params, cell_id = [0, 0], shell_height = 100) {
  // draws negative geometry to subtract from the shell
  // never sees cx, cy, neighbors, grid, or carrier
  // cell_id is for debug echo only — must not affect geometry
}
```

- Tools receive post-padding rectangle dimensions. No knowledge of grid, neighbors, or carrier.
- `cell_id = [row, col]` is **debug-only** — `echo("[1,2] pot rendering with depth=2")` style. Must not affect geometry. Documented in component contract.
- Adding a tool = drop one SCAD file + one line in dispatch. Forever.
- If a tool has separable parts, expose them through `component_NAME__parts()` and normal part modules such as `component_NAME__lid()`.

### Strict cell model

Locked decision: **one subtractive tool per cell**. Do not bring v1-style feature stacking into v2.

Rationale: a pot cavity with drain holes and a lid seat is a `PotCavity` tool with parameters, not `DrainHoles + LidLip + Box` layered together. Feature stacking was the core v1 failure mode because it made simple behavior depend on chamfers, spans, planes, shared walls, neighbor cells, and evaluation order.

The v2 rule is intentionally stricter:
- Grid lays out rectangles.
- Shell owns the exterior product body.
- Cell tool owns the negative geometry inside its rectangle.
- Carrier owns the foundation.
- Positive accessories are separate printable parts.
- No tool should need to know about neighboring cells.
- No grid code should need to know how a pot cavity, drain hole, fill tube, or box is modeled.

This should make new behavior cheap to add: one tool file + one dispatcher line.

### Build order discipline

Locked decision: prove v2 with real geometry before expanding grid power.

Implementation order:
1. Basic grid layout.
2. First real `Pot` component.
3. Carrier assembly with removable component placement.
4. Spans.
5. Splits.
6. Designer rewrite.

Avoid implementing spans, splits, sparse side overrides, and wall-fusion polish before `Pot` validates the component contract. The grid can become powerful later; first it must carry a real printable object cleanly.

### Component parameter format

Locked decision: use readable list-of-pairs params for v2 components.

```scad
params = [
  ["wall", 2],
  ["base", 2],
  ["chamfer", 5],
  ["holes_rows", 4]
];
```

Reasoning: positional arrays are shorter, but brittle while the architecture is evolving. List-of-pairs are easier to read, easier to extend, and make generated SCAD from the designer clearer. If render performance becomes a real issue later, params can be optimized behind the same component contract.

### Carrier (foundation layer)

- **(1a)** Single `Carrier()` module with feature flags (back plate on/off, drain pan on/off, reservoir height, etc.) — composes its sub-pieces internally
- **(2b)** Footprint **shared** at `main.scad` top level via `Pot_Width` / `Pot_Depth`. Grid AND carrier both consume the same input — no inter-module dependency.
- **(3a)** Drain pan is a **generic reservoir** under the entire grid footprint — not targeted at specific cell drain hole positions.
- **Removable components from day 1** — components are not union'd into the drain pan. Drain pan has a flat top (or a raised lip matching the grid footprint); components rest on it. This means each component is an independent printable part that can be lifted out.

### Z placement contract

- Every independently printable v2 part must start at **Z=0** in print orientation.
- Carrier geometry owns its own full printable height: `base_thickness + reservoir_height` for the drain pan case.
- The carrier base occupies `0..base_thickness`; reservoir walls occupy `base_thickness..base_thickness+reservoir_height`.
- Assembly is the only place that lifts removable components onto the carrier. Components sit at `Carrier_Base_Thickness + Carrier_Reservoir_Height` when the drain pan carrier is enabled.
- Components should not compensate for carrier height internally; their bottom remains Z=0 in their own module.

### Migration approach
- **Greenfield rewrite** — drop old `cell_features/`, redesign in parallel, switch over once parity reached, then delete old.
- App is not running publicly — no migration concern.
- v1 PR #35 fixes (ordered features, multi-plane, span preservation) become **mostly irrelevant** in v2 — there's no list to order, no planes to reconcile, one component per cell. The work wasn't wasted; it solidified our understanding of the failure modes.

### Initial component set
- **Pot** — open container with optional lid; drain holes, lid seat
- **FillTube** — vertical tube/channel; bottom hole; optional cap
- **Box** — closed-bottom container; optional lid
- **WickPort** — single hole through whatever surrounds it; optional rim
- **Empty** — draws nothing; placeholder for unused cells / scaffold smoke tests

### Separable parts (sub-modules per component + dispatcher-driven output mode)

Each component declares its parts list and provides one sub-module per part:

```scad
function component_NAME__parts() = ["main"];           // single-part default
// or: ["main", "lid"] / ["main", "lid", "mesh"] for multi-part

module component_NAME__main(cell_w, cell_d, cell_h, params, cell_id = [0,0]) { ... }
module component_NAME__lid (cell_w, cell_d, cell_h, params, cell_id = [0,0]) { ... }
```

**Dispatcher** (in `_dispatch.scad`) handles output modes:
- `Assembly` — renders all parts in their assembled positions
- `Print Layout` — renders all parts laid flat with print spacing
- `Component Only` — same as Assembly but no carrier
- `Carrier Only` — no components rendered

Each part sub-module draws itself in its **print orientation**; the dispatcher rotates/translates into assembly position when needed. (Open: how exactly; will solidify when first multi-part component lands.)

### Grid additions (in scope for v2)

- **Splits** — inverse of spans; divides one cell into a sub-grid
- **Mixed fixed + dynamic sizing** — `gridRowSizes / gridColumnSizes` parser supports `"10, 1*, 1*, 10"` style (mm + weighted)

### Output modes (in scope for v2)
- `Assembly`
- `Print Layout`
- `Component Only`
- `Carrier Only`

### File structure (target)

```
cad/openscad/v2/
├── main.scad                ← orchestrator
├── grid.scad                ← layout primitives (margin, padding, spans, splits, fusion)
├── carrier.scad             ← single Carrier() module with feature flags
└── components/
    ├── _dispatch.scad       ← component_apply() + part-orchestration per output mode
    ├── _params.scad         ← param_num / param_str / param_bool helpers
    ├── empty.scad
    ├── pot.scad
    ├── fill_tube.scad
    ├── box.scad
    └── wick_port.scad
```

Old `cad/openscad/*.scad` + `cell_features/` stay untouched until v2 reaches parity, then cleaned up in a final phase.

### Designer UX
Will be redesigned to mirror the new model: per-cell **component picker** → component-specific param panel. Plane / multi-feature concepts retire. Details (collapsible sections, defaults, apply-to-all shortcut) surface during designer rewrite.

## Implementation sequence

Each step = one commit, reviewable independently.

1. **memory folder** added to repo (implemented on `refactor/v2-architecture`)
2. **v2 scaffolding** — empty stubs, header comments only (implemented)
3. **`grid.scad`** — layout primitives, pure data (first pass implemented: fixed-mm, percent, weighted-star tracks, uniform margin/padding)
4. **`carrier.scad`** — Carrier() with flags (first pass implemented: simple reservoir/foundation, optional placeholder back plate)
5. **dispatcher + empty component** — validates contract end-to-end (implemented)
6. **`v2/main.scad` orchestrator + smoke test** — 2×2 of Empty renders just the carrier (implemented)
7. **`pot.scad`** — first real component with lid (multi-part) (implemented first pass)
8. **fill_tube, box, wick_port** — one commit each
9. **designer rewrite** — parallel work, can start after step 5
10. **switch-over** — promote `v2/` to top-level, delete legacy

## Immediate execution plan

Current branch: `refactor/v2-architecture`

Goal for the next PR: create a working v2 skeleton that renders something real without touching legacy v1 files. The PR should prove the new layer boundaries before any complex component work begins.

Status: implemented locally on `refactor/v2-architecture`.

### Step A — make the scaffold internally valid
- Add `cad/openscad/v2/components/`
- Add `_dispatch.scad`, `_params.scad`, and `empty.scad`
- Ensure `cad/openscad/v2/main.scad` can be opened/rendered without missing include errors
- Output may be visually simple; the point is contract validation

Implemented.

### Step B — implement minimal grid layout
- Implement `grid_layout()` for basic row/column sizing:
  - comma-separated tracks
  - numeric fixed tracks
  - weighted `*` tracks
  - no spans/splits yet except safe passthrough defaults
- Return cell records using the locked shape:
  `[cx, cy, cell_w, cell_d, cell_h, row, col]`
- Keep margin/padding parameters in the signature, but implement only uniform defaults first

Implemented. Spans, splits, and sparse margin/padding overrides are still placeholders.

### Step C — implement minimal carrier
- Implement `Carrier()` as a simple removable foundation:
  - flat reservoir/drain pan footprint
  - no OpenGrid back plate yet
  - basic wall/base dimensions only
- Keep feature flags in the signature so later commits can add back plate / drain pan options without changing caller contracts

Implemented. Carrier chamfer is capped internally so BOSL2 does not reject thin base geometry.

### Step D — implement dispatcher + empty component path
- `component_apply()` dispatches `empty` first
- `render_components()` iterates grid cells and calls dispatcher
- `Assembly`, `Print Layout`, `Component Only`, and `Carrier Only` exist as output mode branches, even if some render the same minimal geometry initially

Implemented. `Component Only` with only `empty` components exits cleanly but does not create an STL file because there is no geometry.

### Step E — smoke-test v2/main.scad
- Default v2 scene renders:
  - carrier visible
  - 2x2 empty grid produces no component bodies
  - no missing include/module errors
- OpenSCAD verification command should be recorded in the PR body

Implemented. Verified with OpenSCAD Nightly:

```powershell
& 'C:\Program Files\OpenSCAD (Nightly)\openscad.com' -q -o tmp_v2_assembly.stl cad\openscad\v2\main.scad
& 'C:\Program Files\OpenSCAD (Nightly)\openscad.com' -q -D 'Output_Mode="Print Layout"' -o tmp_v2_print.stl cad\openscad\v2\main.scad
& 'C:\Program Files\OpenSCAD (Nightly)\openscad.com' -q -D 'Output_Mode="Component Only"' -o tmp_v2_components.stl cad\openscad\v2\main.scad
& 'C:\Program Files\OpenSCAD (Nightly)\openscad.com' -q -D 'Output_Mode="Carrier Only"' -o tmp_v2_carrier.stl cad\openscad\v2\main.scad
```

Also verified:

```powershell
dotnet build apps/designer/OpenGarden.Designer.csproj
```

### Step F — update memory after implementation
- Mark scaffold + minimal grid/carrier/dispatcher as implemented
- Record any contract changes discovered during implementation
- Keep unresolved decisions explicit before moving to Pot component work

Implemented in this memory update.

## Pot component — first pass

Implement `cad/openscad/v2/components/pot.scad` as the first real component.

First-pass scope:
- `component_pot__parts() = ["main", "lid"]` (implemented)
- `component_pot__main(...)` renders an open pot body inside its cell rectangle (implemented)
- bottom drain holes belong to the pot component (implemented)
- lid seat/lip belongs to the pot component (implemented)
- `component_pot__lid(...)` renders a simple printable lid plate (implemented)
- dispatcher supports `pot` (implemented)
- `v2/main.scad` default component becomes `pot` for smoke testing (implemented)

Keep out of first pass:
- spans
- splits
- per-cell component selection DSL
- designer rewrite
- OpenGrid back plate integration

Important implementation note: OpenSCAD `if/else` routing in `_dispatch.scad` must use braces. Without braces, the `else if (name == "pot")` can bind to the inner `part` check and make non-empty components silently render nothing.

Smoke-test behavior:
- `Assembly` renders the carrier plus four removable pot components on top of it.
- `Print Layout` renders carrier, pot bodies, and separate lids.
- `Component Only` renders only the pot bodies.
- `Carrier Only` renders only the carrier.

Current simplifications:
- all cells use the same default component and params
- print layout is a simple row of parts, not an optimized packing layout
- the carrier is still a simple reservoir/foundation; OpenGrid back plate integration remains later

## Migration / build sequence (sketch)

Once enough of the above is locked:
1. New folder `cad/openscad/v2/` (or rename old → `legacy/`)
2. Build grid layout primitives first (margin/padding/spans/splits/fusion)
3. Add carrier with feature flags
4. Implement first component (Pot) end-to-end through main.scad
5. Migrate other features → components (FillTube, Box, WickPort, Empty)
6. Designer-side rewrite to match the new model
7. Delete old `cell_features/`, `feature_dsl.scad`, `pot_insert.scad`'s feature-related code

## Notes / lessons from v1

- The "feature stacking" model produced interaction rules that don't scale (chamfer × span × plane × wallThickness × neighbor)
- The recursive char-by-char DSL parser in OpenSCAD (`feature_dsl.scad`, `registry.scad`) was a tax we paid for using a string format; OpenSCAD list literals are parser-free
- "Bleed into walls" semantics for lid_lip kept fighting the chamfer because both the wall AND the chamfer are owned by the same module — separating them (component owns walls, grid owns chamfer if it draws gap-fill, carrier owns its own pieces) makes the conflict structurally impossible
