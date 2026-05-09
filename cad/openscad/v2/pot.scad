include <BOSL2/std.scad>

module Pot(
  top_size = [180, 50],
  h = 25,
  taper = 6,
  chamfer = 1,
  tag_name = "cut"
) {
  bottom_size = [
    max(0.01, top_size[0] - taper * 2),
    max(0.01, top_size[1] - taper * 2)
  ];
  safe_chamfer = min(chamfer, h / 4, min(top_size[0], top_size[1], bottom_size[0], bottom_size[1]) / 6);

  tag(tag_name)
    down(0.05)
      prismoid(
        size1=bottom_size,
        size2=top_size,
        h=h + 0.1,
        chamfer=safe_chamfer,
        anchor=TOP
      );
}
