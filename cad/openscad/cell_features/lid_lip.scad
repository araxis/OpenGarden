include <BOSL2/std.scad>

// feature_lid_lip
//
// Recesses the top of a cell to form a seat. The cut takes up to `width`
// material from each wall (clamped per-side by the caller via max_*),
// going down `depth` from the cell top.
//
// Geometry: single cuboid sized cell + per-side bleed, anchored TOP.
// Subtracted from the assembly by pot_insert.scad's diff("lid_lip").
//
// Per-side bleeds (max_left/right/front/back) are how much wall material
// the caller permits the cut to consume on each side:
//   - interior dividers: divider / 2 (other half stays for the neighbor)
//   - outer walls:       wallThickness
//
// Known limitation: the cut is a plain cuboid and does not currently
// account for chamfered corners (frontChamfer / chamferBackSide). On
// chamfered corner cells a thin artifact line appears where the cut
// floor meets the chamfer face. This is tracked for the upcoming
// cell-features refactor (centralized cell_context).
module feature_lid_lip(
  cell_w, cell_d,
  depth = 2, width = 1.0,
  max_left = 0, max_right = 0, max_front = 0, max_back = 0
) {
  safe_depth = max(0.1, depth);
  left_bleed  = min(max(0, width), max(0, max_left));
  right_bleed = min(max(0, width), max(0, max_right));
  front_bleed = min(max(0, width), max(0, max_front));
  back_bleed  = min(max(0, width), max(0, max_back));
  outer_w = max(0.01, cell_w + left_bleed + right_bleed);
  outer_d = max(0.01, cell_d + front_bleed + back_bleed);

  translate([(right_bleed - left_bleed) / 2, (back_bleed - front_bleed) / 2, 0])
    cuboid([outer_w, outer_d, safe_depth + 0.1], anchor=TOP);
}
