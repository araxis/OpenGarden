# OpenGarden

OpenGarden is a modular self-watering planter project built around OpenGrid-style mechanical mounting, 3D-printed parts, and a future ESP32-based watering controller.

The current work is focused on the mechanical CAD for a wall-mounted holder, drain/reservoir area, and removable pot insert. Electronics, firmware, backend, and UI folders are reserved for later phases.

![OpenGarden assembled CAD view](docs/images/cad/opengarden-assembly.png)

## Current Status

- OpenSCAD CAD modules for the holder, drain pan, back plate, and pot insert
- BOSL2 attachable anchors for assembling the pot insert into the holder
- Main OpenSCAD entry point with assembly and print/export layouts
- Research and design notes for self-watering strategies

## Repository Layout

```text
OpenGarden/
  cad/
    openscad/                 OpenSCAD CAD source files
  docs/
    mechanical/               Mechanical design notes
    self_watering_research/   Research notes and reference images
    self_watering_design.md   Current system design direction
  assets/                     Project assets
  backend/                    Reserved for backend services
  electronics/                Reserved for circuit/electronics files
  firmware/                   Reserved for ESP32 firmware
  scripts/                    Reserved for helper scripts
  ui/                         Reserved for user interface work
```

## CAD Workflow

The main CAD entry point is:

```text
cad/openscad/main.scad
```

Open it in OpenSCAD Nightly and use the `Output_Mode` customizer value:

```scad
Output_Mode = "Assembly"; // [Assembly, Freestanding Pot, Print Layout, Holder Only, Drain Only, Pot Insert Only]
OpenGrid_Support = true;
Render_Quality = "Preview"; // [Preview, Export]
```

Modes:

- `Assembly`: shows either the OpenGrid holder assembly or the freestanding drain/pot assembly, based on `OpenGrid_Support`
- `Freestanding Pot`: assembles the drain pan and pot insert without the OpenGrid back plate
- `Print Layout`: places the printable parts side by side; with `OpenGrid_Support = true` it shows the holder and pot insert, and with `OpenGrid_Support = false` it shows the drain pan and pot insert
- `Holder Only`: exports just the holder
- `Drain Only`: exports just the drain pan/reservoir section
- `Pot Insert Only`: exports just the removable insert

![OpenGarden print layout CAD view](docs/images/cad/opengarden-print-layout.png)

Set `OpenGrid_Support = false` when printing a freestanding pot that does not mount to OpenGrid.

Set `Chamfer_Back_Side = true` to apply the side chamfer to both sides of the freestanding drain pan and pot insert. OpenGrid holder mode keeps the holder-facing chamfer style.

For OpenGrid holders, `Subtracted_Slots` reduces the back-plate slot count and `Slot_Placement` controls whether the remaining slots stay centered, move to the left/right side of the plate, or spread across valid OpenGrid positions.

The insert drain hole pattern can be set with `Hole_Pattern` and adjusted with `Hole_Rows`, `Hole_Columns`, `Hole_Diameter`, and `Hole_Area_Padding`. The pattern is generated inside each pot insert grid cell. `Rectangle` uses rows and columns; `Circle` uses rows as a maximum ring count and columns as holes per ring. Circle mode may use fewer rings when a cell is too small to fit the requested rings cleanly.

The pot insert interior is always treated as a grid. `Grid_Row_Sizes` and `Grid_Column_Sizes` are comma-separated strings; each item creates one row or column, so `1*` by itself creates one open compartment, while `1*,1*` creates two equal tracks. Track values can use relative weights such as `1*` or `2*`, plain numeric weights such as `1`, or percentages such as `25%`. `Grid_Cell_Spans` can merge walls with 1-based `row,column=rowspanxcolspan` entries, such as `1,1=1x2;2,2=2x1`. Spans merge the interior divider walls and make the spanned cell behave as one feature area. `Grid_Wall_Thickness` controls the divider wall thickness, and `Fill_Tube_Clearance` leaves a small margin around FillTube bottom cutouts.

Cell behavior is controlled by the cell-feature registry. `Cell_Default_Feature` is used by every cell that does not have an override. `Pot` is a drain-hole cell, `Box` is closed at the bottom, `FillTube` is an open-bottom tube cell, and `WickPort` is a single wick hole.

