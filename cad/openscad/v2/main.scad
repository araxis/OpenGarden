include <BOSL2/std.scad>
include <grid.scad>
include <shell.scad>
include <pot.scad>

$fn = 48;

Shell_Size_Top = [200, 70];
Shell_Size_Bottom = [190, 60];
Shell_Height = 40;
Shell_Thickness = 3;
Shell_Chamfer = 2;
Shell_Rounding = 0;

Grid_Rows = 1;
Grid_Columns = 1;
Cell_Row = 1;
Cell_Column = 1;
Cell_Padding = [6, 6, 6, 6]; // [left, right, fwd, back]

Pot_Height = Shell_Height - Shell_Thickness;
Pot_Taper = 6;
Pot_Chamfer = 1;
Pot_Hole_Rows = 2;
Pot_Hole_Columns = 8;
Pot_Hole_Diameter = 3;
Pot_Hole_Padding = 14;

cell_size = grid_cell_size(Shell_Size_Top, Grid_Rows, Grid_Columns, Cell_Padding);
cell_center = grid_cell_center(Shell_Size_Top, Grid_Rows, Grid_Columns, Cell_Row, Cell_Column, Cell_Padding);

TopShell(
  size1=Shell_Size_Top,
  size2=Shell_Size_Bottom,
  h=Shell_Height,
  chamfer=Shell_Chamfer,
  rounding=Shell_Rounding
)
  translate([cell_center[0], cell_center[1], Shell_Height])
    Pot(
      top_size=cell_size,
      h=Pot_Height,
      floor=Shell_Thickness,
      taper=Pot_Taper,
      chamfer=Pot_Chamfer,
      hole_rows=Pot_Hole_Rows,
      hole_cols=Pot_Hole_Columns,
      hole_diameter=Pot_Hole_Diameter,
      hole_padding=Pot_Hole_Padding
    );
