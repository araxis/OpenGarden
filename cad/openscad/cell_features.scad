include <BOSL2/std.scad>
use <feature_dsl.scad>
include <grid_helpers.scad>

function feature_plane(featureName) =
  feature_name_plane(featureName);

function feature_polarity(featureName) =
  featureName == "" || featureName == "none" ? ""
  : "SUBTRACT";

function cell_bottom_feature_name(overrides, roles, roleOverrides, row, col, colCount) =
  let (explicit = feature_override_name(overrides, row, col, "BOTTOM"))
    explicit != "" ? explicit : cell_role_bottom_feature(grid_cell_role(roles, roleOverrides, row, col, colCount));

function cell_top_lip_feature_name(overrides, row, col) =
  feature_override_name(overrides, row, col, "TOP_LIP");

function cell_role_bottom_feature(role) =
  role == "Pot" ? "drain_holes"
  : role == "FillTube" ? "fill_tube"
  : "";

function feature_drain_pattern(overrides, row, col, defaultPattern) =
  feature_override_token_param_equals(overrides, row, col, "BOTTOM", "pattern", "Circle")
  || feature_override_token_param_equals(overrides, row, col, "BOTTOM", "pattern", "circle") ? "Circle"
  : feature_override_token_param_equals(overrides, row, col, "BOTTOM", "pattern", "Rectangle")
  || feature_override_token_param_equals(overrides, row, col, "BOTTOM", "pattern", "rectangle") ? "Rectangle"
  : defaultPattern;

function feature_drain_rows(overrides, row, col, defaultRows) =
  feature_override_number_param(overrides, row, col, "BOTTOM", "rows", defaultRows);

function feature_drain_cols(overrides, row, col, defaultCols) =
  feature_override_number_param(
    overrides, row, col, "BOTTOM", "cols",
    feature_override_number_param(overrides, row, col, "BOTTOM", "columns", defaultCols)
  );

function feature_drain_diameter(overrides, row, col, defaultDiameter) =
  feature_override_number_param(overrides, row, col, "BOTTOM", "diameter", defaultDiameter);

function feature_drain_padding(overrides, row, col, defaultPadding) =
  feature_override_number_param(overrides, row, col, "BOTTOM", "padding", defaultPadding);

function feature_fill_tube_clearance(overrides, row, col, defaultClearance) =
  feature_override_number_param(overrides, row, col, "BOTTOM", "clearance", defaultClearance);

function feature_wick_port_diameter(overrides, row, col) =
  feature_override_number_param(overrides, row, col, "BOTTOM", "diameter", 10);

function feature_wick_port_rim(overrides, row, col) =
  feature_override_bool_param(overrides, row, col, "BOTTOM", "rim", false);

function feature_lid_lip_depth(overrides, row, col) =
  feature_override_number_param(overrides, row, col, "TOP_LIP", "depth", 2);

function feature_lid_lip_width(overrides, row, col) =
  feature_override_number_param(overrides, row, col, "TOP_LIP", "width", 8);

module CellFeatureApply(
  featureName,
  plane,
  cellWidth,
  cellDepth,
  cellHeight,
  overrides,
  row,
  col,
  holeAreaPadding,
  holePattern,
  holeRows,
  holeCols,
  holeDiameter,
  fillTubeClearance,
  fillTubeLeftClearance,
  fillTubeRightClearance,
  fillTubeFrontClearance,
  fillTubeBackClearance
) {
  if (featureName == "drain_holes" && plane == "BOTTOM")
    CellFeatureDrainHoles(
      cellWidth,
      cellDepth,
      feature_drain_padding(overrides, row, col, holeAreaPadding),
      feature_drain_pattern(overrides, row, col, holePattern),
      feature_drain_rows(overrides, row, col, holeRows),
      feature_drain_cols(overrides, row, col, holeCols),
      feature_drain_diameter(overrides, row, col, holeDiameter)
    );
  else if (featureName == "fill_tube" && plane == "BOTTOM")
    CellFeatureFillTubeCutout(
      cellWidth,
      cellDepth,
      fillTubeLeftClearance,
      fillTubeRightClearance,
      fillTubeFrontClearance,
      fillTubeBackClearance
    );
  else if (featureName == "wick_port" && plane == "BOTTOM")
    CellFeatureWickPort(
      feature_wick_port_diameter(overrides, row, col),
      feature_wick_port_rim(overrides, row, col)
    );
  else if (featureName == "lid_lip" && plane == "TOP_LIP")
    CellFeatureLidLip(
      cellWidth,
      cellDepth,
      feature_lid_lip_depth(overrides, row, col),
      feature_lid_lip_width(overrides, row, col)
    );
}

module CellFeatureDrainHoles(width, depth, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter) {
  rows = max(1, round(holeRows));
  cols = max(1, round(holeCols));
  span_x = max(0, width - holeAreaPadding);
  span_y = max(0, depth - holeAreaPadding);

  if (holePattern == "Circle") {
    radius = max(0, min(span_x, span_y) / 2 - holeDiameter / 2);
    ring_spacing = holeDiameter * 1.15;
    fitted_rows = radius <= 0 ? 1 : min(rows, floor(radius / ring_spacing) + 1);

    for (ring = [0:fitted_rows - 1]) {
      ring_radius = fitted_rows <= 1 ? 0 : ring * radius / (fitted_rows - 1);
      holes = ring == 0 ? 1 : cols * ring;
      angle_offset = ring % 2 == 0 ? 180 / holes : 0;
      for (hole = [0:holes - 1])
        translate([
          ring_radius * cos(angle_offset + 360 * hole / holes),
          ring_radius * sin(angle_offset + 360 * hole / holes),
          0
        ])
          cyl(d=holeDiameter, h=30);
    }
  } else {
    for (row = [0:rows - 1])
      for (col = [0:cols - 1])
        translate([
          feature_hole_offset(row, rows, span_x),
          feature_hole_offset(col, cols, span_y),
          0
        ])
          cyl(d=holeDiameter, h=30);
  }
}

module CellFeatureFillTubeCutout(width, depth, leftClearance, rightClearance, frontClearance, backClearance) {
  cut_w = max(0, width - leftClearance - rightClearance);
  cut_d = max(0, depth - frontClearance - backClearance);

  if (cut_w > 0 && cut_d > 0)
    translate([(leftClearance - rightClearance) / 2, (frontClearance - backClearance) / 2, 0])
      cuboid([cut_w, cut_d, 30]);
}

module CellFeatureWickPort(diameter, rim) {
  cyl(d=diameter, h=30);

  if (rim)
    cyl(d=diameter + 4, h=3);
}

module CellFeatureLidLip(width, depth, lipDepth, lipWidth) {
  cut_depth = max(0, lipDepth);
  side_width = min(max(0, lipWidth), min(width, depth) / 2);

  if (cut_depth > 0 && side_width > 0) {
    down(cut_depth / 2) {
      translate([0, depth / 2 - side_width / 2, 0])
        cuboid([width, side_width, cut_depth + 0.1]);
      translate([0, -depth / 2 + side_width / 2, 0])
        cuboid([width, side_width, cut_depth + 0.1]);

      if (depth - side_width * 2 > 0) {
        translate([width / 2 - side_width / 2, 0, 0])
          cuboid([side_width, depth - side_width * 2, cut_depth + 0.1]);
        translate([-width / 2 + side_width / 2, 0, 0])
          cuboid([side_width, depth - side_width * 2, cut_depth + 0.1]);
      }
    }
  }
}

function feature_hole_offset(index, count, span) =
  count <= 1 ? 0 : -span / 2 + index * span / (count - 1);
