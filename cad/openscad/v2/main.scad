include <BOSL2/std.scad>
include <pot.scad>
include <shell.scad>
include <grid.scad>

$fn = 48;

Pot_Cavity_Height = 37;
Pot_Wall = 2;
Pot_Floor = 3;
Pot_Taper = 0;
Pot_Chamfer = 1;
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

Grid_Row_Sizes = "1*,1*";
Grid_Column_Sizes = "1*,2*,1*";
Grid_Padding = [4, 4, 4, 4]; // [left, right, front, back]

Components = [
  [["type", "pot"], ["row", 1], ["col", 1], ["cavity_h", Pot_Cavity_Height]],
  [["type", "box"], ["row", 1], ["col", 2], ["margin", 8]],
  [["type", "fill_tube"], ["row", 2], ["col", 3], ["tube_w", 12], ["tube_d", 12], ["clearance", 0.2]]
];

Preview_Spacing = 18;
Show_Component_References = true;
Show_FillTube_Reference = false;

module ComponentReference(component) {
  comp_type = v2_component_prop(component, "type", "pot");
  row = v2_component_prop(component, "row", 1);
  col = v2_component_prop(component, "col", 1);
  margin = v2_component_prop(component, "margin", 0);
  cavity_h = v2_component_prop(component, "cavity_h", Pot_Cavity_Height);
  center = grid_cell_center(Shell_Top_Size, Grid_Row_Sizes, Grid_Column_Sizes, row, col, Grid_Padding);
  cell_size = grid_cell_size(Shell_Top_Size, Grid_Row_Sizes, Grid_Column_Sizes, row, col, Grid_Padding);
  size = [max(0.01, cell_size[0] - margin * 2), max(0.01, cell_size[1] - margin * 2)];

  translate([center[0], center[1], 0])
    if (comp_type == "pot")
      Pot(
        top_size=size,
        h=cavity_h,
        wall=Pot_Wall,
        floor=Pot_Floor,
        taper=Pot_Taper,
        chamfer=Pot_Chamfer,
        hole_rows=Pot_Hole_Rows,
        hole_cols=Pot_Hole_Columns,
        hole_diameter=Pot_Hole_Diameter,
        hole_padding=Pot_Hole_Padding
      );
    else if (comp_type == "box")
      BoxContainer(
        top_size=size,
        h=cavity_h,
        wall=Pot_Wall,
        floor=Pot_Floor,
        chamfer=Pot_Chamfer
      );
    else if (comp_type == "fill_tube" && Show_FillTube_Reference) {
      tube_w = v2_component_prop(component, "tube_w", min(size[0], 10));
      tube_d = v2_component_prop(component, "tube_d", min(size[1], 10));
      prismoid(
        size1=[max(0.01, tube_w), max(0.01, tube_d)],
        size2=[max(0.01, tube_w), max(0.01, tube_d)],
        h=cavity_h,
        chamfer=Pot_Chamfer,
        anchor=BOTTOM
      );
    }
}

if (Show_Component_References)
  right((Shell_Top_Size[0] + Preview_Spacing) / 2)
    for (component = Components)
      ComponentReference(component);

left((Shell_Top_Size[0] + Preview_Spacing) / 2)
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
    default_cavity_height=Pot_Cavity_Height,
    default_clearance=Shell_Pot_Clearance,
    components=Components
  );
