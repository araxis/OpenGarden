include <BOSL2/std.scad>
include <shell.scad>
include <grid.scad>
include <components/registry.scad>
include <components/container.scad>
include <components/deck_frame.scad>

/*[Preview]*/
// Show component reference geometry alongside the assembly.
Show_Component_References = true;
// Render fill-tube components in the reference preview (usually thin, hides other geometry).
Show_FillTube_Reference = false;
// X spacing between the reference group and the assembly group (mm).
Preview_Spacing = 18; // [0:1:100]
// X offset applied to the shell-plate preview (mm).
Shell_Preview_X_Offset = 0; // [-500:1:500]
// Z offset applied to the reservoir container in the preview (mm).
Container_Z_Offset = 0; // [-50:0.5:50]
// Vertical gap between container top and shell plate (mm).
Container_Shell_Clearance = 0; // [0:0.5:50]
// Lift the shell and deck frame off the container for an exploded view.
Exploded_View = false;
// Extra Z lift applied to the shell when Exploded_View is on (mm).
Exploded_Z = 8; // [0:0.5:60]
// Extra Z lift applied to the deck frame above the container when Exploded_View is on (mm).
Deck_Frame_Exploded_Z = 20; // [0:1:80]
// Show the deck frame in the assembled view.
Show_Deck_Frame = true;

/*[Grid]*/
// Comma-separated row tokens — one per row. Use "1*", "2*", literal mm, or "25%".
Grid_Row_Sizes = "1*";
// Comma-separated column tokens — one per column.
Grid_Column_Sizes = "1*,1*,1*,1*";
// Inner padding [left, right, front, back] applied to the grid (mm).
Grid_Padding = [4, 4, 4, 4];

/*[Shell Plate]*/
// Top footprint of the shell plate [x, y] (mm). Drops into the container opening.
// The reservoir container outer footprint is derived from this + Container_Wall + Shell_Plate_Fit_Clearance per side.
Shell_Top_Size = [200, 100];
// Plate thickness (mm). Typical range 2..5.
Shell_Thickness = 3; // [1:0.2:8]
// Chamfer applied to the plate's outer edges (mm).
Shell_Chamfer = 0.8; // [0:0.1:3]
// Corner-rounding radius on the plate footprint (mm).
Shell_Rounding = 0; // [0:0.5:30]
// Slip-fit clearance between pot rims and their shell-plate seats (mm).
Shell_Pot_Clearance = 0.4; // [0:0.05:1.5]
// Slip-fit gap between the shell plate outer edge and the container inner wall (mm).
Shell_Plate_Fit_Clearance = 0.4; // [0:0.05:1.5]

/*[Pot Body]*/
// Total pot height including the rim (mm).
Pot_Height = 55; // [20:1:200]
// Distance the pot drops into the shell-plate seat — must be < Pot_Height (mm).
Pot_Insert_Depth = 37; // [5:1:200]
// Wall thickness for the pot body (mm).
Pot_Wall = 2; // [0.8:0.1:6]
// Floor thickness for the pot body (mm).
Pot_Floor = 3; // [0.8:0.1:8]
// Per-side inward taper from top to bottom (mm). 0 = vertical walls.
Pot_Taper = 0; // [0:0.5:20]
// Body edge chamfer (mm). Only affects pot_rect; other pot shapes ignore this.
Pot_Chamfer = 1; // [0:0.1:5]
// Corner-rounding radius for pot_roundrect and box (mm). Ignored by other shapes.
Pot_Corner_Radius = 14; // [0:0.5:50]

/*[Pot Rim]*/
// Outward rim extension per side (mm). 0 disables the rim.
Pot_Rim_Width = 3; // [0:0.1:10]
// Rim height above the body (mm). 0 disables the rim.
Pot_Rim_Height = 3; // [0:0.1:10]
// Chamfer on the inside top edge of the rim opening (mm).
Pot_Rim_Chamfer = 0.6; // [0:0.1:3]

/*[Pot Drainage]*/
// Number of drain-hole rows (pot_rect / box). Other shapes use a ring layout.
Pot_Hole_Rows = 2; // [1:1:10]
// Number of drain-hole columns (pot_rect / box).
Pot_Hole_Columns = 8; // [1:1:20]
// Drain-hole diameter (mm).
Pot_Hole_Diameter = 3; // [1:0.1:10]
// Inset of the drain-hole pattern from the inner wall (mm).
Pot_Hole_Padding = 14; // [0:0.5:50]

