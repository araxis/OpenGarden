include <BOSL2/std.scad>

module feature_drain_holes(
  cell_w,
  cell_d,
  pattern = "Rectangle",
  rows = 4,
  cols = 4,
  diameter = 5,
  padding = 25
) {
  rs = max(1, round(rows));
  cs = max(1, round(cols));
  span_x = max(0, cell_w - padding);
  span_y = max(0, cell_d - padding);

  if (pattern == "Circle") {
    radius = max(0, min(span_x, span_y) / 2 - diameter / 2);
    ring_spacing = diameter * 1.15;
    fitted_rows = radius <= 0 ? 1 : min(rs, floor(radius / ring_spacing) + 1);

    for (ring = [0:fitted_rows - 1]) {
      ring_radius = fitted_rows <= 1 ? 0 : ring * radius / (fitted_rows - 1);
      holes = ring == 0 ? 1 : cs * ring;
      angle_offset = ring % 2 == 0 ? 180 / holes : 0;
      for (hole = [0:holes - 1])
        translate([
          ring_radius * cos(angle_offset + 360 * hole / holes),
          ring_radius * sin(angle_offset + 360 * hole / holes),
          0
        ])
          cyl(d=diameter, h=30);
    }
  } else {
    for (row = [0:rs - 1])
      for (col = [0:cs - 1])
        translate([
          feature_hole_offset(row, rs, span_x),
          feature_hole_offset(col, cs, span_y),
          0
        ])
          cyl(d=diameter, h=30);
  }
}

function feature_hole_offset(index, count, span) =
  count <= 1 ? 0 : -span / 2 + index * span / (count - 1);
