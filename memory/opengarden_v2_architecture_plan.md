---
name: OpenGarden v2 architecture plan
description: ACTIVE restart of the OpenSCAD v2 model around a prismoid top shell, simple grid layout, and BOSL2 diff/tag subtraction.
type: project
---
# OpenGarden v2 — shell/grid/subtract restart

**Status as of 2026-05-09:** v2 was restarted from scratch on `refactor/v2-architecture`. The active proof is intentionally tiny: one top shell, one grid position, one subtractive pot cut. Do not reintroduce carrier, drain, OpenGrid back plate, lids, feature registry, or rich components until this base idea is correct.

## Core Idea

Start with a single solid top shell. The shell itself is the product body:

- `TopShell()` is a BOSL2 `prismoid`
- it has `size1`, `size2`, `h`
- it can be chamfered and later rounded
- it owns the visible outside form

Then apply a grid layout to the shell's top surface:

- grid rows and columns divide the top shell surface
- `row, col` identifies where a subtractive component should be placed
- padding controls the usable rectangle inside that grid cell
- later, margin can control spacing between adjacent cells

Then subtract a component from the shell:

- use BOSL2 `diff()` in the shell
- use BOSL2 `tag()` in the subtractive component
- first subtractive component is `PotCut()`
- no drain, no OpenGrid, no carrier, no printable lids in this step

## Current Files

```text
cad/openscad/v2/
├── main.scad   // parameter wiring and first proof scene
├── shell.scad  // TopShell(), prismoid + diff()
├── grid.scad   // grid_cell_size(), grid_cell_center()
└── pot.scad    // PotCut(), tagged subtractive prismoid
```

All older v2 files were removed.

## Current Contract

`TopShell()`:

```scad
module TopShell(size1, size2, h, chamfer, rounding, subtract_tag)
```

`grid_cell_center()` and `grid_cell_size()`:

```scad
grid_cell_center(shell_size, rows, cols, row, col, padding)
grid_cell_size(shell_size, rows, cols, padding)
```

`PotCut()`:

```scad
module PotCut(size, h, chamfer, tag_name)
```

`main.scad` composes them:

```scad
TopShell(...)
  translate([cell_center[0], cell_center[1], Shell_Height])
    PotCut(size=cell_size, h=Pot_Height, chamfer=Pot_Chamfer);
```

## Locked Rules For This Phase

- Keep the model simple.
- Prove one cell first.
- Shell is positive geometry.
- Components are subtractive tools for now.
- Grid only computes placement and size.
- Use `diff()` / `tag()` instead of hand-written `difference()` routing.
- Do not add carrier, drain pan, OpenGrid back plate, lid generation, feature stacking, or UI wiring yet.

## Verified

OpenSCAD Nightly export passed:

```powershell
& 'C:\Program Files\OpenSCAD (Nightly)\openscad.com' -q -o tmp_v2_restart.stl cad\openscad\v2\main.scad
```

PNG preview confirmed: one chamfered prismoid shell with one inset pot cut.
