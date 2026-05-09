include <BOSL2/std.scad>
include <_params.scad>

function component_pot__parts() = ["main", "lid"];

module component_pot__main(cell_w, cell_d, cell_h, params = [], cell_id = [0, 0]) {
  wall = param_num(params, "wall", 2);
  base = param_num(params, "base", 2);
  chamfer = param_num(params, "chamfer", 2);
  holes_rows = max(1, round(param_num(params, "holes_rows", 3)));
  holes_cols = max(1, round(param_num(params, "holes_cols", 3)));
  holes_diameter = param_num(params, "holes_diameter", 4);
  holes_padding = param_num(params, "holes_padding", 12);
  lid_seat_depth = param_num(params, "lid_seat_depth", 2);
  lid_seat_width = param_num(params, "lid_seat_width", 1.5);

  safe_wall = min(max(0.4, wall), min(cell_w, cell_d) / 3);
  safe_base = min(max(0.4, base), cell_h / 3);
  safe_chamfer = min(chamfer, safe_wall / 2, safe_base / 2);
  safe_seat_depth = min(max(0, lid_seat_depth), cell_h / 3);
  safe_seat_width = min(max(0, lid_seat_width), safe_wall);

  difference() {
    union() {
      rect_tube(
        size=[cell_w, cell_d],
        h=cell_h,
        wall=safe_wall,
        chamfer=safe_chamfer,
        ichamfer=safe_chamfer,
        anchor=BOTTOM
      );

      cuboid(
        [cell_w, cell_d, safe_base],
        chamfer=safe_chamfer,
        anchor=BOTTOM
      );
    }

    component_pot__drain_holes(
      cell_w,
      cell_d,
      safe_base,
      safe_wall,
      holes_rows,
      holes_cols,
      holes_diameter,
      holes_padding
    );

    if (safe_seat_depth > 0 && safe_seat_width > 0)
      up(cell_h + 0.05)
        component_pot__lid_seat(cell_w, cell_d, safe_seat_depth + 0.1, safe_seat_width);
  }
}

module component_pot__lid(cell_w, cell_d, cell_h, params = [], cell_id = [0, 0]) {
  wall = param_num(params, "wall", 2);
  lid_thickness = param_num(params, "lid_thickness", 2);
  lid_clearance = param_num(params, "lid_clearance", 0.4);
  lid_grip = param_bool(params, "lid_grip", true);
  safe_wall = min(max(0.4, wall), min(cell_w, cell_d) / 3);
  lid_w = max(0.01, cell_w - safe_wall * 2 - lid_clearance);
  lid_d = max(0.01, cell_d - safe_wall * 2 - lid_clearance);

  union() {
    cuboid([lid_w, lid_d, lid_thickness], chamfer=min(lid_thickness / 4, safe_wall / 3), anchor=BOTTOM);

    if (lid_grip)
      translate([0, 0, lid_thickness])
        cuboid([lid_w / 3, lid_d / 8, lid_thickness], chamfer=lid_thickness / 4, anchor=BOTTOM);
  }
}

module component_pot__drain_holes(cell_w, cell_d, base, wall, rows, cols, diameter, padding) {
  span_x = max(0, cell_w - wall * 2 - padding);
  span_y = max(0, cell_d - wall * 2 - padding);

  for (row = [0:rows - 1])
    for (col = [0:cols - 1])
      translate([
        component_pot__hole_offset(col, cols, span_x),
        component_pot__hole_offset(row, rows, span_y),
        -0.05
      ])
        cylinder(d=diameter, h=base + 0.2);
}

module component_pot__lid_seat(cell_w, cell_d, depth, width) {
  difference() {
    cuboid([cell_w + 0.2, cell_d + 0.2, depth], anchor=TOP);
    cuboid([max(0.01, cell_w - width * 2), max(0.01, cell_d - width * 2), depth + 0.2], anchor=TOP);
  }
}

function component_pot__hole_offset(index, count, span) =
  count <= 1 ? 0 : -span / 2 + index * span / (count - 1);
