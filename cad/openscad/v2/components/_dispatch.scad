include <BOSL2/std.scad>
include <_params.scad>
include <empty.scad>

function component_parts(name) =
  name == "empty" ? component_empty__parts()
  : ["main"];

module component_apply(name, part, cell_w, cell_d, cell_h, params = [], cell_id = [0, 0]) {
  if (name == "empty")
    if (part == "main")
      component_empty__main(cell_w, cell_d, cell_h, params, cell_id);
}

module render_components(cells, component_name = "empty", params = [], part = "main") {
  for (cell = cells)
    translate([cell[0], cell[1], 0])
      component_apply(
        component_name,
        part,
        cell[2],
        cell[3],
        cell[4],
        params,
        [cell[5], cell[6]]
      );
}

module render_components_print_layout(cells, component_name = "empty", params = [], part = "main", spacing = 20) {
  for (index = [0:len(cells) - 1])
    let (cell = cells[index])
      translate([index * (cell[2] + spacing), 0, 0])
        component_apply(
          component_name,
          part,
          cell[2],
          cell[3],
          cell[4],
          params,
          [cell[5], cell[6]]
        );
}
