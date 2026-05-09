---
name: OpenGarden overview
description: What the OpenGarden project is — repo layout, current phase, roadmap, where mechanical/CAD/web/v2-rewrite work lives
type: project
---
# OpenGarden — project overview

Repo: `D:\Projects\OpenGarden`

Modular self-watering planter system. 3D-printed parts, OpenGrid wall mounting, future ESP32 watering controller. Currently transitioning between **Phase 1: mechanical CAD + web designer (done)** and a **v2 architectural rewrite** of the pot insert system.

## Architecture in one paragraph

Carrier-first design. Load path: OpenGrid → Carrier (`pot_holder_frame`) → Insert (`pot_insert`) → Accessories. Wet/dry separation: pot insert + sensor holder + tube clip are wet; electronics plate is dry. All parts replaceable independently. Active pump-based watering is the chosen architecture (passive wick is the fallback).

## Repo layout

```
cad/openscad/
  main.scad              entry point + customizer
  anchor_names.scad      shared BOSL2 anchor name constants
  back_plate.scad        OpenGrid Multiconnect mounting plate
  pot_drain.scad         drain pan / reservoir geometry
  pot_holder_frame.scad  carrier (back plate + drain pan)
  pot_insert.scad        v1 — multi-cell insert; will be DISSOLVED in v2
  grid_helpers.scad      v1 grid parser
  cell_features/         v1 — feature registry, drain_holes, lid_lip, wick_port, fill_tube, box
cad/bosl2/               BOSL2 library
apps/designer/           Blazor WebAssembly designer app (MudBlazor UI)
docs/
  self_watering_design.md
  mechanical/step-01-mvp-module/
  mechanical/step-02-opengrid-architecture/
memory/                  project memory / planning docs (this folder)
backend/ electronics/ firmware/ scripts/  (RESERVED empty placeholders)
```

## Phases (per docs/self_watering_design.md)

- **Phase 1 (done)**: holder, drain/reservoir, insert, BOSL2 anchors, output modes, Blazor WASM designer with feature panels
- **v2 rewrite (active)**: see [opengarden_v2_architecture_plan.md](opengarden_v2_architecture_plan.md) — split into clean grid/component/carrier layers
- **Phase 2**: print validation, overflow + refill design, basic pump integration
- **Phase 3**: ESP32 control, timed watering
- **Phase 4**: sensors, automation logic, backend (.NET)

## v1 (current) capabilities — being replaced by v2

`Grid_Row_Sizes`, `Grid_Column_Sizes` — comma-separated tracks with `*`/percent/numeric weights
`Cell_Feature_Overrides` — per-cell feature DSL: `row,col: feature_name key=value,...`
`Grid_Cell_Spans` — sparse cell merging
Feature types: `drain_holes`, `lid_lip`, `wick_port`, `fill_tube`, `box`

Known v1 limitation: chamfer-corner artifact on lid_lip — accepted in PR #35, will be fixed structurally in v2.

## Designer app (`apps/designer/`)

Blazor WebAssembly app (.NET 10, MudBlazor 9.4.0) — see [project_designer_app.md](project_designer_app.md)

- Live UI to configure all pot/grid/feature parameters
- Generates the OpenSCAD config text for copy-paste
- Runs OpenSCAD via WASM in the browser to produce a live STL preview

## Workflow rules (from CONTRIBUTING.md)

- Never push to `master` directly — short-lived feature branches + PR
- PR description must list which `Output_Mode` values were exported and verified
- GitHub Actions auto-renders STL previews on PRs that touch OpenSCAD files

## Why: shape of future work

v2 architectural rewrite is the active focus. It collapses the v1 feature-stacking model into a cleaner three-layer split (grid / component / carrier). Adding a new component will be one file + one dispatch line. Geometry interactions (chamfer, walls, neighbors) are made structurally impossible rather than rule-managed.
