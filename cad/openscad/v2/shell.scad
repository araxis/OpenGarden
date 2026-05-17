include <BOSL2/std.scad>
include <grid.scad>
include <components/registry.scad>

module ShellPlate(
  top_size = [200, 70],
  bottom_size = [196, 66],
  thickness = 3,
  chamfer = 0.8,
  rounding = 0
) {
  safe_thickness = max(0.5, thickness);
  safe_chamfer = min(chamfer, safe_thickness / 2, min(top_size[0], top_size[1], bottom_size[0], bottom_size[1]) / 6);
  safe_rounding = min(rounding, min(top_size[0], top_size[1], bottom_size[0], bottom_size[1]) / 6);

  prismoid(
    size1=bottom_size,
    size2=top_size,
    h=safe_thickness,
    chamfer=safe_chamfer,
    rounding=safe_rounding,
    anchor=BOTTOM
  );
}

module ShellPlateWithPotCut(
  top_size = [200, 70],
  bottom_size = [196, 66],
  thickness = 3,
  chamfer = 0.8,
  rounding = 0,
  pot_top_size = [180, 50],
  pot_taper = 6,
  pot_cavity_height = 37,
  fit_clearance = 0.4,
  cut_center = [0, 0]
) {
  safe_thickness = max(0.5, thickness);
  safe_clearance = max(0, fit_clearance);
  safe_cavity_height = max(0.5, pot_cavity_height);
  taper_at_cut_depth = pot_taper * min(1, safe_thickness / safe_cavity_height);

  cut_top_size = [
    max(0.01, pot_top_size[0] + safe_clearance * 2),
    max(0.01, pot_top_size[1] + safe_clearance * 2)
  ];
  cut_bottom_size = [
    max(0.01, pot_top_size[0] - taper_at_cut_depth * 2 + safe_clearance * 2),
    max(0.01, pot_top_size[1] - taper_at_cut_depth * 2 + safe_clearance * 2)
  ];

  difference() {
    ShellPlate(
      top_size=top_size,
      bottom_size=bottom_size,
      thickness=safe_thickness,
      chamfer=chamfer,
      rounding=rounding
    );

    translate([cut_center[0], cut_center[1], -0.1])
      prismoid(
        size1=cut_bottom_size,
        size2=cut_top_size,
        h=safe_thickness + 0.2,
        anchor=BOTTOM
      );
  }
}

module ShellPlateWithComponents(
  top_size = [200, 70],
  bottom_size = [196, 66],
  thickness = 3,
  chamfer = 0.8,
  rounding = 0,
  row_spec = "1*",
  col_spec = "1*",
  grid_padding = [4, 4, 4, 4],
  default_taper = 0,
  default_cavity_height = 37,
  default_clearance = 0.4,
  default_cut_epsilon = 0.2,
  components = [[["type", "pot"], ["row", 1], ["col", 1]]],
  seat_enabled = true,
  seat_inset = 4,
  seat_width = 3,
  seat_height = 2,
  seat_fit_clearance = 0.25
) {
  groove_outer = [
    max(0.01, bottom_size[0] - seat_inset * 2 + seat_fit_clearance * 2),
    max(0.01, bottom_size[1] - seat_inset * 2 + seat_fit_clearance * 2)
  ];
  groove_inner = [
    max(0.01, groove_outer[0] - seat_width * 2 - seat_fit_clearance * 4),
    max(0.01, groove_outer[1] - seat_width * 2 - seat_fit_clearance * 4)
  ];
  safe_seat_h = min(max(0, seat_height + seat_fit_clearance), thickness - 0.2);

  difference() {
    ShellPlate(
      top_size=top_size,
      bottom_size=bottom_size,
      thickness=thickness,
      chamfer=chamfer,
      rounding=rounding
    );

    if (seat_enabled && seat_width > 0 && safe_seat_h > 0.1 && groove_inner[0] > 0.5 && groove_inner[1] > 0.5)
      difference() {
        cuboid([groove_outer[0], groove_outer[1], safe_seat_h], anchor=BOTTOM);
        cuboid([groove_inner[0], groove_inner[1], safe_seat_h + 0.05], anchor=BOTTOM);
      }

    for (component = components)
      v2_component_cut(
        component=component,
        shell_size=top_size,
        row_spec=row_spec,
        col_spec=col_spec,
        grid_padding=grid_padding,
        default_taper=default_taper,
        default_cavity_height=default_cavity_height,
        default_clearance=default_clearance,
        default_cut_epsilon=default_cut_epsilon,
        shell_thickness=thickness
      );
  }
}
