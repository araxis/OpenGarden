include <BOSL2/std.scad>

module PotOvalReference(
  top_size = [180, 50],
  pot_h = 55,
  insert_depth = 37,
  wall = 2,
  floor = 3,
  taper = 0,
  chamfer = 0, // kept for API compatibility; not used in oval primitive
  rim_w = 3,
  rim_h = 3,
  rim_chamfer = 0.6,
  hole_rows = 2,
  hole_cols = 8,
  hole_diameter = 3,
  hole_padding = 14,
  geom_epsilon = 0.05
) {
  outer_top = [max(0.01, top_size[0]), max(0.01, top_size[1])];
  outer_bottom = [
    max(0.01, outer_top[0] - taper * 2),
    max(0.01, outer_top[1] - taper * 2)
  ];
  inner_top = [
    max(0.01, outer_top[0] - wall * 2),
    max(0.01, outer_top[1] - wall * 2)
  ];
  inner_bottom = [
    max(0.01, outer_bottom[0] - wall * 2),
    max(0.01, outer_bottom[1] - wall * 2)
  ];
  eps = max(0.001, geom_epsilon);
  safe_rim_z = min(max(0, insert_depth), pot_h);
  body_at_rim = PotOvalSizeAtZ(outer_bottom, outer_top, pot_h, safe_rim_z);
  inner_at_rim = [
    max(0.01, body_at_rim[0] - wall * 2),
    max(0.01, body_at_rim[1] - wall * 2)
  ];
  rim_outer = [
    max(0.01, body_at_rim[0] + rim_w * 2),
    max(0.01, body_at_rim[1] + rim_w * 2)
  ];

  union() {
    difference() {
      OvalFrustum(outer_bottom, outer_top, pot_h);

      up(floor - eps)
        OvalFrustum(
          inner_bottom,
          inner_top,
          max(0.01, pot_h - floor) + eps * 2
        );

      PotOvalDrainHoles(
        size=inner_bottom,
        floor=floor,
        rows=hole_rows,
        cols=hole_cols,
        hole_d=hole_diameter,
        padding=hole_padding,
        geom_epsilon=eps
      );
    }

    if (rim_w > 0 && rim_h > 0)
      up(safe_rim_z - eps)
        OvalRim(
          outer_size=rim_outer,
          base_size=body_at_rim,
          inner_size=inner_at_rim,
          h=rim_h + eps,
          chamfer=rim_chamfer,
          geom_epsilon=eps
        );
  }
}

module PotOvalCut(
  cut_size = [180, 50],
  shell_thickness = 3,
  fit_clearance = 0.4,
  taper = 0,
  insert_depth = 37,
  rim_w = 3,
  rim_h = 3,
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
        OvalFrustum(
          seat_through,
          seat_outer,
          seat_depth + eps * 3
        );

    down(eps)
      OvalPrism(
        seat_through,
        safe_t + eps * 3
      );
  } else {
    safe_insert = max(0.5, insert_depth);
    taper_at_cut_depth = taper * min(1, safe_t / safe_insert);
    top_sz = [
      max(0.01, through[0] + safe_clearance * 2),
      max(0.01, through[1] + safe_clearance * 2)
    ];
    bottom_sz = [
      max(0.01, through[0] - taper_at_cut_depth * 2 + safe_clearance * 2),
      max(0.01, through[1] - taper_at_cut_depth * 2 + safe_clearance * 2)
    ];
    OvalFrustum(bottom_sz, top_sz, safe_t + 0.2);
  }
}

