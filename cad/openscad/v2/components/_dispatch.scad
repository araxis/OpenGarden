include <BOSL2/std.scad>
include <_params.scad>
include <empty.scad>
include <pot.scad>

function component_parts(name) =
  name == "empty" ? component_empty__parts()
  : name == "pot" ? component_pot__parts()
  : ["main"];

module component_apply(name, part, cell_w, cell_d, cell_h, params = [], cell_id = [0, 0]) {
  if (name == "empty") {
    if (part == "main") {
      component_empty__main(cell_w, cell_d, cell_h, params, cell_id);
    }
  } else if (name == "pot") {
    if (part == "main") {
      component_pot__main(cell_w, cell_d, cell_h, params, cell_id);
    } else if (part == "lid") {
      component_pot__lid(cell_w, cell_d, cell_h, params, cell_id);
    }
  }
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

module render_component_parts_print_layout(cells, component_name = "empty", params = [], spacing = 20) {
  parts = component_parts(component_name);

  for (cell_index = [0:len(cells) - 1])
    for (part_index = [0:len(parts) - 1])
      let (
        cell = cells[cell_index],
        x = (cell_index * len(parts) + part_index) * (cell[2] + spacing)
      )
        translate([x, 0, 0])
          component_apply(
            component_name,
            parts[part_index],
            cell[2],
            cell[3],
            cell[4],
            params,
            [cell[5], cell[6]]
          );
}
