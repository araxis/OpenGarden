include <BOSL2/std.scad>

module RectRim(
  outer_size = [60, 30],
  base_size = undef,
  inner_size = [52, 22],
  h = 2,
  chamfer = 0.6
) {
  safe_h = max(0.2, h);
  safe_outer = [max(0.01, outer_size[0]), max(0.01, outer_size[1])];
  safe_base = base_size == undef
    ? safe_outer
    : [
        max(0.01, min(base_size[0], safe_outer[0])),
        max(0.01, min(base_size[1], safe_outer[1]))
      ];
  safe_inner = [
    max(0.01, min(inner_size[0], min(safe_base[0], safe_outer[0]) - 0.8)),
    max(0.01, min(inner_size[1], min(safe_base[1], safe_outer[1]) - 0.8))
  ];
  safe_chamfer = min(chamfer, safe_h / 2, min(safe_outer[0], safe_outer[1]) / 8);

  difference() {
    prismoid(
      size1=safe_base,
      size2=safe_outer,
      h=safe_h,
      chamfer=safe_chamfer,
      anchor=BOTTOM
    );

    down(0.05)
      prismoid(
        size1=safe_inner,
        size2=safe_inner,
        h=safe_h + 0.1,
        chamfer=min(safe_chamfer, min(safe_inner[0], safe_inner[1]) / 8),
        anchor=BOTTOM
      );
  }
}

module RectSeatCut(
  outer_size = [60, 30],
  through_size = [52, 22],
  shell_thickness = 3,
  seat_depth = 1.2,
  fit_clearance = 0.4,
  chamfer = 0.6,
  cut_epsilon = 0.2
) {
  safe_thickness = max(0.5, shell_thickness);
  safe_seat_depth = min(max(0, seat_depth), safe_thickness);
  safe_clearance = max(0, fit_clearance);
  safe_epsilon = max(0.01, cut_epsilon);
  safe_outer = [
    max(0.01, outer_size[0] + safe_clearance * 2),
    max(0.01, outer_size[1] + safe_clearance * 2)
  ];
  safe_through = [
    max(0.01, through_size[0] + safe_clearance * 2),
    max(0.01, through_size[1] + safe_clearance * 2)
  ];
  safe_chamfer = min(chamfer, safe_thickness / 2, min(safe_outer[0], safe_outer[1]) / 8);

  if (safe_seat_depth > 0)
    up(safe_thickness - safe_seat_depth - safe_epsilon)
      prismoid(
        size1=safe_through,
        size2=safe_outer,
        h=safe_seat_depth + safe_epsilon * 3,
        chamfer=safe_chamfer,
        anchor=BOTTOM
      );

  down(safe_epsilon)
    prismoid(
      size1=safe_through,
      size2=safe_through,
      h=safe_thickness + safe_epsilon * 3,
      chamfer=min(safe_chamfer, min(safe_through[0], safe_through[1]) / 8),
      anchor=BOTTOM
    );
}
