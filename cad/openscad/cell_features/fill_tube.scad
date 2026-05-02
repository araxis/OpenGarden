include <BOSL2/std.scad>

module feature_fill_tube(cell_w, cell_d, clearance = 0.8) {
  cut_w = max(0, cell_w - clearance * 2);
  cut_d = max(0, cell_d - clearance * 2);

  if (cut_w > 0 && cut_d > 0)
    cuboid([cut_w, cut_d, 30]);
}
