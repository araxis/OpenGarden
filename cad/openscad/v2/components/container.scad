include <BOSL2/std.scad>
include <props.scad>
include <../grid.scad>

module ReservoirContainer(
  top_size = [200, 100],
  bottom_size = [200, 100],
  h = 60,
  wall = 2,
  floor = 2.4,
  chamfer = 1,
  rounding = 0,
  seat_ledge_enabled = true,
  seat_ledge_drop = 3,
  seat_ledge_depth = 4,
  seat_ledge_thickness = 2,
  seat_ledge_chamfer = 1.2,
  pot_support_enabled = true,
  pot_support_clearance = 0.8,
  pot_support_margin = 8,
  pot_support_ring_width = 6,
  pot_support_chamfer = 1,
  components = [],
  shell_size = top_size,
  row_spec = "1*",
  col_spec = "1*",
  grid_padding = [0, 0, 0, 0],
  default_insert_depth = 37,
  default_taper = 0,
  default_rim_w = 3
) {
  eps = 0.04;
  safe_h = max(1, h);
  safe_wall = max(0.8, wall);
  safe_floor = min(max(0.8, floor), safe_h - 0.8);
  safe_chamfer = min(chamfer, safe_h / 4, min(top_size[0], top_size[1], bottom_size[0], bottom_size[1]) / 8);
  safe_rounding = min(rounding, min(top_size[0], top_size[1], bottom_size[0], bottom_size[1]) / 8);

  inner_top = [
    max(0.01, top_size[0] - safe_wall * 2),
    max(0.01, top_size[1] - safe_wall * 2)
  ];
  inner_bottom = [
    max(0.01, bottom_size[0] - safe_wall * 2),
    max(0.01, bottom_size[1] - safe_wall * 2)
  ];
  ledge_z = max(safe_floor + 0.4, min(safe_h - 0.4, safe_h - seat_ledge_drop - seat_ledge_thickness));
  ledge_h = max(0.6, min(seat_ledge_thickness, safe_h - ledge_z));
  ledge_outer = [
    max(0.01, inner_top[0]),
    max(0.01, inner_top[1])
  ];
  ledge_outer_bottom = [
    max(0.01, ledge_outer[0] - seat_ledge_chamfer * 2),
    max(0.01, ledge_outer[1] - seat_ledge_chamfer * 2)
  ];
  ledge_inner = [
    max(0.01, ledge_outer[0] - seat_ledge_depth * 2),
    max(0.01, ledge_outer[1] - seat_ledge_depth * 2)
  ];
  ledge_inner_bottom = [
    max(0.01, ledge_inner[0] + seat_ledge_chamfer * 2),
    max(0.01, ledge_inner[1] + seat_ledge_chamfer * 2)
  ];

  union() {
    difference() {
      prismoid(
        size1=bottom_size,
        size2=top_size,
        h=safe_h,
        chamfer=safe_chamfer,
        rounding=safe_rounding,
        anchor=BOTTOM
      );

      up(safe_floor)
        prismoid(
          size1=inner_bottom,
          size2=inner_top,
          h=max(0.01, safe_h - safe_floor) + 0.05,
          chamfer=min(safe_chamfer, safe_wall / 2),
          rounding=min(safe_rounding, safe_wall / 2),
          anchor=BOTTOM
        );
    }

    if (seat_ledge_enabled)
      up(ledge_z)
        difference() {
          prismoid(
            size1=ledge_outer_bottom,
            size2=ledge_outer,
            h=ledge_h,
            anchor=BOTTOM
          );
          down(eps / 2)
            prismoid(
              size1=[ledge_inner_bottom[0] + eps, ledge_inner_bottom[1] + eps],
              size2=[ledge_inner[0] + eps, ledge_inner[1] + eps],
              h=ledge_h + eps,
              anchor=BOTTOM
            );
        }

    if (pot_support_enabled)
      for (component = components)
        PotSupportPad(
          component=component,
          container_h=safe_h,
          floor=safe_floor,
          shell_size=shell_size,
          row_spec=row_spec,
          col_spec=col_spec,
          grid_padding=grid_padding,
          default_insert_depth=default_insert_depth,
          default_taper=default_taper,
          default_rim_w=default_rim_w,
          support_clearance=pot_support_clearance,
          support_margin=pot_support_margin,
          support_ring_width=pot_support_ring_width,
          support_chamfer=pot_support_chamfer
        );
  }
}

