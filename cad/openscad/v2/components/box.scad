module BoxContainer(
  top_size = [180, 50],
  h = 25,
  wall = 2,
  floor = 3,
  chamfer = 1
) {
  safe_wall = min(max(0.4, wall), min(top_size[0], top_size[1]) / 3);
  safe_floor = max(0.4, floor);
  inner_top_size = [
    max(0.01, top_size[0] - safe_wall * 2),
    max(0.01, top_size[1] - safe_wall * 2)
  ];
  safe_chamfer = min(chamfer, h / 4, safe_wall / 2, min(top_size[0], top_size[1]) / 6);

  difference() {
    prismoid(
      size1=top_size,
      size2=top_size,
      h=h,
      chamfer=safe_chamfer,
      anchor=BOTTOM
    );

    up(h + 0.05)
      prismoid(
        size1=inner_top_size,
        size2=inner_top_size,
        h=max(0.01, h - safe_floor) + 0.1,
        chamfer=min(safe_chamfer, safe_wall / 3),
        anchor=TOP
      );
  }
}
