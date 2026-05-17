include <BOSL2/std.scad>
include <rim.scad>
include <pot.scad>

module PotRectReference(
  top_size = [180, 50],
  pot_h = 55,
  insert_depth = 37,
  wall = 2,
  floor = 3,
  taper = 0,
  chamfer = 1,
  rim_w = 3,
  rim_h = 3,
  rim_chamfer = 0.6,
  hole_rows = 2,
  hole_cols = 8,
  hole_diameter = 3,
  hole_padding = 14
) {
  body_size = [
    max(0.01, top_size[0] - rim_w * 2),
    max(0.01, top_size[1] - rim_w * 2)
  ];

  Pot(
    top_size=body_size,
    h=pot_h,
    wall=wall,
    floor=floor,
    taper=taper,
    chamfer=chamfer,
    rim_width=rim_w,
    rim_height=rim_h,
    rim_z=insert_depth,
    rim_chamfer=rim_chamfer,
    hole_rows=hole_rows,
    hole_cols=hole_cols,
    hole_diameter=hole_diameter,
    hole_padding=hole_padding
  );
}

module PotRectCut(
  cut_size = [180, 50],
  shell_thickness = 3,
  fit_clearance = 0.4,
  taper = 0,
  insert_depth = 37,
  rim_w = 3,
  rim_h = 3,
  rim_chamfer = 0.6,
  cut_epsilon = 0.2
) {
  through_size = [
    max(0.01, cut_size[0] - rim_w * 2),
    max(0.01, cut_size[1] - rim_w * 2)
  ];

  if (rim_w > 0 || rim_h > 0)
    RectSeatCut(
      outer_size=cut_size,
      through_size=through_size,
      shell_thickness=shell_thickness,
      seat_depth=max(0, rim_h),
      fit_clearance=fit_clearance,
      chamfer=rim_chamfer,
      cut_epsilon=cut_epsilon
    );
  else {
    safe_thickness = max(0.5, shell_thickness);
    safe_insert = max(0.5, insert_depth);
    taper_at_cut_depth = taper * min(1, safe_thickness / safe_insert);
    cut_top_size = [
      max(0.01, through_size[0] + fit_clearance * 2),
      max(0.01, through_size[1] + fit_clearance * 2)
    ];
    cut_bottom_size = [
      max(0.01, through_size[0] - taper_at_cut_depth * 2 + fit_clearance * 2),
      max(0.01, through_size[1] - taper_at_cut_depth * 2 + fit_clearance * 2)
    ];

    prismoid(
      size1=cut_bottom_size,
      size2=cut_top_size,
      h=safe_thickness + 0.2,
      anchor=BOTTOM
    );
  }
}