`Cell_Feature_Overrides` is a sparse per-cell list using 1-based `row,col: feature key=value key=value` entries separated by `;`. This syntax avoids programming-style parentheses in the OpenSCAD Customizer. Short aliases are supported:

- `dh` or `p` — `drain_holes` / `Pot`
- `b` — `box`
- `ft` or `f` — `fill_tube` / `FillTube`
- `wp` — `wick_port`
- `ll` — `lid_lip`
- `pattern=C` and `pattern=R` — `Circle` and `Rectangle`

Built-in features:

- `drain_holes` (`dh`, `p`) — `BOTTOM`. Params: `pattern`, `rows`, `cols`, `diameter`, `padding`. Unspecified params fall back to the global drain-hole settings.
- `box` (`b`) — `BOTTOM`. Closed floor, no cutout.
- `fill_tube` (`ft`, `f`) — `BOTTOM`. Open-bottom tube cell. Param: `clearance`.
- `wick_port` (`wp`) — `BOTTOM`. Single centered wick hole. Param: `diameter`.
- `lid_lip` (`ll`) — `TOP_LIP`. Rectangular ring recess at the top of the cell wall. Params: `depth`, `width`.

Examples:

```scad
Cell_Default_Feature = "Pot";
Cell_Feature_Overrides = "1,1: dh pattern=C rows=3 cols=6";
Cell_Feature_Overrides = "1,1: wp diameter=10; 2,2: ll depth=2";
```

Bottom-plane overrides replace the default feature for that cell. Top-lip overrides are additive, so the cell still uses `Cell_Default_Feature` for its floor. You can apply both planes to one cell by adding two entries for the same cell.

Each cell also exposes named BOSL2 anchors that external accessory `.scad` files can `attach()` to: `cell_<row>_<col>_top`, `cell_<row>_<col>_bottom`, `cell_<row>_<col>_center`, and `cell_<row>_<col>_wall_n/s/e/w` for cells on the corresponding boundary. Row and column are 1-based. Wall anchors only exist on grid-boundary cells.

Malformed or unknown `Cell_Feature_Overrides` entries are silently skipped.

The print layout spacing can be adjusted with:

```scad
Print_Spacing = 20;
```

Use `Render_Quality = "Preview"` while tuning the grid, roles, and hole layout. It lowers the global OpenSCAD facet count for smoother interaction. Switch to `Render_Quality = "Export"` for final STL output.

## CAD Dependencies

The OpenSCAD files use [BOSL2](https://github.com/BelfrySCAD/BOSL2). The project has been tested with OpenSCAD Nightly.

Expected local OpenSCAD path on the current development machine:

```text
C:\Program Files\OpenSCAD (Nightly)
```

To export from the command line:

```powershell
& 'C:\Program Files\OpenSCAD (Nightly)\openscad.com' -o output.stl cad\openscad\main.scad
```

To export a specific mode:

```powershell
& 'C:\Program Files\OpenSCAD (Nightly)\openscad.com' -D 'Output_Mode="Print Layout"' -o print-layout.stl cad\openscad\main.scad
```

## Design Direction

The project is moving toward an active pump-based self-watering system:

- removable pot insert
- drain/reservoir section
- OpenGrid-compatible mounting
- future ESP32 pump control
- later support for moisture or water-level sensors

See [docs/self_watering_design.md](docs/self_watering_design.md) for the current design notes.

## Development Notes

- Keep CAD modules reusable and avoid rendering sample objects from library files.
- Define shared BOSL2 anchor names in `cad/openscad/anchor_names.scad`.
- Use `main.scad` as the output/export entry point.
- Validate OpenSCAD changes by exporting the relevant `Output_Mode` values.
- Pull requests that change OpenSCAD files generate STL preview artifacts through GitHub Actions.
- Do not push feature work directly to `master`; create a branch and open a pull request first.

## Contributing

Use short-lived branches for changes:

```powershell
git checkout -b feat/your-change-name
```

Before opening a pull request, verify any CAD changes with OpenSCAD Nightly and include the tested `Output_Mode` values in the PR description. See [CONTRIBUTING.md](CONTRIBUTING.md) for the repository workflow.
