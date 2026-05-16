include <BOSL2/std.scad>
include <pot_roundrect.scad>

module BoxContainer(
  top_size = [180, 50],
  h = 25,
  wall = 2,
  floor = 3,
  chamfer = 0, // kept for API compatibility; not used in roundrect primitive
  corner_radius = 0,
  rim_w = 0,
  rim_h = 0,
  rim_chamfer = 0.6,
  insert_depth = undef,
  geom_epsilon = 0.05
) {
  outer_size = [max(0.01, top_size[0]), max(0.01, top_size[1])];
  safe_wall = min(max(0.4, wall), min(outer_size[0], outer_size[1]) / 3);
  safe_floor = max(0.4, floor);
  inner_size = [
    max(0.01, outer_size[0] - safe_wall * 2),
    max(0.01, outer_size[1] - safe_wall * 2)
  ];
  eps = max(0.001, geom_epsilon);
  safe_r = PotRoundRectRadius(outer_size, corner_radius);
  inner_r = PotRoundRectRadius(inner_size, safe_r - safe_wall);
  safe_rim_z = min(max(0, insert_depth == undef ? h : insert_depth), h);
  rim_outer = [
    max(0.01, outer_size[0] + rim_w * 2),
    max(0.01, outer_size[1] + rim_w * 2)
  ];

  union() {
    difference() {
      RoundRectFrustum(outer_size, outer_size, h, safe_r);

      up(safe_floor - eps)
        RoundRectFrustum(
          inner_size,
          inner_size,
          max(0.01, h - safe_floor) + eps * 2,
          inner_r
        );
    }

    if (rim_w > 0 && rim_h > 0)
      up(safe_rim_z - eps)
        RoundRectRim(
          outer_size=rim_outer,
          base_size=outer_size,
          inner_size=inner_size,
          h=rim_h + eps,
          corner_radius=safe_r + rim_w,
          chamfer=rim_chamfer,
          geom_epsilon=eps
        );
  }
}

module BoxContainerCut(
  cut_size = [180, 50],
  shell_thickness = 3,
  fit_clearance = 0.4,
  insert_depth = 37,
  corner_radius = 0,
  rim_w = 0,
  rim_h = 0,
  rim_chamfer = 0.6,
  cut_epsilon = 0.2
) {
  through = [
    max(0.01, cut_size[0] - rim_w * 2),
    max(0.01, cut_size[1] - rim_w * 2)
  ];
  safe_t = max(0.5, shell_thickness);
  safe_clearance = max(0, fit_clearance);
  eps = max(0.01, cut_epsilon);
  seat_depth = min(max(0, rim_h), safe_t);
  safe_r = PotRoundRectRadius(cut_size, corner_radius);

  seat_outer = [
    max(0.01, cut_size[0] + safe_clearance * 2),
    max(0.01, cut_size[1] + safe_clearance * 2)
  ];
  seat_through = [
    max(0.01, through[0] + safe_clearance * 2),
    max(0.01, through[1] + safe_clearance * 2)
  ];

  if (rim_w > 0 || rim_h > 0) {
    if (seat_depth > 0)
      up(safe_t - seat_depth - eps)
        RoundRectFrustum(
          seat_through,
          seat_outer,
          seat_depth + eps * 3,
          PotRoundRectRadius(seat_outer, safe_r + safe_clearance)
        );

    down(eps)
      RoundRectPrism(
        seat_through,
        safe_t + eps * 3,
        PotRoundRectRadius(seat_through, safe_r - rim_w + safe_clearance)
      );
  } else {
    cut_top_size = [
      max(0.01, through[0] + safe_clearance * 2),
      max(0.01, through[1] + safe_clearance * 2)
    ];
    RoundRectPrism(cut_top_size, safe_t + 0.2, PotRoundRectRadius(cut_top_size, safe_r));
  }
}
