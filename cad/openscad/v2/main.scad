include <BOSL2/std.scad>
include <shell.scad>
include <grid.scad>
include <components/registry.scad>
include <components/container.scad>

$fn = 48;

Pot_Height = 55;
Pot_Insert_Depth = 37;
Pot_Wall = 2;
Pot_Floor = 3;
Pot_Taper = 0;
Pot_Chamfer = 1;
Pot_Rim_Width = 3;
Pot_Rim_Height = 3;
Pot_Rim_Chamfer = 0.6;
Pot_Hole_Rows = 2;
Pot_Hole_Columns = 8;
Pot_Hole_Diameter = 3;
Pot_Hole_Padding = 14;

Shell_Top_Size = [200, 100];
Shell_Bottom_Size = Shell_Top_Size;
Shell_Thickness = 3; // Typical range: 2..5 mm
Shell_Chamfer = 0.8;
Shell_Rounding = 0;
Shell_Pot_Clearance = 0.4;

Container_Height = 60;
Container_Wall = 2;
Container_Floor = 2.4;
Container_Chamfer = 0;
Container_Rounding = 1.2;
Container_Seat_Ledge_Enabled = true;
Container_Seat_Ledge_Drop = 3;
Container_Seat_Ledge_Depth = 4;
Container_Seat_Ledge_Thickness = 2;
Container_Seat_Ledge_Chamfer = 1.2;
Container_Support_Deck_Enabled = true;
Container_Support_Deck_Clearance = 0.8;
Container_Support_Deck_Rail_Width = 3;
Container_Support_Deck_Rail_Gap = 7;
Container_Support_Deck_Side_Gap = 8;
Container_Support_Deck_Chamfer = 0.6;
Container_Shell_Clearance = 0;
Container_Z_Offset = 0;
Exploded_View = false;
Exploded_Z = 8;
Shell_Preview_X_Offset = 0;

Grid_Row_Sizes = "1*";
Grid_Column_Sizes = "1*,1*,1*";
Grid_Padding = [4, 4, 4, 4]; // [left, right, front, back]

Components = [
  [["type", "pot_rect"], ["row", 1], ["col", 1], ["pot_h", Pot_Height], ["insert_depth", Pot_Insert_Depth], ["rim_w", Pot_Rim_Width], ["rim_h", Pot_Rim_Height], ["rim_chamfer", Pot_Rim_Chamfer]],
  [["type", "pot_circle"], ["row", 1], ["col", 2], ["pot_h", Pot_Height], ["insert_depth", Pot_Insert_Depth], ["rim_w", Pot_Rim_Width], ["rim_h", Pot_Rim_Height]],
  [["type", "pot_oval"], ["row", 1], ["col", 3], ["pot_h", Pot_Height], ["insert_depth", Pot_Insert_Depth], ["rim_w", Pot_Rim_Width], ["rim_h", Pot_Rim_Height], ["rim_chamfer", Pot_Rim_Chamfer]],
];

Preview_Spacing = 18;
Show_Component_References = true;
Show_FillTube_Reference = false;

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

left((Shell_Top_Size[0] + Preview_Spacing) / 2)
  union() {
    up(Container_Z_Offset)
      ReservoirContainer(
        top_size=Shell_Bottom_Size,
        bottom_size=Shell_Bottom_Size,
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
        support_deck_enabled=Container_Support_Deck_Enabled,
        support_deck_clearance=Container_Support_Deck_Clearance,
        support_deck_rail_width=Container_Support_Deck_Rail_Width,
        support_deck_rail_gap=Container_Support_Deck_Rail_Gap,
        support_deck_side_gap=Container_Support_Deck_Side_Gap,
        support_deck_chamfer=Container_Support_Deck_Chamfer,
        components=Components,
        shell_size=Shell_Top_Size,
        row_spec=Grid_Row_Sizes,
        col_spec=Grid_Column_Sizes,
        grid_padding=Grid_Padding,
        default_insert_depth=Pot_Insert_Depth
      );

    right(Shell_Preview_X_Offset)
      up(
        (Container_Height + Container_Shell_Clearance)
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
