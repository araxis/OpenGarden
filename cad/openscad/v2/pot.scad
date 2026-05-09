include <BOSL2/std.scad>

module PotCut(
  size = [180, 50],
  h = 25,
  chamfer = 1,
  tag_name = "cut"
) {
  safe_chamfer = min(chamfer, h / 4, min(size[0], size[1]) / 6);

  tag(tag_name)
    down(0.05)
      prismoid(
        size1=size,
        size2=size,
        h=h + 0.1,
        chamfer=safe_chamfer,
        anchor=TOP
      );
}
