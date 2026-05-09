include <BOSL2/std.scad>
include <_params.scad>

function component_pot_cavity__parts() = [];

module component_pot_cavity__tool(cell_w, cell_d, cell_h, params = [], cell_id = [0, 0], shell_height = 100) {
  floor = param_num(params, "floor", 2);
  cavity_height = param_num(params, "cavity_height", cell_h);
  chamfer = param_num(params, "cavity_chamfer", 2);

  safe_floor = min(max(0.4, floor), shell_height / 3);
  safe_height = min(max(0.4, cavity_height), max(0.4, shell_height - safe_floor));
  safe_chamfer = min(chamfer, cell_w / 6, cell_d / 6, safe_height / 5);

  translate([0, 0, shell_height + 0.05])
    cuboid(
      [cell_w, cell_d, safe_height + 0.1],
      chamfer=safe_chamfer,
      anchor=TOP
    );
}
