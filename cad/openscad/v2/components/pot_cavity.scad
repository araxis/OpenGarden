include <BOSL2/std.scad>
include <_params.scad>

function component_pot_cavity__parts() = ["lid"];

module component_pot_cavity__tool(cell_w, cell_d, cell_h, params = [], cell_id = [0, 0], shell_height = 100) {
  wall = param_num(params, "wall", 2);
  floor = param_num(params, "floor", 2);
  cavity_depth = param_num(params, "cavity_depth", cell_h);
  chamfer = param_num(params, "cavity_chamfer", 2);
  holes_rows = max(1, round(param_num(params, "holes_rows", 3)));
  holes_cols = max(1, round(param_num(params, "holes_cols", 3)));
  holes_diameter = param_num(params, "holes_diameter", 4);
  holes_padding = param_num(params, "holes_padding", 12);
  lid_seat_depth = param_num(params, "lid_seat_depth", 2);
  lid_seat_width = param_num(params, "lid_seat_width", 1.5);

  safe_wall = min(max(0.4, wall), min(cell_w, cell_d) / 3);
  safe_floor = min(max(0.4, floor), shell_height / 3);
  safe_depth = min(max(0.4, cavity_depth), max(0.4, shell_height - safe_floor));
  safe_chamfer = min(chamfer, safe_wall / 2, safe_depth / 5);
  safe_seat_depth = min(max(0, lid_seat_depth), safe_depth / 3);
  safe_seat_width = min(max(0, lid_seat_width), safe_wall);
  inner_w = max(0.01, cell_w - safe_wall * 2);
  inner_d = max(0.01, cell_d - safe_wall * 2);

  union() {
    translate([0, 0, shell_height + 0.05])
      cuboid(
        [inner_w, inner_d, safe_depth + 0.1],
        chamfer=safe_chamfer,
        anchor=TOP
      );

    if (safe_seat_depth > 0 && safe_seat_width > 0)
      translate([0, 0, shell_height + 0.08])
        component_pot_cavity__lid_seat_tool(cell_w, cell_d, safe_seat_depth + 0.1, safe_seat_width);

    component_pot_cavity__drain_holes(
      inner_w,
      inner_d,
      shell_height - safe_depth,
      holes_rows,
      holes_cols,
      holes_diameter,
      holes_padding
    );
  }
}

module component_pot_cavity__lid(cell_w, cell_d, cell_h, params = [], cell_id = [0, 0]) {
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

module component_pot_cavity__lid_seat_tool(cell_w, cell_d, depth, width) {
  difference() {
    cuboid([cell_w + 0.2, cell_d + 0.2, depth], anchor=TOP);
    cuboid([max(0.01, cell_w - width * 2), max(0.01, cell_d - width * 2), depth + 0.2], anchor=TOP);
  }
}

module component_pot_cavity__drain_holes(cell_w, cell_d, floor_z, rows, cols, diameter, padding) {
  span_x = max(0, cell_w - padding);
  span_y = max(0, cell_d - padding);

  for (row = [0:rows - 1])
    for (col = [0:cols - 1])
      translate([
        component_pot_cavity__hole_offset(col, cols, span_x),
        component_pot_cavity__hole_offset(row, rows, span_y),
        -0.05
      ])
        cylinder(d=diameter, h=floor_z + 0.2);
}

function component_pot_cavity__hole_offset(index, count, span) =
  count <= 1 ? 0 : -span / 2 + index * span / (count - 1);
