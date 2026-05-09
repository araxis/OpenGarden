include <BOSL2/std.scad>
include <pot.scad>

$fn = 48;

Pot_Top_Size = [180, 50];
Pot_Height = 37;
Pot_Wall = 2;
Pot_Floor = 3;
Pot_Taper = 6;
Pot_Chamfer = 1;
Pot_Hole_Rows = 2;
Pot_Hole_Columns = 8;
Pot_Hole_Diameter = 3;
Pot_Hole_Padding = 14;

Pot(
  top_size=Pot_Top_Size,
  h=Pot_Height,
  wall=Pot_Wall,
  floor=Pot_Floor,
  taper=Pot_Taper,
  chamfer=Pot_Chamfer,
  hole_rows=Pot_Hole_Rows,
  hole_cols=Pot_Hole_Columns,
  hole_diameter=Pot_Hole_Diameter,
  hole_padding=Pot_Hole_Padding
);
