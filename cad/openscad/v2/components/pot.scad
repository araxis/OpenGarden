include <BOSL2/std.scad>
include <rim.scad>

module Pot(
  top_size = [180, 50],
  h = 25,
  wall = 2,
  floor = 3,
  taper = 0,
  chamfer = 1,
  rim_width = 0,
  rim_height = 0,
  rim_z = undef,
  rim_chamfer = 0.6,
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

  safe_rim_width = max(0, rim_width);
  safe_rim_height = max(0, rim_height);
  safe_rim_z = min(max(0, rim_z == undef ? h : rim_z), h);
  rim_body_size = PotOuterSizeAtZ(bottom_size, top_size, h, safe_rim_z);
  rim_inner_size = [
    max(0.01, rim_body_size[0] - safe_wall * 2),
    max(0.01, rim_body_size[1] - safe_wall * 2)
  ];
  rim_outer_size = [
    max(0.01, rim_body_size[0] + safe_rim_width * 2),
    max(0.01, rim_body_size[1] + safe_rim_width * 2)
  ];

  union() {
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

    if (safe_rim_width > 0 && safe_rim_height > 0)
      up(safe_rim_z)
        RectRim(
          outer_size=rim_outer_size,
          base_size=rim_body_size,
          inner_size=rim_inner_size,
          h=safe_rim_height,
          chamfer=rim_chamfer
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

function PotOuterSizeAtZ(bottom_size, top_size, h, z) =
  let (t = h <= 0 ? 1 : min(max(0, z), h) / h)
    [
      bottom_size[0] + (top_size[0] - bottom_size[0]) * t,
      bottom_size[1] + (top_size[1] - bottom_size[1]) * t
    ];
