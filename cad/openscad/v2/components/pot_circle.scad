include <BOSL2/std.scad>

module PotCircleReference(
  diameter = 50,
  pot_h = 55,
  insert_depth = 37,
  wall = 2,
  floor = 3,
  taper = 0,
  rim_w = 3,
  rim_h = 3,
  rim_chamfer = 0.6,
  hole_rows = 2,
  hole_cols = 2,
  hole_diameter = 3,
  hole_padding = 10,
  geom_epsilon = 0.05
) {
  body_d_top = max(0.01, diameter - rim_w * 2);
  body_d_bottom = max(0.01, body_d_top - taper * 2);
  inner_d_top = max(0.01, body_d_top - wall * 2);
  inner_d_bottom = max(0.01, body_d_bottom - wall * 2);
  eps = max(0.001, geom_epsilon);
  safe_rim_z = min(max(0, insert_depth), pot_h);
  body_d_at_rim = PotCircleDiameterAtZ(body_d_bottom, body_d_top, pot_h, safe_rim_z);
  inner_d_at_rim = max(0.01, body_d_at_rim - wall * 2);
  rim_outer_d = max(0.01, body_d_at_rim + rim_w * 2);

  union() {
    difference() {
      cyl(d1=body_d_bottom, d2=body_d_top, h=pot_h, anchor=BOTTOM);
      up(floor - eps)
        cyl(d1=inner_d_bottom, d2=inner_d_top, h=max(0.01, pot_h - floor) + eps * 2, anchor=BOTTOM);
      PotCircleDrainHoles(
        diameter=max(0.01, inner_d_bottom),
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
        CircleRim(
          outer_d=rim_outer_d,
          base_d=body_d_at_rim,
          inner_d=inner_d_at_rim,
          h=rim_h + eps,
          chamfer=rim_chamfer,
          geom_epsilon=eps
        );
  }
}

module PotCircleCut(
  diameter = 50,
  shell_thickness = 3,
  fit_clearance = 0.4,
  taper = 0,
  insert_depth = 37,
  rim_w = 3,
  rim_h = 3,
  rim_chamfer = 0.6,
  cut_epsilon = 0.2
) {
  through_d = max(0.01, diameter - rim_w * 2);
  safe_t = max(0.5, shell_thickness);
  safe_clearance = max(0, fit_clearance);
  safe_eps = max(0.01, cut_epsilon);
  seat_depth = min(max(0, rim_h), safe_t);

  if (rim_w > 0 || rim_h > 0) {
    if (seat_depth > 0)
      up(safe_t - seat_depth - safe_eps)
        cyl(d1=max(0.01, through_d + safe_clearance * 2), d2=max(0.01, diameter + safe_clearance * 2), h=seat_depth + safe_eps * 3, anchor=BOTTOM);

    down(safe_eps)
      cyl(d=max(0.01, through_d + safe_clearance * 2), h=safe_t + safe_eps * 3, anchor=BOTTOM);
  } else {
    safe_insert = max(0.5, insert_depth);
    taper_at_cut_depth = taper * min(1, safe_t / safe_insert);
    d_top = max(0.01, through_d + safe_clearance * 2);
    d_bottom = max(0.01, through_d - taper_at_cut_depth * 2 + safe_clearance * 2);
    cyl(d1=d_bottom, d2=d_top, h=safe_t + 0.2, anchor=BOTTOM);
  }
}

module CircleRim(
  outer_d,
  base_d,
  inner_d,
  h,
  chamfer = 0.6,
  geom_epsilon = 0.05
) {
  eps = max(0.001, geom_epsilon);
  safe_h = max(0.2, h);
  safe_outer = max(0.01, outer_d);
  safe_base = max(0.01, min(base_d, safe_outer));
  safe_inner = max(0.01, min(inner_d, min(safe_base, safe_outer) - 0.8));
  safe_chamfer = min(max(0, chamfer), safe_h / 2, safe_outer / 8);
  shoulder_h = max(0.01, safe_h - safe_chamfer);
  top_outer = max(0.01, safe_outer - safe_chamfer * 2);
  inner_top = max(0.01, safe_inner + safe_chamfer * 2);

  difference() {
    union() {
      cyl(d1=safe_base, d2=safe_outer, h=shoulder_h, anchor=BOTTOM);

      if (safe_chamfer > 0)
        up(shoulder_h - eps)
          cyl(d1=safe_outer, d2=top_outer, h=safe_chamfer + eps, anchor=BOTTOM);
    }

    down(eps)
      cyl(d=safe_inner, h=safe_h + eps * 3, anchor=BOTTOM);

    if (safe_chamfer > 0)
      up(safe_h - safe_chamfer - eps)
        cyl(d1=safe_inner, d2=inner_top, h=safe_chamfer + eps * 3, anchor=BOTTOM);
  }
}

module PotCircleDrainHoles(diameter, floor, rows, cols, hole_d, padding, geom_epsilon = 0.05) {
  d = max(0.8, hole_d);
  eps = max(0.001, geom_epsilon);
  r = max(0, diameter / 2 - max(d * 2, diameter * 0.18));
  ring_count = max(6, floor((2 * PI * r) / max(d * 2.6, 8)));

  // Center drain
  translate([0, 0, -eps])
    cyl(d=d, h=floor + eps * 2, anchor=BOTTOM);

  // Ring drains (typical round nursery style)
  if (r > d * 0.8)
    for (i = [0:ring_count - 1]) {
      a = 360 * i / ring_count;
      translate([r * cos(a), r * sin(a), -eps])
        cyl(d=d, h=floor + eps * 2, anchor=BOTTOM);
    }
}

function PotCircleOffset(index, count, span) =
  count <= 1 ? 0 : -span / 2 + index * span / (count - 1);

function PotCircleDiameterAtZ(bottom_d, top_d, h, z) =
  let (t = h <= 0 ? 1 : min(max(0, z), h) / h)
    bottom_d + (top_d - bottom_d) * t;