module PotSupportPad(
  component,
  container_h,
  floor,
  shell_size,
  row_spec,
  col_spec,
  grid_padding,
  default_insert_depth,
  default_taper,
  default_rim_w,
  support_clearance,
  support_margin,
  support_ring_width,
  support_chamfer
) {
  raw_type = v2_component_prop(component, "type", "pot_rect");
  comp_type = raw_type == "pot" ? "pot_rect" : raw_type;

  if (comp_type == "pot_rect" || comp_type == "pot_circle" || comp_type == "pot_oval") {
    row = v2_component_prop(component, "row", 1);
    col = v2_component_prop(component, "col", 1);
    margin = v2_component_prop(component, "margin", 0);
    rim_w = v2_component_prop(component, "rim_w", default_rim_w);
    taper = v2_component_prop(component, "taper", default_taper);
    insert_depth = v2_component_prop(component, "insert_depth", default_insert_depth);
    center = grid_cell_center(shell_size, row_spec, col_spec, row, col, grid_padding);
    cell_size = grid_cell_size(shell_size, row_spec, col_spec, row, col, grid_padding);
    top_size = [
      max(0.01, cell_size[0] - margin * 2 - rim_w * 2 - support_margin * 2),
      max(0.01, cell_size[1] - margin * 2 - rim_w * 2 - support_margin * 2)
    ];
    bottom_size = [
      max(0.01, top_size[0] - taper * 2),
      max(0.01, top_size[1] - taper * 2)
    ];
    support_top_z = container_h - insert_depth - support_clearance;
    support_eps = 0.04;
    support_z = floor - support_eps;
    support_h = max(0, support_top_z - support_z);
    ring_w = max(1, support_ring_width);
    inner_size = [
      max(0.01, bottom_size[0] - ring_w * 2),
      max(0.01, bottom_size[1] - ring_w * 2)
    ];
    inner_cut_size = [
      inner_size[0] + support_eps,
      inner_size[1] + support_eps
    ];
    inner_circle_d = max(0.01, min(bottom_size[0], bottom_size[1]) - ring_w * 2 + support_eps);

    if (support_h > 0.5)
      translate([center[0], center[1], support_z])
        if (comp_type == "pot_circle")
          difference() {
            cyl(
              d=max(0.01, min(bottom_size[0], bottom_size[1])),
              h=support_h,
              chamfer=min(support_chamfer, support_h / 3),
              anchor=BOTTOM
            );
            down(support_eps / 2)
              cyl(
                d=inner_circle_d,
                h=support_h + support_eps,
                anchor=BOTTOM
              );
          }
        else if (comp_type == "pot_oval")
          difference() {
            scale([max(0.01, bottom_size[0] / 2), max(0.01, bottom_size[1] / 2), 1])
              cyl(
                d=2,
                h=support_h,
                chamfer=min(support_chamfer, support_h / 3),
                anchor=BOTTOM
              );
            down(support_eps / 2)
              scale([max(0.01, inner_cut_size[0] / 2), max(0.01, inner_cut_size[1] / 2), 1])
                cyl(
                  d=2,
                  h=support_h + support_eps,
                  anchor=BOTTOM
                );
          }
        else
          difference() {
            prismoid(
              size1=bottom_size,
              size2=bottom_size,
              h=support_h,
              chamfer=min(support_chamfer, support_h / 3, min(bottom_size[0], bottom_size[1]) / 6),
              anchor=BOTTOM
            );
            down(support_eps / 2)
              prismoid(
                size1=inner_cut_size,
                size2=inner_cut_size,
                h=support_h + support_eps,
                anchor=BOTTOM
              );
          }
  }
}
