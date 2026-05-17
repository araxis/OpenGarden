include <BOSL2/std.scad>
include <props.scad>
include <../grid.scad>

// ---------------------------------------------------------------------------
// Geometry helpers (moved here from container.scad)
// ---------------------------------------------------------------------------

module FlatTopArcBridge(span, width, h, rise, steps = 10) {
  safe_span = max(0.01, span);
  safe_width = max(0.01, width);
  safe_h = max(0.01, h);
  safe_rise = min(max(0, rise), safe_h);
  points = concat(
    [[-safe_span / 2, safe_h], [safe_span / 2, safe_h]],
    [for (i = [0:steps])
      let (
        t = i / steps,
        y = safe_span / 2 - safe_span * t,
        z = safe_rise * sin(180 * t)
      )
        [y, z]
    ]
  );
  multmatrix([
    [0, 0, 1, 0],
    [1, 0, 0, 0],
    [0, 1, 0, 0],
    [0, 0, 0, 1]
  ])
    linear_extrude(height=safe_width, center=true, convexity=4)
      polygon(points=points);
}

module FusedSupportRail(length, width, h, foot, embed, chamfer) {
  shoe_h = foot > 0 ? min(max(1, foot * 0.55), h * 0.25) : 0;
  shoe_width = width + foot * 2;
  rail_chamfer = min(chamfer, width / 3, h / 3);
  shoe_chamfer = shoe_h > 0 ? min(chamfer, shoe_h / 3, shoe_width / 4) : 0;
  top_web = max(width, 2);
  relief_post = max(width * 1.4, 3);
  relief_target_w = max(10, min(28, h * 1.25));
  relief_available = max(0, length - relief_post * 2);
  relief_count = relief_available < relief_target_w
    ? 0
    : max(1, floor((relief_available + relief_post) / (relief_target_w + relief_post)));
  relief_w = relief_count <= 0
    ? 0
    : (relief_available - max(0, relief_count - 1) * relief_post) / relief_count;
  arch_r = relief_count <= 0 ? 0 : max(0, min(relief_w / 2, h - shoe_h - top_web));
  arch_z = shoe_h - arch_r * 0.35;
  relief_start_x = -length / 2 + relief_post + relief_w / 2;
  relief_pitch = relief_w + relief_post;

