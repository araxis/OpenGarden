# CAD Layout

## Purpose

Defines how OpenSCAD files are structured and organized.

![OpenSCAD output modes](../../images/diagrams/cad-output-modes.svg)

---

## Current Folder Structure

```text
cad/openscad/
  anchor_names.scad
  back_plate.scad
  cell_anchors.scad
  cell_features/
    box.scad
    drain_holes.scad
    fill_tube.scad
    lid_lip.scad
    registry.scad
    wick_port.scad
  grid_helpers.scad
  main.scad
  pot_drain.scad
  pot_holder_frame.scad
  pot_insert.scad
```

`main.scad` is the entry point for previewing or exporting:

- `Assembly`
- `Freestanding Pot`
- `Print Layout`
- `Holder Only`
- `Drain Only`
- `Pot Insert Only`

The `OpenGrid_Support` flag selects whether shared modes are for the OpenGrid-mounted holder or the freestanding drain/pot pair:

- `OpenGrid_Support = true`: `Assembly` and `Print Layout` use the holder and pot insert.
- `OpenGrid_Support = false`: `Assembly` and `Print Layout` use the drain pan and pot insert.

---

## Pot Insert Layers

The pot insert is built in three layers:

1. **Grid layout** (`grid_helpers.scad`) — parses `Grid_Row_Sizes`, `Grid_Column_Sizes`, and `Grid_Cell_Spans` strings into per-cell positions and sizes.
2. **Feature registry** (`cell_features/registry.scad`) — resolves `Cell_Default_Feature` plus `Cell_Feature_Overrides` into one feature per cell per plane.
3. **Feature modules** (`cell_features/*.scad`) — each feature owns its geometry, defaults, and per-cell parameters.

Adding a new add-on (sensor slot, trellis post, drain mesh seat, etc.) means adding a feature file under `cell_features/` and one dispatch entry in `registry.scad`. `pot_insert.scad` should stay focused on grid placement and mount-plane passes.

The Customizer DSL uses `row,col: feature key=value key=value` entries, for example `1,1: dh pattern=C rows=3 cols=6; 2,2: ll depth=2`. Short feature names are user-facing aliases, while the registry normalizes them to canonical feature module names.

Per-cell named BOSL2 anchors (`cell_<row>_<col>_top`, `cell_<row>_<col>_wall_n`, etc.) are built by `cell_anchors.scad` and exposed on every `PotInsert()`. External accessory `.scad` files can `attach()` directly to those anchors without modifying the insert source.

---

## Target Folder Structure

As the project grows, the CAD can move toward this structure:

```text
cad/openscad/

- params/
  - Global parameters (MVP + OpenGrid)

- lib/
  - Shared helpers and utilities

- interfaces/
  - External system adapters (OpenGrid)

- modules/
  - Individual printable parts

- assemblies/
  - Combined previews

- main.scad
  - Entry point
```

---

## Rules

### 1. No Hardcoding
All dimensions must come from `params/`.

---

### 2. One Responsibility Per File
Each file defines exactly one module.

---

### 3. Assemblies Are Non-Destructive
Assemblies must NOT merge parts into one solid.

They are only for preview.

---

### 4. Interfaces Are Isolated
All OpenGrid-specific logic must be inside:

interfaces/opengrid_interface.scad

---

### 5. Reusability

Modules must:
- not depend on assembly files
- not assume fixed positions