/*[Reservoir Container]*/
// Reservoir container height (mm).
Container_Height = 60; // [20:1:200]
// Container wall thickness (mm).
Container_Wall = 2; // [0.8:0.1:6]
// Container floor thickness (mm).
Container_Floor = 2.4; // [0.8:0.1:8]
// Container outer-edge chamfer (mm).
Container_Chamfer = 0; // [0:0.1:5]
// Container corner-rounding radius (mm).
Container_Rounding = 1.2; // [0:0.1:30]

/*[Container Seat Ledge]*/
// Inner ledge that supports the shell plate at the container top.
Container_Seat_Ledge_Enabled = true;
// Drop from container top to ledge top (mm).
Container_Seat_Ledge_Drop = 3; // [0:0.5:30]
// Ledge horizontal depth (mm).
Container_Seat_Ledge_Depth = 4; // [0.5:0.5:20]
// Ledge vertical thickness (mm).
Container_Seat_Ledge_Thickness = 2; // [0.5:0.1:10]
// Chamfer on ledge edges (mm).
Container_Seat_Ledge_Chamfer = 1.2; // [0:0.1:5]

/*[Guide Rails]*/
// Add vertical guide rails to the container inner long walls for deck frame alignment.
Guide_Rails_Enabled = true;
// Guide rail width (mm).
Guide_Rail_Width = 5; // [2:0.5:12]
// Guide rail protrusion depth into the container interior (mm).
Guide_Rail_Depth = 1.2; // [0.5:0.1:3]
// Fit clearance between guide rail and deck frame channel, per side (mm).
Guide_Rail_Clearance = 0.3; // [0:0.05:1]
// Distance from inner corner to guide rail center along the long wall (mm).
Guide_Rail_Corner_Offset = 16; // [5:0.5:60]

/*[Deck Frame]*/
// Vertical gap between deck slat tops and pot bottom (mm).
Deck_Frame_Support_Clearance = 0.8; // [0:0.1:5]
// Deck frame outer wall thickness (mm).
Deck_Frame_Wall = 3; // [1.2:0.2:6]
// Per-side fit clearance between frame outer edge and container inner wall (mm).
Deck_Frame_Fit_Clearance = 0.3; // [0:0.05:1]
// Slat width (mm).
Deck_Frame_Slat_Width = 3; // [1:0.1:10]
// Gap between adjacent slats (mm).
Deck_Frame_Slat_Gap = 7; // [1:0.1:30]
// Y-axis inset from long frame walls to slat zone (mm). Slats always span full inner X.
Deck_Frame_Slat_Side_Gap = 6; // [0:0.5:20]
// Slat edge chamfer (mm).
Deck_Frame_Slat_Chamfer = 0.6; // [0:0.1:3]
// Add arch bridges between slats.
Deck_Frame_Bridges = true;

/*[Hidden]*/
$fn = 48;

// Bottom footprint of the shell plate — tracks Shell_Top_Size so the plate stays flat.
// Override here for a tapered plate.
Shell_Bottom_Size = Shell_Top_Size;

// Reservoir container outer footprint — derived so the shell plate slip-fits inside.
Container_Outer_Size = [
  Shell_Top_Size[0] + Container_Wall * 2 + Shell_Plate_Fit_Clearance * 2,
  Shell_Top_Size[1] + Container_Wall * 2 + Shell_Plate_Fit_Clearance * 2
];

// Container inner footprint (outer minus two walls).
Container_Inner_Size = [
  Container_Outer_Size[0] - Container_Wall * 2,
  Container_Outer_Size[1] - Container_Wall * 2
];

// Z height at which the shell plate rests: on top of the seat ledge when enabled,
// otherwise on the container's top rim.
Shell_Rest_Z = Container_Seat_Ledge_Enabled
  ? max(0, Container_Height - Container_Seat_Ledge_Drop)
  : Container_Height;

// Deck frame height: from container floor surface up to the slat top (= pot insert level).
Deck_Frame_Height = max(1,
  Container_Height - Container_Floor - Pot_Insert_Depth - Deck_Frame_Support_Clearance
);

Components = [
  [["type", "pot_roundrect"], ["row", 1], ["col", 1], ["pot_h", Pot_Height], ["insert_depth", Pot_Insert_Depth], ["corner_radius", Pot_Corner_Radius], ["rim_w", Pot_Rim_Width], ["rim_h", Pot_Rim_Height], ["rim_chamfer", Pot_Rim_Chamfer]],
  [["type", "pot_circle"], ["row", 1], ["col", 2], ["pot_h", Pot_Height], ["insert_depth", Pot_Insert_Depth], ["rim_w", Pot_Rim_Width], ["rim_h", Pot_Rim_Height]],
  [["type", "pot_oval"], ["row", 1], ["col", 3], ["pot_h", Pot_Height], ["insert_depth", Pot_Insert_Depth], ["rim_w", Pot_Rim_Width], ["rim_h", Pot_Rim_Height], ["rim_chamfer", Pot_Rim_Chamfer]],
  [["type", "box"], ["row", 1], ["col", 4], ["cavity_h", Pot_Height], ["insert_depth", Pot_Insert_Depth], ["corner_radius", Pot_Corner_Radius], ["rim_w", Pot_Rim_Width], ["rim_h", Pot_Rim_Height], ["rim_chamfer", Pot_Rim_Chamfer]],
];

