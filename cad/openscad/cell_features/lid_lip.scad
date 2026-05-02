include <BOSL2/std.scad>

module feature_lid_lip(cell_w, cell_d, depth = 2, width = 1.5) {
  difference() {
    cuboid([cell_w + width * 2, cell_d + width * 2, depth + 0.1], anchor=TOP);
    cuboid([cell_w, cell_d, depth + 1], anchor=TOP);
  }
}
