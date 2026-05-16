include <BOSL2/std.scad>

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
  seat_ledge_chamfer = 1.2
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

  }
}
