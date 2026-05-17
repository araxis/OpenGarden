include <BOSL2/std.scad>

module PotRoundRectReference(
  top_size = [180, 50],
  pot_h = 55,
  insert_depth = 37,
  wall = 2,
  floor = 3,
  taper = 0,
  chamfer = 0, // kept for pot-family API compatibility
  corner_radius = 12,
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
  safe_wall = min(max(0.4, wall), min(outer_top[0], outer_top[1], outer_bottom[0], outer_bottom[1]) / 3);
  inner_top = [
    max(0.01, outer_top[0] - safe_wall * 2),
    max(0.01, outer_top[1] - safe_wall * 2)
  ];
  inner_bottom = [
    max(0.01, outer_bottom[0] - safe_wall * 2),
    max(0.01, outer_bottom[1] - safe_wall * 2)
  ];
  safe_floor = max(0.4, floor);
  eps = max(0.001, geom_epsilon);
  safe_r = PotRoundRectRadius(outer_top, corner_radius);
  inner_r = PotRoundRectRadius(inner_top, safe_r - safe_wall);
  safe_rim_z = min(max(0, insert_depth), pot_h);
  body_at_rim = PotRoundRectSizeAtZ(outer_bottom, outer_top, pot_h, safe_rim_z);
  inner_at_rim = [
    max(0.01, body_at_rim[0] - safe_wall * 2),
    max(0.01, body_at_rim[1] - safe_wall * 2)
  ];
  rim_outer = [
    max(0.01, body_at_rim[0] + rim_w * 2),
    max(0.01, body_at_rim[1] + rim_w * 2)
  ];

  union() {
    difference() {
      RoundRectFrustum(outer_bottom, outer_top, pot_h, safe_r);

      up(safe_floor - eps)
        RoundRectFrustum(
          inner_bottom,
          inner_top,
          max(0.01, pot_h - safe_floor) + eps * 2,
          inner_r
        );

      PotRoundRectDrainHoles(
        size=inner_bottom,
        corner_radius=inner_r,
        floor=safe_floor,
        hole_d=hole_diameter,
        geom_epsilon=eps
      );
    }

    if (rim_w > 0 && rim_h > 0)
      up(safe_rim_z - eps)
        RoundRectRim(
          outer_size=rim_outer,
          base_size=body_at_rim,
          inner_size=inner_at_rim,
          h=rim_h + eps,
          corner_radius=safe_r + rim_w,
          chamfer=rim_chamfer,
          geom_epsilon=eps
        );
  }
}

module PotRoundRectCut(
  cut_size = [180, 50],
  shell_thickness = 3,
  fit_clearance = 0.4,
  taper = 0,
  insert_depth = 37,
  corner_radius = 12,
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
    RoundRectFrustum(bottom_sz, top_sz, safe_t + 0.2, PotRoundRectRadius(top_sz, safe_r));
  }
}

module PotRoundRectDrainHoles(size, corner_radius, floor, hole_d, geom_epsilon = 0.05) {
  d = max(0.8, hole_d);
  eps = max(0.001, geom_epsilon);
  inset_x = max(d * 1.6, size[0] * 0.16);
  inset_y = max(d * 1.6, size[1] * 0.18);
  usable_x = max(0, size[0] - inset_x * 2);
  usable_y = max(0, size[1] - inset_y * 2);
  edge_x = max(0, usable_x / 2);
  pitch = max(d * 2.6, 8);
  count_y = max(3, floor(usable_y / pitch) + 1);

  translate([0, 0, -eps])
    cyl(d=d, h=floor + eps * 2, anchor=BOTTOM);

  if (edge_x > d * 0.9)
    for (i = [0:count_y - 1]) {
      y = PotRoundRectHoleOffset(i, count_y, usable_y);
      translate([-edge_x, y, -eps])
        cyl(d=d, h=floor + eps * 2, anchor=BOTTOM);
      translate([ edge_x, y, -eps])
        cyl(d=d, h=floor + eps * 2, anchor=BOTTOM);
    }
}

module RoundRectRim(
  outer_size = [60, 30],
  base_size = [54, 24],
  inner_size = [50, 20],
  h = 3,
  corner_radius = 8,
  chamfer = 0.6,
  geom_epsilon = 0.05
) {
  safe_h = max(0.2, h);
  eps = max(0.001, geom_epsilon);
  safe_outer = [max(0.01, outer_size[0]), max(0.01, outer_size[1])];
  safe_base = [
    max(0.01, min(base_size[0], safe_outer[0])),
    max(0.01, min(base_size[1], safe_outer[1]))
  ];
  safe_inner = [
    max(0.01, min(inner_size[0], min(safe_base[0], safe_outer[0]) - 0.8)),
    max(0.01, min(inner_size[1], min(safe_base[1], safe_outer[1]) - 0.8))
  ];
  difference() {
    RoundRectFrustum(
      safe_base,
      safe_outer,
      safe_h,
      PotRoundRectRadius(safe_outer, corner_radius)
    );

    down(eps)
      RoundRectPrism(
        safe_inner,
        safe_h + eps * 3,
        PotRoundRectRadius(safe_inner, corner_radius - (safe_outer[0] - safe_inner[0]) / 2)
      );
  }
}

module RoundRectPrism(size = [60, 30], h = 10, corner_radius = 6) {
  linear_extrude(height=max(0.01, h), center=false)
    rect(size, rounding=PotRoundRectRadius(size, corner_radius), anchor=CENTER, $fn=max($fn, 24));
}

module RoundRectFrustum(size1 = [50, 25], size2 = [60, 30], h = 10, corner_radius = 6) {
  safe1 = [max(0.01, size1[0]), max(0.01, size1[1])];
  safe2 = [max(0.01, size2[0]), max(0.01, size2[1])];
  linear_extrude(height=max(0.01, h), scale=[safe2[0] / safe1[0], safe2[1] / safe1[1]], center=false)
    rect(safe1, rounding=PotRoundRectRadius(safe1, corner_radius), anchor=CENTER, $fn=max($fn, 24));
}

function PotRoundRectRadius(size, corner_radius) =
  max(0, min(corner_radius, min(size[0], size[1]) / 2 - 0.01));

function PotRoundRectHoleOffset(index, count, span) =
  count <= 1 ? 0 : -span / 2 + index * span / (count - 1);

function PotRoundRectSizeAtZ(bottom_size, top_size, h, z) =
  let (t = h <= 0 ? 1 : min(max(0, z), h) / h)
    [
      bottom_size[0] + (top_size[0] - bottom_size[0]) * t,
      bottom_size[1] + (top_size[1] - bottom_size[1]) * t
    ];
