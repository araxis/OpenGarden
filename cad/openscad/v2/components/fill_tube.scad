module FillTubeCut(
  tube_w = 8,
  tube_d = 8,
  fit_clearance = 0.4,
  shell_thickness = 3
) {
  safe_clearance = max(0, fit_clearance);
  w = max(0.01, tube_w + safe_clearance * 2);
  d = max(0.01, tube_d + safe_clearance * 2);

  prismoid(
    size1=[w, d],
    size2=[w, d],
    h=max(0.5, shell_thickness) + 0.2,
    anchor=BOTTOM
  );
}

module FillTubeReference(
  tube_w = 8,
  tube_d = 8,
  h = 25,
  chamfer = 0
) {
  prismoid(
    size1=[max(0.01, tube_w), max(0.01, tube_d)],
    size2=[max(0.01, tube_w), max(0.01, tube_d)],
    h=max(0.5, h),
    chamfer=max(0, chamfer),
    anchor=BOTTOM
  );
}
