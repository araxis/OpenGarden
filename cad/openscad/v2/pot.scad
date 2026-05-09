include <BOSL2/std.scad>

module Pot(
  top_size = [180, 50],
  h = 25,
  wall = 2,
  floor = 3,
  taper = 0,
  chamfer = 1,
  hole_rows = 2,
  hole_cols = 6,
  hole_diameter = 3,
  hole_padding = 12
) {
  bottom_size = [
    max(0.01, top_size[0] - taper * 2),
    max(0.01, top_size[1] - taper * 2)
  ];
  safe_wall = min(max(0.4, wall), min(top_size[0], top_size[1], bottom_size[0], bottom_size[1]) / 3);
  safe_floor = max(0.4, floor);
  inner_top_size = [
    max(0.01, top_size[0] - safe_wall * 2),
    max(0.01, top_size[1] - safe_wall * 2)
  ];
  inner_bottom_size = [
    max(0.01, bottom_size[0] - safe_wall * 2),
    max(0.01, bottom_size[1] - safe_wall * 2)
  ];
  safe_chamfer = min(chamfer, h / 4, safe_wall / 2, min(top_size[0], top_size[1], bottom_size[0], bottom_size[1]) / 6);

  difference() {
    prismoid(
      size1=bottom_size,
      size2=top_size,
      h=h,
      chamfer=safe_chamfer,
      anchor=BOTTOM
    );

    up(h + 0.05)
      prismoid(
        size1=inner_bottom_size,
        size2=inner_top_size,
        h=max(0.01, h - safe_floor) + 0.1,
        chamfer=min(safe_chamfer, safe_wall / 3),
        anchor=TOP
      );

    PotDrainHoles(
      size=inner_bottom_size,
      floor=safe_floor,
      rows=hole_rows,
      cols=hole_cols,
      diameter=hole_diameter,
      padding=hole_padding
    );
  }
}

module BoxContainer(
  top_size = [180, 50],
  h = 25,
  wall = 2,
  floor = 3,
  chamfer = 1
) {
  safe_wall = min(max(0.4, wall), min(top_size[0], top_size[1]) / 3);
  safe_floor = max(0.4, floor);
  inner_top_size = [
    max(0.01, top_size[0] - safe_wall * 2),
    max(0.01, top_size[1] - safe_wall * 2)
  ];
  safe_chamfer = min(chamfer, h / 4, safe_wall / 2, min(top_size[0], top_size[1]) / 6);

  difference() {
    prismoid(
      size1=top_size,
      size2=top_size,
      h=h,
      chamfer=safe_chamfer,
      anchor=BOTTOM
    );

    up(h + 0.05)
      prismoid(
        size1=inner_top_size,
        size2=inner_top_size,
        h=max(0.01, h - safe_floor) + 0.1,
        chamfer=min(safe_chamfer, safe_wall / 3),
        anchor=TOP
      );
  }
}

module PotDrainHoles(size, floor, rows, cols, diameter, padding) {
  span_x = max(0, size[0] - padding);
  span_y = max(0, size[1] - padding);

  for (row = [0:rows - 1])
    for (col = [0:cols - 1])
      translate([
        PotHoleOffset(col, cols, span_x),
        PotHoleOffset(row, rows, span_y),
        -0.1
      ])
        cylinder(d=diameter, h=floor + 0.2, anchor=BOTTOM);
}

function PotHoleOffset(index, count, span) =
  count <= 1 ? 0 : -span / 2 + index * span / (count - 1);
