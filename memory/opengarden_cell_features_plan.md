---
name: OpenGarden cell-feature-registry plan (v1, historical)
description: SUPERSEDED. v1 cell-features registry — completed, then identified as architecturally too rigid. Kept for context. Active plan is opengarden_v2_architecture_plan.md.
type: project
---
# v1 Cell-feature registry — HISTORICAL REFERENCE

**Status: SUPERSEDED by v2 architecture rewrite.** See [opengarden_v2_architecture_plan.md](opengarden_v2_architecture_plan.md) for the active plan.

## What v1 was

A per-cell feature override system layered on top of the grid:
- DSL: `Cell_Feature_Overrides = "1,1: dh,pattern=R,rows=4; 1,2: ll,depth=2,width=1"`
- Each cell could have one feature per plane (BOTTOM + TOP_LIP)
- Features: `drain_holes`, `lid_lip`, `wick_port`, `fill_tube`, `box`
- Each feature was its own SCAD file under `cad/openscad/cell_features/`
- Recursive char-by-char DSL parser in `feature_dsl.scad` / `registry.scad`
- Designer app exposed it via `CellFeaturesPanel` + per-feature editors

## What shipped (PRs leading to v1 complete)

- PR #32: removed top-level hole pattern, per-cell only via DrainHoles feature
- PR #33: replaced MudNumericField with MudSlider for all numeric inputs
- PR #34: promoted Cell Features panel to top-level
- PR #35 (latest): ordered features (move up/down), multi-plane per cell, span preservation across multi-feature anchors, simplified lid_lip to internal recess, default Width 8→1

## Why we're rewriting

The v1 model layers many small features per cell. This produces interaction rules: chamfer × span × plane × wallThickness × neighbor. Each new feature potentially needs to know about chamfers, dividers, spans, walls. **The chamfer-corner artifact in lid_lip (still present in PR #35) is the canonical example: a "simple" feature interaction problem that took multiple rounds and still wasn't fully fixed.**

User's framing: *"applying these type of feature and fixes have to be much much easier — we are spending a lot of effort to add a really simple feature, it is not good sign."*

## Lessons carried into v2

- The "feature stacking" model has unbounded interaction surface area
- Recursive char-by-char DSL parsing in OpenSCAD is a tax — list literals are parser-free
- "Bleed into walls" semantics for lid_lip kept fighting the chamfer because both were owned by the same module — separating concerns (component owns walls, grid owns chamfer if drawing gap-fill) makes the conflict structurally impossible
- v2 reframes: **one component per cell**, components are self-contained units that own everything inside their cell rectangle (walls, chamfer, drain holes, lid, lid seat — all belong together as part of e.g. a "Pot" component)

## Files that will be deleted in v2

- `cad/openscad/cell_features/` (entire folder)
- `cad/openscad/feature_dsl.scad`
- `cad/openscad/cell_anchors.scad`
- Most of `cad/openscad/pot_insert.scad`

## Files that may live on (in modified form)

- `grid_helpers.scad` — grid math is largely sound; will gain margin/padding/splits/mixed sizing
- `back_plate.scad`, `pot_drain.scad` — carrier sub-pieces, conceptually unchanged
