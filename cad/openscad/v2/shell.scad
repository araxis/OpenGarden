include <BOSL2/std.scad>

module TopShell(
  size1 = [200, 70],
  size2 = [190, 60],
  h = 40,
  chamfer = 2,
  rounding = 0,
  subtract_tag = "cut"
) {
  safe_chamfer = min(chamfer, h / 4, min(size1[0], size1[1], size2[0], size2[1]) / 6);
  safe_rounding = min(rounding, min(size1[0], size1[1], size2[0], size2[1]) / 6);

  diff(subtract_tag)
    prismoid(
      size1=size1,
      size2=size2,
      h=h,
      chamfer=safe_chamfer,
      rounding=safe_rounding,
      anchor=BOTTOM
    )
      children();
}
