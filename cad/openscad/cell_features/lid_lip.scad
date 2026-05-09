include <BOSL2/std.scad>

module feature_lid_lip(
  cell_w, cell_d,
  depth = 2, width = 1.5,
  max_left = 0, max_right = 0, max_front = 0, max_back = 0
) {
  safe_depth = max(0.1, depth);
  inset_w = max(0.01, cell_w - width * 2);
  inset_d = max(0.01, cell_d - width * 2);
  left_bleed = min(max(0, width), max(0, max_left));
  right_bleed = min(max(0, width), max(0, max_right));
  front_bleed = min(max(0, width), max(0, max_front));
  back_bleed = min(max(0, width), max(0, max_back));
  outer_w = max(0.01, cell_w + left_bleed + right_bleed);
  outer_d = max(0.01, cell_d + front_bleed + back_bleed);

  difference() {
    translate([(right_bleed - left_bleed) / 2, (back_bleed - front_bleed) / 2, 0])
      cuboid([outer_w, outer_d, safe_depth + 0.1], anchor=TOP);
    cuboid([inset_w, inset_d, safe_depth + 1], anchor=TOP);
  }
}
