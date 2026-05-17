include <props.scad>
include <rim.scad>
include <pot.scad>
include <pot_rect.scad>
include <pot_roundrect.scad>
include <pot_circle.scad>
include <pot_oval.scad>
include <box.scad>
include <fill_tube.scad>
include <../grid.scad>

function v2_odd_count(n) = max(1, n % 2 == 0 ? n + 1 : n);
function v2_is_pot_component(comp_type) =
  comp_type == "pot_rect" || comp_type == "pot_roundrect" || comp_type == "pot_circle" || comp_type == "pot_oval";

module v2_component_cut(
  component,
  shell_size,
  row_spec,
  col_spec,
  grid_padding,
  default_taper,
  default_cavity_height,
  default_clearance,
  default_cut_epsilon,
  shell_thickness
) {
  raw_type = v2_component_prop(component, "type", "pot_rect");
  comp_type = raw_type == "pot" ? "pot_rect" : raw_type;
  row = v2_component_prop(component, "row", 1);
  col = v2_component_prop(component, "col", 1);
  row_span = v2_component_prop(component, "row_span", 1);
  col_span = v2_component_prop(component, "col_span", 1);
  fit_clearance = v2_component_prop(component, "clearance", default_clearance);
  cavity_height = v2_component_prop(component, "cavity_h", default_cavity_height);
  insert_depth = v2_component_prop(component, "insert_depth", cavity_height);
  taper = v2_component_prop(component, "taper", default_taper);
  margin = v2_component_prop(component, "margin", 0);
  corner_radius = v2_component_prop(component, "corner_radius", 12);
  rim_w = v2_component_prop(component, "rim_w", v2_is_pot_component(comp_type) ? 4 : 0);
  rim_h = v2_component_prop(component, "rim_h", v2_is_pot_component(comp_type) ? 2 : 0);
  rim_chamfer = v2_component_prop(component, "rim_chamfer", 0.6);
  cut_epsilon = v2_component_prop(component, "cut_epsilon", default_cut_epsilon);
  geom_epsilon = v2_component_prop(component, "geom_epsilon", 0.05);
  tube_w = v2_component_prop(component, "tube_w", 8);
  tube_d = v2_component_prop(component, "tube_d", 8);

  center = grid_cell_span_center(shell_size, row_spec, col_spec, row, col, row_span, col_span, grid_padding);
  cell_size = grid_cell_span_size(shell_size, row_spec, col_spec, row, col, row_span, col_span, grid_padding);
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
  safe_cavity_height = max(0.5, v2_is_pot_component(comp_type) ? insert_depth : cavity_height);
  taper_at_cut_depth = taper * min(1, safe_thickness / safe_cavity_height);
  cut_top_size = [
    max(0.01, through_size[0] + safe_clearance * 2),
    max(0.01, through_size[1] + safe_clearance * 2)
  ];
  cut_bottom_size = [
    max(0.01, through_size[0] - taper_at_cut_depth * 2 + safe_clearance * 2),
    max(0.01, through_size[1] - taper_at_cut_depth * 2 + safe_clearance * 2)
  ];

  translate([center[0], center[1], -cut_epsilon])
    if (comp_type == "fill_tube")
      FillTubeCut(
        tube_w=tube_w,
        tube_d=tube_d,
        fit_clearance=fit_clearance,
        shell_thickness=safe_thickness
      );
    else if (comp_type == "pot_rect")
      PotRectCut(
        cut_size=size,
        shell_thickness=safe_thickness,
        fit_clearance=fit_clearance,
        taper=taper,
        insert_depth=insert_depth,
        rim_w=rim_w,
        rim_h=rim_h,
        rim_chamfer=rim_chamfer,
        cut_epsilon=cut_epsilon
      );
    else if (comp_type == "pot_roundrect")
      PotRoundRectCut(
        cut_size=size,
        shell_thickness=safe_thickness,
        fit_clearance=fit_clearance,
        taper=taper,
        insert_depth=insert_depth,
        corner_radius=corner_radius,
        rim_w=rim_w,
        rim_h=rim_h,
        rim_chamfer=rim_chamfer,
        cut_epsilon=cut_epsilon
      );
    else if (comp_type == "pot_circle")
      PotCircleCut(
        diameter=min(size[0], size[1]),
        shell_thickness=safe_thickness,
        fit_clearance=fit_clearance,
        taper=taper,
        insert_depth=insert_depth,
        rim_w=rim_w,
        rim_h=rim_h,
        rim_chamfer=rim_chamfer,
        cut_epsilon=cut_epsilon
      );
    else if (comp_type == "pot_oval")
      PotOvalCut(
        cut_size=size,
        shell_thickness=safe_thickness,
        fit_clearance=fit_clearance,
        taper=taper,
        insert_depth=insert_depth,
        rim_w=rim_w,
        rim_h=rim_h,
        rim_chamfer=rim_chamfer,
        cut_epsilon=cut_epsilon
      );
    else if (comp_type == "box")
      BoxContainerCut(
        cut_size=size,
        shell_thickness=safe_thickness,
        fit_clearance=fit_clearance,
        insert_depth=insert_depth,
        corner_radius=corner_radius,
        rim_w=rim_w,
        rim_h=rim_h,
        rim_chamfer=rim_chamfer,
        cut_epsilon=cut_epsilon
      );
    else
      prismoid(
        size1=v2_is_pot_component(comp_type) ? cut_bottom_size : cut_top_size,
        size2=cut_top_size,
        h=safe_thickness + cut_epsilon * 2,
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
  raw_type = v2_component_prop(component, "type", "pot_rect");
  comp_type = raw_type == "pot" ? "pot_rect" : raw_type;
  row = v2_component_prop(component, "row", 1);
  col = v2_component_prop(component, "col", 1);
  row_span = v2_component_prop(component, "row_span", 1);
  col_span = v2_component_prop(component, "col_span", 1);
  margin = v2_component_prop(component, "margin", 0);
  corner_radius = v2_component_prop(component, "corner_radius", 12);
  rim_w = v2_component_prop(component, "rim_w", v2_is_pot_component(comp_type) ? 4 : 0);
  rim_h = v2_component_prop(component, "rim_h", v2_is_pot_component(comp_type) ? 2 : 0);
  rim_chamfer = v2_component_prop(component, "rim_chamfer", 0.6);
  geom_epsilon = v2_component_prop(component, "geom_epsilon", 0.05);
  cavity_h = v2_component_prop(component, "cavity_h", default_cavity_height);
  insert_depth = v2_component_prop(component, "insert_depth", cavity_h);
  pot_h = v2_component_prop(component, "pot_h", default_pot_height);
  center = grid_cell_span_center(shell_size, row_spec, col_spec, row, col, row_span, col_span, grid_padding);
  cell_size = grid_cell_span_size(shell_size, row_spec, col_spec, row, col, row_span, col_span, grid_padding);
  size = [max(0.01, cell_size[0] - margin * 2), max(0.01, cell_size[1] - margin * 2)];
  body_size = [
    max(0.01, size[0] - rim_w * 2),
    max(0.01, size[1] - rim_w * 2)
  ];

  translate([center[0], center[1], 0])
    if (comp_type == "pot_rect")
      PotRectReference(
        top_size=size,
        pot_h=pot_h,
        insert_depth=insert_depth,
        wall=default_wall,
        floor=default_floor,
        taper=default_taper,
        chamfer=default_chamfer,
        rim_w=rim_w,
        rim_h=rim_h,
        rim_chamfer=rim_chamfer,
        hole_rows=default_hole_rows,
        hole_cols=default_hole_cols,
        hole_diameter=default_hole_diameter,
        hole_padding=default_hole_padding
      );
    else if (comp_type == "pot_roundrect")
      render(convexity=12)
        PotRoundRectReference(
          top_size=size,
          pot_h=pot_h,
          insert_depth=insert_depth,
          wall=default_wall,
          floor=default_floor,
          taper=default_taper,
          chamfer=default_chamfer,
          corner_radius=corner_radius,
          rim_w=rim_w,
          rim_h=rim_h,
          rim_chamfer=rim_chamfer,
          geom_epsilon=geom_epsilon,
          hole_rows=default_hole_rows,
          hole_cols=default_hole_cols,
          hole_diameter=default_hole_diameter,
          hole_padding=default_hole_padding
        );
    else if (comp_type == "pot_circle")
      render(convexity=12)
        PotCircleReference(
          diameter=min(size[0], size[1]),
          pot_h=pot_h,
          insert_depth=insert_depth,
          wall=default_wall,
          floor=default_floor,
          taper=default_taper,
          rim_w=rim_w,
          rim_h=rim_h,
          rim_chamfer=rim_chamfer,
          geom_epsilon=geom_epsilon,
          hole_rows=v2_odd_count(default_hole_rows),
          hole_cols=v2_odd_count(default_hole_cols),
          hole_diameter=default_hole_diameter,
          hole_padding=default_hole_padding
        );
    else if (comp_type == "pot_oval")
      render(convexity=12)
        PotOvalReference(
          top_size=size,
          pot_h=pot_h,
          insert_depth=insert_depth,
          wall=default_wall,
          floor=default_floor,
          taper=default_taper,
          chamfer=default_chamfer,
          rim_w=rim_w,
          rim_h=rim_h,
          rim_chamfer=rim_chamfer,
          geom_epsilon=geom_epsilon,
          hole_rows=v2_odd_count(default_hole_rows),
          hole_cols=v2_odd_count(default_hole_cols),
          hole_diameter=default_hole_diameter,
          hole_padding=default_hole_padding
        );
    else if (comp_type == "box")
      render(convexity=12)
        BoxContainer(
          top_size=size,
          h=cavity_h,
          wall=default_wall,
          floor=default_floor,
          chamfer=default_chamfer,
          corner_radius=corner_radius,
          rim_w=rim_w,
          rim_h=rim_h,
          rim_chamfer=rim_chamfer,
          insert_depth=insert_depth,
          geom_epsilon=geom_epsilon
        );
    else if (comp_type == "fill_tube" && show_fill_tube_reference)
      FillTubeReference(
        tube_w=v2_component_prop(component, "tube_w", min(size[0], 10)),
        tube_d=v2_component_prop(component, "tube_d", min(size[1], 10)),
        h=cavity_h,
        chamfer=default_chamfer
      );
}