module ComponentReference(component) {
  v2_component_reference(
    component=component,
    shell_size=Shell_Top_Size,
    row_spec=Grid_Row_Sizes,
    col_spec=Grid_Column_Sizes,
    grid_padding=Grid_Padding,
    default_cavity_height=Pot_Insert_Depth,
    default_pot_height=Pot_Height,
    default_wall=Pot_Wall,
    default_floor=Pot_Floor,
    default_taper=Pot_Taper,
    default_chamfer=Pot_Chamfer,
    default_hole_rows=Pot_Hole_Rows,
    default_hole_cols=Pot_Hole_Columns,
    default_hole_diameter=Pot_Hole_Diameter,
    default_hole_padding=Pot_Hole_Padding,
    show_fill_tube_reference=Show_FillTube_Reference
  );
}

if (Show_Component_References)
  right((Shell_Top_Size[0] + Preview_Spacing) / 2)
    for (component = Components)
      ComponentReference(component);

left((Container_Outer_Size[0] + Preview_Spacing) / 2)
  union() {
    up(Container_Z_Offset)
      ReservoirContainer(
        top_size=Container_Outer_Size,
        bottom_size=Container_Outer_Size,
        h=Container_Height,
        wall=Container_Wall,
        floor=Container_Floor,
        chamfer=Container_Chamfer,
        rounding=Container_Rounding,
        seat_ledge_enabled=Container_Seat_Ledge_Enabled,
        seat_ledge_drop=Container_Seat_Ledge_Drop,
        seat_ledge_depth=Container_Seat_Ledge_Depth,
        seat_ledge_thickness=Container_Seat_Ledge_Thickness,
        seat_ledge_chamfer=Container_Seat_Ledge_Chamfer,
        deck_rails_enabled=Guide_Rails_Enabled,
        deck_rail_width=Guide_Rail_Width,
        deck_rail_depth=Guide_Rail_Depth,
        deck_rail_corner_offset=Guide_Rail_Corner_Offset
      );

    if (Show_Deck_Frame)
      up(Container_Z_Offset + Container_Floor
        + (Exploded_View ? Container_Height - Container_Floor + Deck_Frame_Exploded_Z : 0))
        DeckFrame(
          container_inner_size=Container_Inner_Size,
          frame_h=Deck_Frame_Height,
          frame_wall=Deck_Frame_Wall,
          fit_clearance=Deck_Frame_Fit_Clearance,
          guide_rail_width=Guide_Rail_Width,
          guide_rail_depth=Guide_Rail_Depth,
          guide_rail_clearance=Guide_Rail_Clearance,
          guide_rail_corner_offset=Guide_Rail_Corner_Offset,
          slat_width=Deck_Frame_Slat_Width,
          slat_gap=Deck_Frame_Slat_Gap,
          slat_side_gap=Deck_Frame_Slat_Side_Gap,
          slat_chamfer=Deck_Frame_Slat_Chamfer,
          include_bridges=Deck_Frame_Bridges,
          components=Components,
          shell_size=Shell_Top_Size,
          row_spec=Grid_Row_Sizes,
          col_spec=Grid_Column_Sizes,
          grid_padding=Grid_Padding
        );

    right(Shell_Preview_X_Offset)
      up(
        Shell_Rest_Z + Container_Shell_Clearance
        + Container_Z_Offset
        + (Exploded_View ? Exploded_Z : 0)
      )
        ShellPlateWithComponents(
          top_size=Shell_Top_Size,
          bottom_size=Shell_Bottom_Size,
          thickness=Shell_Thickness,
          chamfer=Shell_Chamfer,
          rounding=Shell_Rounding,
          row_spec=Grid_Row_Sizes,
          col_spec=Grid_Column_Sizes,
          grid_padding=Grid_Padding,
          default_taper=Pot_Taper,
          default_cavity_height=Pot_Insert_Depth,
          default_clearance=Shell_Pot_Clearance,
          default_cut_epsilon=0.2,
          components=Components,
          seat_enabled=false
        );
  }
