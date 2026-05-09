include <BOSL2/std.scad>
include <grid.scad>

module ShellPlate(
  top_size = [200, 70],
  bottom_size = [196, 66],
  thickness = 3,
  chamfer = 0.8,
  rounding = 0
) {
  safe_thickness = max(0.5, thickness);
  safe_chamfer = min(chamfer, safe_thickness / 2, min(top_size[0], top_size[1], bottom_size[0], bottom_size[1]) / 6);
  safe_rounding = min(rounding, min(top_size[0], top_size[1], bottom_size[0], bottom_size[1]) / 6);

  prismoid(
    size1=bottom_size,
    size2=top_size,
    h=safe_thickness,
    chamfer=safe_chamfer,
    rounding=safe_rounding,
    anchor=BOTTOM
  );
}

module ShellPlateWithPotCut(
  top_size = [200, 70],
  bottom_size = [196, 66],
  thickness = 3,
  chamfer = 0.8,
  rounding = 0,
  pot_top_size = [180, 50],
  pot_taper = 6,
  pot_cavity_height = 37,
  fit_clearance = 0.4,
  cut_center = [0, 0]
) {
  safe_thickness = max(0.5, thickness);
  safe_clearance = max(0, fit_clearance);
  safe_cavity_height = max(0.5, pot_cavity_height);
  taper_at_cut_depth = pot_taper * min(1, safe_thickness / safe_cavity_height);

  cut_top_size = [
    max(0.01, pot_top_size[0] + safe_clearance * 2),
    max(0.01, pot_top_size[1] + safe_clearance * 2)
  ];
  cut_bottom_size = [
    max(0.01, pot_top_size[0] - taper_at_cut_depth * 2 + safe_clearance * 2),
    max(0.01, pot_top_size[1] - taper_at_cut_depth * 2 + safe_clearance * 2)
  ];

  difference() {
    ShellPlate(
      top_size=top_size,
      bottom_size=bottom_size,
      thickness=safe_thickness,
      chamfer=chamfer,
      rounding=rounding
    );

    translate([cut_center[0], cut_center[1], -0.1])
      prismoid(
        size1=cut_bottom_size,
        size2=cut_top_size,
        h=safe_thickness + 0.2,
        anchor=BOTTOM
      );
  }
}

function v2_component_prop(component, name, fallback, i = 0) =
  i >= len(component) ? fallback
  : component[i][0] == name ? component[i][1]
  : v2_component_prop(component, name, fallback, i + 1);

module v2_component_cut(
  component,
  shell_size,
  row_spec,
  col_spec,
  grid_padding,
  default_taper,
  default_cavity_height,
  default_clearance,
  shell_thickness
) {
  comp_type = v2_component_prop(component, "type", "pot");
  row = v2_component_prop(component, "row", 1);
  col = v2_component_prop(component, "col", 1);
  fit_clearance = v2_component_prop(component, "clearance", default_clearance);
  cavity_height = v2_component_prop(component, "cavity_h", default_cavity_height);
  taper = v2_component_prop(component, "taper", default_taper);
  margin = v2_component_prop(component, "margin", 0);
  tube_w = v2_component_prop(component, "tube_w", 8);
  tube_d = v2_component_prop(component, "tube_d", 8);

  center = grid_cell_center(shell_size, row_spec, col_spec, row, col, grid_padding);
  size = grid_cell_size(shell_size, row_spec, col_spec, row, col, grid_padding);

  safe_thickness = max(0.5, shell_thickness);
  safe_clearance = max(0, fit_clearance);
  safe_cavity_height = max(0.5, cavity_height);
  taper_at_cut_depth = taper * min(1, safe_thickness / safe_cavity_height);

  usable_size = [
    max(0.01, size[0] - margin * 2),
    max(0.01, size[1] - margin * 2)
  ];
  cut_top_size = comp_type == "fill_tube"
    ? [
        max(0.01, tube_w + safe_clearance * 2),
        max(0.01, tube_d + safe_clearance * 2)
      ]
    : [
        max(0.01, usable_size[0] + safe_clearance * 2),
        max(0.01, usable_size[1] + safe_clearance * 2)
      ];
  cut_bottom_size = comp_type == "pot"
    ? [
        max(0.01, size[0] - taper_at_cut_depth * 2 + safe_clearance * 2),
        max(0.01, size[1] - taper_at_cut_depth * 2 + safe_clearance * 2)
      ]
    : cut_top_size;

  translate([center[0], center[1], -0.1])
    prismoid(
      size1=cut_bottom_size,
      size2=cut_top_size,
      h=safe_thickness + 0.2,
      anchor=BOTTOM
    );
}

module ShellPlateWithComponents(
  top_size = [200, 70],
  bottom_size = [196, 66],
  thickness = 3,
  chamfer = 0.8,
  rounding = 0,
  row_spec = "1*",
  col_spec = "1*",
  grid_padding = [4, 4, 4, 4],
  default_taper = 0,
  default_cavity_height = 37,
  default_clearance = 0.4,
  components = [[["type", "pot"], ["row", 1], ["col", 1]]]
) {
  difference() {
    ShellPlate(
      top_size=top_size,
      bottom_size=bottom_size,
      thickness=thickness,
      chamfer=chamfer,
      rounding=rounding
    );

    for (component = components)
      v2_component_cut(
        component=component,
        shell_size=top_size,
        row_spec=row_spec,
        col_spec=col_spec,
        grid_padding=grid_padding,
        default_taper=default_taper,
        default_cavity_height=default_cavity_height,
        default_clearance=default_clearance,
        shell_thickness=thickness
      );
  }
}
