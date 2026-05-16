include <props.scad>
include <rim.scad>
include <pot.scad>
include <box.scad>
include <fill_tube.scad>
include <../grid.scad>

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
  insert_depth = v2_component_prop(component, "insert_depth", cavity_height);
  taper = v2_component_prop(component, "taper", default_taper);
  margin = v2_component_prop(component, "margin", 0);
  rim_w = v2_component_prop(component, "rim_w", comp_type == "pot" ? 4 : 0);
  seat_depth = v2_component_prop(component, "seat_depth", comp_type == "pot" ? 1.6 : 0);
  seat_chamfer = v2_component_prop(component, "seat_chamfer", 0.6);
  cut_epsilon = v2_component_prop(component, "cut_epsilon", 0.2);
  tube_w = v2_component_prop(component, "tube_w", 8);
  tube_d = v2_component_prop(component, "tube_d", 8);

  center = grid_cell_center(shell_size, row_spec, col_spec, row, col, grid_padding);
  cell_size = grid_cell_size(shell_size, row_spec, col_spec, row, col, grid_padding);
  size = [
    max(0.01, cell_size[0] - margin * 2),
    max(0.01, cell_size[1] - margin * 2)
  ];
  through_size = [
    max(0.01, size[0] - rim_w * 2),
    max(0.01, size[1] - rim_w * 2)
  ];

  safe_thickness = max(0.5, shell_thickness);
  safe_clearance = max(0, fit_clearance);
  safe_cavity_height = max(0.5, comp_type == "pot" ? insert_depth : cavity_height);
  taper_at_cut_depth = taper * min(1, safe_thickness / safe_cavity_height);
  cut_top_size = [
    max(0.01, through_size[0] + safe_clearance * 2),
    max(0.01, through_size[1] + safe_clearance * 2)
  ];
  cut_bottom_size = [
    max(0.01, through_size[0] - taper_at_cut_depth * 2 + safe_clearance * 2),
    max(0.01, through_size[1] - taper_at_cut_depth * 2 + safe_clearance * 2)
  ];

  translate([center[0], center[1], -0.1])
    if (comp_type == "fill_tube")
      FillTubeCut(
        tube_w=tube_w,
        tube_d=tube_d,
        fit_clearance=fit_clearance,
        shell_thickness=safe_thickness
      );
    else if (comp_type == "pot" && (rim_w > 0 || seat_depth > 0))
      RectSeatCut(
        outer_size=size,
        through_size=through_size,
        shell_thickness=safe_thickness,
        seat_depth=seat_depth,
        fit_clearance=fit_clearance,
        chamfer=seat_chamfer,
        cut_epsilon=cut_epsilon
      );
    else
      prismoid(
        size1=comp_type == "pot" ? cut_bottom_size : cut_top_size,
        size2=cut_top_size,
        h=safe_thickness + 0.2,
        anchor=BOTTOM
      );
}

module v2_component_reference(
  component,
  shell_size,
  row_spec,
  col_spec,
  grid_padding,
  default_cavity_height = 37,
  default_pot_height = 55,
  default_wall = 2,
  default_floor = 3,
  default_taper = 0,
  default_chamfer = 1,
  default_hole_rows = 2,
  default_hole_cols = 8,
  default_hole_diameter = 3,
  default_hole_padding = 14,
  show_fill_tube_reference = false
) {
  comp_type = v2_component_prop(component, "type", "pot");
  row = v2_component_prop(component, "row", 1);
  col = v2_component_prop(component, "col", 1);
  margin = v2_component_prop(component, "margin", 0);
  rim_w = v2_component_prop(component, "rim_w", comp_type == "pot" ? 4 : 0);
  rim_h = v2_component_prop(component, "rim_h", comp_type == "pot" ? 2 : 0);
  rim_chamfer = v2_component_prop(component, "rim_chamfer", 0.6);
  cavity_h = v2_component_prop(component, "cavity_h", default_cavity_height);
  insert_depth = v2_component_prop(component, "insert_depth", cavity_h);
  pot_h = v2_component_prop(component, "pot_h", default_pot_height);
  center = grid_cell_center(shell_size, row_spec, col_spec, row, col, grid_padding);
  cell_size = grid_cell_size(shell_size, row_spec, col_spec, row, col, grid_padding);
  size = [max(0.01, cell_size[0] - margin * 2), max(0.01, cell_size[1] - margin * 2)];
  body_size = [
    max(0.01, size[0] - rim_w * 2),
    max(0.01, size[1] - rim_w * 2)
  ];

  translate([center[0], center[1], 0])
    if (comp_type == "pot")
      Pot(
        top_size=body_size,
        h=pot_h,
        wall=default_wall,
        floor=default_floor,
        taper=default_taper,
        chamfer=default_chamfer,
        rim_width=rim_w,
        rim_height=rim_h,
        rim_z=insert_depth,
        rim_chamfer=rim_chamfer,
        hole_rows=default_hole_rows,
        hole_cols=default_hole_cols,
        hole_diameter=default_hole_diameter,
        hole_padding=default_hole_padding
      );
    else if (comp_type == "box")
      BoxContainer(
        top_size=size,
        h=cavity_h,
        wall=default_wall,
        floor=default_floor,
        chamfer=default_chamfer
      );
    else if (comp_type == "fill_tube" && show_fill_tube_reference)
      FillTubeReference(
        tube_w=v2_component_prop(component, "tube_w", min(size[0], 10)),
        tube_d=v2_component_prop(component, "tube_d", min(size[1], 10)),
        h=cavity_h,
        chamfer=default_chamfer
      );
}
