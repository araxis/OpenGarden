include <BOSL2/std.scad>

module Pot(
  top_size = [180, 50],
  h = 25,
  floor = 3,
  taper = 6,
  chamfer = 1,
  hole_rows = 2,
  hole_cols = 6,
  hole_diameter = 3,
  hole_padding = 12,
  tag_name = "cut"
) {
  bottom_size = [
    max(0.01, top_size[0] - taper * 2),
    max(0.01, top_size[1] - taper * 2)
  ];
  safe_chamfer = min(chamfer, h / 4, min(top_size[0], top_size[1], bottom_size[0], bottom_size[1]) / 6);
  safe_floor = max(0.4, floor);

  tag(tag_name)
    union() {
      down(0.05)
      prismoid(
        size1=bottom_size,
        size2=top_size,
        h=h + 0.1,
        chamfer=safe_chamfer,
        anchor=TOP
      );

      PotDrainHoles(
        size=bottom_size,
        z=-h + 0.05,
        floor=safe_floor,
        rows=hole_rows,
        cols=hole_cols,
        diameter=hole_diameter,
        padding=hole_padding
      );
    }
}

module PotDrainHoles(size, z, floor, rows, cols, diameter, padding) {
  span_x = max(0, size[0] - padding);
  span_y = max(0, size[1] - padding);

  for (row = [0:rows - 1])
    for (col = [0:cols - 1])
      translate([
        PotHoleOffset(col, cols, span_x),
        PotHoleOffset(row, rows, span_y),
        z
      ])
        cylinder(d=diameter, h=floor + 0.2, anchor=TOP);
}

function PotHoleOffset(index, count, span) =
  count <= 1 ? 0 : -span / 2 + index * span / (count - 1);