  union() {
    if (shoe_h > 0)
      cuboid([length, shoe_width, shoe_h], chamfer=shoe_chamfer, anchor=BOTTOM);
    difference() {
      cuboid([length, width, h], chamfer=rail_chamfer, anchor=BOTTOM);
      if (relief_count > 0 && arch_r > 0.5)
        for (i = [0:relief_count - 1])
          translate([relief_start_x + i * relief_pitch, 0, arch_z])
            rotate([90, 0, 0])
              cylinder(r=arch_r, h=width + 0.2, center=true);
    }
  }
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

module _DeckFrameSlats(
  inner_x,
  inner_y,
  outer_x,           // slats extend to outer_x so they embed into the short frame walls
  frame_h,
  side_gap,
  slat_width,
  slat_gap,
  slat_chamfer,
  include_bridges,
  eps
) {
  pitch = max(0.1, slat_width + slat_gap);
  usable_y = max(0.01, inner_y - side_gap * 2);
  usable_x = max(0.01, outer_x);  // embeds into short walls for a fused joint
  slat_count = max(1, floor((usable_y + slat_gap) / pitch));
  total_y = slat_count * slat_width + max(0, slat_count - 1) * slat_gap;
  start_y = -total_y / 2 + slat_width / 2;

  bridge_width = max(slat_width, 2.4);
  bridge_overlap = max(0.6, slat_width * 0.3);
  bridge_h = min(max(2, slat_width * 0.9), frame_h);
  bridge_top_web = min(max(1.0, bridge_h * 0.35), bridge_h);
  bridge_rise = max(0, bridge_h - bridge_top_web);
  bridge_target_pitch = max(28, slat_width * 10);
  bridge_count = usable_x < bridge_target_pitch
    ? 0
    : max(1, floor(usable_x / bridge_target_pitch));
  bridge_pitch = bridge_count <= 0 ? 0 : usable_x / (bridge_count + 1);
  bridge_start_x = -usable_x / 2 + bridge_pitch;

  for (i = [0:slat_count - 1])
    translate([0, start_y + i * pitch, 0])
      FusedSupportRail(
        length=usable_x,
        width=slat_width,
        h=frame_h,
        foot=0,
        embed=0,
        chamfer=slat_chamfer
      );

  if (include_bridges && slat_count > 1 && bridge_count > 0 && bridge_rise > 0.5)
    for (x_i = [0:bridge_count - 1])
      for (s_i = [0:slat_count - 2])
        translate([
          bridge_start_x + x_i * bridge_pitch,
          start_y + s_i * pitch + pitch / 2,
          frame_h - bridge_h
        ])
          FlatTopArcBridge(
            span=pitch + bridge_overlap * 2,
            width=bridge_width,
            h=bridge_h,
            rise=bridge_rise
          );
}

module _DeckFrameKeepouts(
  components,
  shell_size,
  row_spec,
  col_spec,
  grid_padding,
  frame_h,
  eps
) {
  for (component = components)
    let (
      comp_type = v2_component_type(component),
      support_mode = v2_component_support_mode(component, comp_type)
    )
      if (support_mode != "deck")
        let (
          margin = v2_component_prop(component, "margin", 0),
          keepout_pad = v2_component_prop(component, "deck_keepout_padding", 0),
          center = v2_component_footprint_center(
            component, shell_size, row_spec, col_spec, grid_padding
          ),
          cell_sz = v2_component_footprint_size(
            component, shell_size, row_spec, col_spec, grid_padding
          ),
          ks = [
            max(0.01, cell_sz[0] - margin * 2 + keepout_pad * 2),
            max(0.01, cell_sz[1] - margin * 2 + keepout_pad * 2)
          ]
        )
          translate([center[0], center[1], -eps])
            cuboid([ks[0], ks[1], frame_h + eps * 2], anchor=BOTTOM);
}

// ---------------------------------------------------------------------------
// DeckFrame — insertable support deck for ReservoirContainer
//
// Sits on the container floor. Guide rail channels on the long (Y-facing)
// outer walls mate with protrusions on the container inner walls.
// Slat tops are flush with the frame top at the correct insert height.
//
// Print orientation: upside-down (slats on build plate, open bottom up).
// ---------------------------------------------------------------------------

module DeckFrame(
  container_inner_size,          // [x, y] — container inner footprint at top
  frame_h,                       // total frame height (floor to slat top)
  frame_wall = 3,                // outer frame wall thickness (mm)
  fit_clearance = 0.3,           // per-side gap between frame outer and container inner
  guide_rail_width = 5,          // width of guide rail channel (mm)
  guide_rail_depth = 1.2,        // depth of guide rail channel (mm) — must match container
  guide_rail_clearance = 0.3,    // extra per-side clearance inside channel (mm)
  guide_rail_corner_offset = 16, // X distance from inner corner to rail center (mm)
  slat_width = 3,                // support slat width (mm)
  slat_gap = 7,                  // gap between adjacent slats (mm)
  slat_side_gap = 6,             // Y-axis inset from long frame walls to slat zone (mm); slats always span full inner X
  slat_chamfer = 0.6,            // slat edge chamfer (mm)
  include_bridges = true,        // add arch bridges between slats
  components = [],               // component array for keepout punching
  shell_size = [200, 100],
  row_spec = "1*",
  col_spec = "1*",
  grid_padding = [4, 4, 4, 4],
  eps = 0.04
) {
  outer_x = max(0.01, container_inner_size[0] - fit_clearance * 2);
  outer_y = max(0.01, container_inner_size[1] - fit_clearance * 2);
  inner_x = max(0.01, outer_x - frame_wall * 2);
  inner_y = max(0.01, outer_y - frame_wall * 2);
  safe_h = max(1, frame_h);

  // Channel cut into the long (Y-facing) outer walls of the frame.
  // The channel receives the container's inward-protruding guide rail.
  ch_depth = min(
    max(0.5, guide_rail_depth + guide_rail_clearance),
    frame_wall - 0.5            // leave at least 0.5 mm of wall behind channel
  );
  ch_width = max(0.1, guide_rail_width + guide_rail_clearance * 2);

  // Clamp corner offset so channels stay within the long wall extents
  safe_corner_off = min(
    max(ch_width / 2 + 1, guide_rail_corner_offset),
    outer_x / 2 - ch_width / 2 - 1
  );

  difference() {
    union() {
      // Outer hollow frame — open bottom and top interior, only walls remain
      difference() {
        cuboid([outer_x, outer_y, safe_h], anchor=BOTTOM);
        down(eps)
          cuboid([inner_x, inner_y, safe_h + eps * 2], anchor=BOTTOM);
      }

      // Interior slats + bridges — span outer_x so ends embed into the short frame walls
      _DeckFrameSlats(
        inner_x=inner_x,
        inner_y=inner_y,
        outer_x=outer_x,
        frame_h=safe_h,
        side_gap=slat_side_gap,
        slat_width=slat_width,
        slat_gap=slat_gap,
        slat_chamfer=slat_chamfer,
        include_bridges=include_bridges,
        eps=eps
      );
    }

    // Guide rail channels: cut from the outer face of each long (Y-facing) wall
    for (y_sign = [-1, 1])
      for (x_sign = [-1, 1])
        translate([
          x_sign * (outer_x / 2 - safe_corner_off),
          y_sign * (outer_y / 2 - ch_depth / 2),
          safe_h / 2
        ])
          cuboid([ch_width, ch_depth + eps, safe_h + eps * 2]);

    // Keepout punches — clear slats under non-deck components
    _DeckFrameKeepouts(
      components=components,
      shell_size=shell_size,
      row_spec=row_spec,
      col_spec=col_spec,
      grid_padding=grid_padding,
      frame_h=safe_h,
      eps=eps
    );
  }
}