module OvalRim(
  outer_size = [50, 30],
  base_size = [44, 24],
  inner_size = [40, 20],
  h = 3,
  chamfer = 0.6,
  geom_epsilon = 0.05
) {
  eps = max(0.001, geom_epsilon);
  safe_h = max(0.2, h);
  safe_outer = [max(0.01, outer_size[0]), max(0.01, outer_size[1])];
  safe_base = [
    max(0.01, min(base_size[0], safe_outer[0])),
    max(0.01, min(base_size[1], safe_outer[1]))
  ];
  safe_inner = [
    max(0.01, min(inner_size[0], min(safe_base[0], safe_outer[0]) - 0.8)),
    max(0.01, min(inner_size[1], min(safe_base[1], safe_outer[1]) - 0.8))
  ];
  safe_chamfer = min(max(0, chamfer), safe_h / 2, min(safe_outer[0], safe_outer[1]) / 8);
  shoulder_h = max(0.01, safe_h - safe_chamfer);
  top_outer = safe_chamfer > 0
    ? [
        max(0.01, safe_outer[0] - safe_chamfer * 2),
        max(0.01, safe_outer[1] - safe_chamfer * 2)
      ]
    : safe_outer;
  inner_top = safe_chamfer > 0
    ? [
        max(0.01, safe_inner[0] + safe_chamfer * 2),
        max(0.01, safe_inner[1] + safe_chamfer * 2)
      ]
    : safe_inner;

  difference() {
    union() {
      OvalFrustum(safe_base, safe_outer, shoulder_h);

      if (safe_chamfer > 0)
        up(shoulder_h - eps)
          OvalFrustum(safe_outer, top_outer, safe_chamfer + eps);
    }

    down(eps)
      OvalPrism(safe_inner, safe_h + eps * 3);

    if (safe_chamfer > 0)
      up(safe_h - safe_chamfer - eps)
        OvalFrustum(safe_inner, inner_top, safe_chamfer + eps * 3);
  }
}

module PotOvalDrainHoles(size, floor, rows, cols, hole_d, padding, geom_epsilon = 0.05) {
  d = max(0.8, hole_d);
  eps = max(0.001, geom_epsilon);
  rx = max(0, size[0] / 2 - max(d * 2, size[0] * 0.14));
  ry = max(0, size[1] / 2 - max(d * 2, size[1] * 0.14));
  perim_est = PI * (3 * (rx + ry) - sqrt(max(0.01, (3 * rx + ry) * (rx + 3 * ry))));
  ring_count = max(8, floor(perim_est / max(d * 2.6, 8)));

  // Center drain
  translate([0, 0, -eps])
    cyl(d=d, h=floor + eps * 2, anchor=BOTTOM);

  // Ring drains (typical oval pot style)
  if (rx > d * 0.8 && ry > d * 0.8)
    for (i = [0:ring_count - 1]) {
      a = 360 * i / ring_count;
      translate([rx * cos(a), ry * sin(a), -eps])
        cyl(d=d, h=floor + eps * 2, anchor=BOTTOM);
    }
}

module OvalPrism(size = [50, 30], h = 10) {
  sx = max(0.01, size[0] / 2);
  sy = max(0.01, size[1] / 2);
  scale([sx, sy, 1])
    cyl(d=2, h=h, anchor=BOTTOM, $fn=max($fn, 24));
}

module OvalFrustum(size1 = [45, 25], size2 = [50, 30], h = 10) {
  sx1 = max(0.01, size1[0] / 2);
  sy1 = max(0.01, size1[1] / 2);
  sx2 = max(0.01, size2[0] / 2);
  sy2 = max(0.01, size2[1] / 2);
  linear_extrude(height=h, scale=[sx2 / sx1, sy2 / sy1], center=false)
    scale([sx1, sy1])
      circle(d=2, $fn=max($fn, 24));
}

function PotOvalOffset(index, count, span) =
  count <= 1 ? 0 : -span / 2 + index * span / (count - 1);

function PotOvalSizeAtZ(bottom_size, top_size, h, z) =
  let (t = h <= 0 ? 1 : min(max(0, z), h) / h)
    [
      bottom_size[0] + (top_size[0] - bottom_size[0]) * t,
      bottom_size[1] + (top_size[1] - bottom_size[1]) * t
    ];
