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
  support_deck_enabled = false,
  support_deck_clearance = 0.8,
  support_deck_rail_width = 3,
  support_deck_rail_gap = 7,
  support_deck_side_gap = 8,
  support_deck_chamfer = 0.6,
  support_deck_foot = 2.5,
  support_deck_embed = 0.6,
  components = [],
  shell_size = top_size,
  row_spec = "1*",
  col_spec = "1*",
  grid_padding = [0, 0, 0, 0],
  default_insert_depth = 37
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

    if (support_deck_enabled)
      if (len(components) > 0)
        for (component = components)
          ComponentSupportDeckSlats(
            component=component,
            container_h=safe_h,
            floor=safe_floor,
            shell_size=shell_size,
            row_spec=row_spec,
            col_spec=col_spec,
            grid_padding=grid_padding,
            default_insert_depth=default_insert_depth,
            support_clearance=support_deck_clearance,
            rail_width=support_deck_rail_width,
            rail_gap=support_deck_rail_gap,
            side_gap=support_deck_side_gap,
            chamfer=support_deck_chamfer,
            foot=support_deck_foot,
            embed=support_deck_embed,
            eps=eps
          );
      else
        SupportDeckSlats(
          container_h=safe_h,
          floor=safe_floor,
          inner_size=[
            min(inner_top[0], inner_bottom[0]),
            min(inner_top[1], inner_bottom[1])
          ],
          insert_depth=default_insert_depth,
          support_clearance=support_deck_clearance,
          rail_width=support_deck_rail_width,
          rail_gap=support_deck_rail_gap,
          side_gap=support_deck_side_gap,
          chamfer=support_deck_chamfer,
          foot=support_deck_foot,
          embed=support_deck_embed,
          eps=eps
        );
  }
}

module SupportDeckSlats(
  container_h,
  floor,
  inner_size,
  insert_depth,
  support_clearance,
  rail_width,
  rail_gap,
  side_gap,
  chamfer,
  foot,
  embed,
  eps
) {
  // Fallback full-width deck when no component list is supplied.
  SupportDeckZone(
    center=[0, 0],
    size=inner_size,
    container_h=container_h,
    floor=floor,
    insert_depth=insert_depth,
    support_clearance=support_clearance,
    rail_width=rail_width,
    rail_gap=rail_gap,
    side_gap=side_gap,
    chamfer=chamfer,
    foot=foot,
    embed=embed,
    eps=eps
  );
}

module ComponentSupportDeckSlats(
  component,
  container_h,
  floor,
  shell_size,
  row_spec,
  col_spec,
  grid_padding,
  default_insert_depth,
  support_clearance,
  rail_width,
  rail_gap,
  side_gap,
  chamfer,
  foot,
  embed,
  eps
) {
  raw_type = v2_component_prop(component, "type", "pot_rect");
  comp_type = raw_type == "pot" ? "pot_rect" : raw_type;

  if (comp_type != "fill_tube") {
    row = v2_component_prop(component, "row", 1);
    col = v2_component_prop(component, "col", 1);
    margin = v2_component_prop(component, "margin", 0);
    center = grid_cell_center(shell_size, row_spec, col_spec, row, col, grid_padding);
    cell_size = grid_cell_size(shell_size, row_spec, col_spec, row, col, grid_padding);
    zone_size = [
      max(0.01, cell_size[0] - margin * 2),
      max(0.01, cell_size[1] - margin * 2)
    ];

    SupportDeckZone(
      center=center,
      size=zone_size,
      container_h=container_h,
      floor=floor,
      insert_depth=default_insert_depth,
      support_clearance=support_clearance,
      rail_width=rail_width,
      rail_gap=rail_gap,
      side_gap=side_gap,
      chamfer=chamfer,
      foot=foot,
      embed=embed,
      eps=eps
    );
  }
}

module SupportDeckZone(
  center,
  size,
  container_h,
  floor,
  insert_depth,
  support_clearance,
  rail_width,
  rail_gap,
  side_gap,
  chamfer,
  foot,
  embed,
  eps
) {
  deck_top_z = container_h - insert_depth - support_clearance;
  safe_embed = max(0, embed);
  rail_z = floor - max(eps, safe_embed);
  rail_h = max(0, deck_top_z - rail_z);
  usable_x = max(0.01, size[0] - side_gap * 2 + safe_embed * 2);
  usable_y = max(0.01, size[1] - side_gap * 2);
  foot_size = max(0, foot);
  foot_h = min(foot_size, rail_h);
  pitch = max(0.1, rail_width + rail_gap);
  rail_count = max(1, floor((usable_y + rail_gap) / pitch));
  total_rails_y = rail_count * rail_width + max(0, rail_count - 1) * rail_gap;
  start_y = -total_rails_y / 2 + rail_width / 2;

  if (rail_h > 0.5)
    translate([center[0], center[1], 0])
      for (i = [0:rail_count - 1])
        translate([0, start_y + i * pitch, rail_z])
          FusedSupportRail(
            length=usable_x,
            width=rail_width,
            h=rail_h,
            foot=foot_size,
            embed=safe_embed,
            chamfer=chamfer
          );
}

module FusedSupportRail(length, width, h, foot, embed, chamfer) {
  shoe_h = min(max(1, foot * 0.55), h * 0.25);
  shoe_width = width + foot * 2;
  rail_chamfer = min(chamfer, width / 3, h / 3);
  shoe_chamfer = min(chamfer, shoe_h / 3, shoe_width / 4);
  top_web = max(width, 2);
  arch_r = max(0.01, min(length / 2 - foot, h - shoe_h - top_web));
  arch_z = shoe_h - arch_r * 0.35;

  union() {
    cuboid(
      [length, shoe_width, shoe_h],
      chamfer=shoe_chamfer,
      anchor=BOTTOM
    );

    difference() {
      cuboid(
        [length, width, h],
        chamfer=rail_chamfer,
        anchor=BOTTOM
      );

      translate([0, 0, arch_z])
        rotate([90, 0, 0])
          cylinder(r=arch_r, h=width + 0.2, center=true);
    }
  }
}
