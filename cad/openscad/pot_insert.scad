include <BOSL2/std.scad>
include <anchor_names.scad>
include <grid_helpers.scad>
use <cell_anchors.scad>
use <cell_features.scad>
use <feature_dsl.scad>

height = 100;
width = 70.0;
depth = 70.0;
wallThickness = 2;
frontChamfer = 5;
chamferBackSide = false;
baseThickness = 2;
holeAreaPadding = 25;
holePattern = "Rectangle";
holeRows = 4;
holeCols = 4;
holeDiameter = 5;
seatHeight = 5;
gridRowSizes = "1*";
gridColumnSizes = "1*";
gridCellRoles = "Pot";
gridCellRoleOverrides = "";
gridCellSpans = "";
cellFeatureOverrides = "";
gridWallThickness = 2;
fillTubeClearance = 0.8;

module PotInsert(
  width,
  depth,
  height,
  wallThickness = wallThickness,
  chamfer = frontChamfer,
  chamferBackSide = chamferBackSide,
  baseThickness = baseThickness,
  holeAreaPadding = holeAreaPadding,
  holePattern = holePattern,
  holeRows = holeRows,
  holeCols = holeCols,
  holeDiameter = holeDiameter,
  seatHeight = seatHeight,
  gridRowSizes = gridRowSizes,
  gridColumnSizes = gridColumnSizes,
  gridCellRoles = gridCellRoles,
  gridCellRoleOverrides = gridCellRoleOverrides,
  gridCellSpans = gridCellSpans,
  cellFeatureOverrides = cellFeatureOverrides,
  gridWallThickness = gridWallThickness,
  fillTubeClearance = fillTubeClearance,
  anchor = CENTER,
  spin = 0,
  orient = UP
) {

  w = width;
  d = depth;
  h = height;
  seat_z = -h / 2 + seatHeight + baseThickness;
  side_chamfer = side_chamfers(chamfer, chamferBackSide);
  anchors = concat(
    [
      named_anchor(POT_INSERT_ANCHOR_BOTTOM, [0, 0, seat_z], DOWN)
    ],
    cell_anchor_set(w, d, h, wallThickness, seatHeight, baseThickness, gridRowSizes, gridColumnSizes, gridWallThickness)
  );

  FeatureDslWarnings(cellFeatureOverrides);

  attachable(anchor, spin, orient, size=[w, d, h], anchors=anchors) {
    assert(h > 0, "PotInsert height must be greater than seatHeight + baseThickness.")
      down(h / 2 - seatHeight - baseThickness)
        fwd(d / 2)
          diff("cell_feature")
            union() {
              rect_tube(
                size=[w, d],
                h=h,
                wall=wallThickness,
                chamfer=side_chamfer,
                ichamfer=side_chamfer,
                anchor=FRONT + BOTTOM
              )
                attach(BOTTOM, TOP)
                  Base(w, d, seatHeight, wallThickness, baseThickness, chamfer, chamferBackSide, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter, gridRowSizes, gridColumnSizes, gridCellRoles, gridCellRoleOverrides, gridCellSpans, cellFeatureOverrides, gridWallThickness, fillTubeClearance);

              InsertGrid(w, d, h, wallThickness, gridRowSizes, gridColumnSizes, gridCellSpans, gridWallThickness);

              tag("cell_feature")
                CellFeaturePattern(w, d, h, wallThickness, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter, gridRowSizes, gridColumnSizes, gridCellRoles, gridCellRoleOverrides, gridCellSpans, cellFeatureOverrides, gridWallThickness, fillTubeClearance, "TOP_LIP", h);
            }

    children();
  }
}

module InsertGrid(width, depth, height, wallThickness, gridRowSizes, gridColumnSizes, gridCellSpans, gridWallThickness) {
  rows = grid_track_count(gridRowSizes);
  cols = grid_track_count(gridColumnSizes);
  divider = max(0.4, gridWallThickness);
  inner_w = max(0, width - wallThickness * 2);
  inner_d = max(0, depth - wallThickness * 2);

  for (row = [0:rows - 1])
    for (col = [0:cols - 1])
      if (!grid_cell_is_covered_by_span(gridCellSpans, row, col))
        let (
          row_span = grid_cell_span_rows(gridCellSpans, row, col, rows),
          col_span = grid_cell_span_cols(gridCellSpans, row, col, cols),
          end_row = row + row_span - 1,
          end_col = col + col_span - 1,
          x0 = grid_track_edge(inner_w, gridColumnSizes, cols, divider, col),
          x1 = grid_track_edge(inner_w, gridColumnSizes, cols, divider, end_col)
            + grid_track_size(inner_w, gridColumnSizes, cols, divider, end_col),
          y0 = wallThickness + grid_track_edge_from_front(inner_d, gridRowSizes, rows, divider, row),
          y1 = wallThickness + grid_track_edge_from_front(inner_d, gridRowSizes, rows, divider, end_row)
            + grid_track_size(inner_d, gridRowSizes, rows, divider, end_row),
          front_ext = row > 0 ? divider / 2 : 0,
          back_ext = end_row < rows - 1 ? divider / 2 : 0,
          left_ext = col > 0 ? divider / 2 : 0,
          right_ext = end_col < cols - 1 ? divider / 2 : 0
        ) {
          if (col > 0)
            translate([x0 - divider / 2, (y0 + y1 - front_ext + back_ext) / 2, 0])
              cuboid([divider, y1 - y0 + front_ext + back_ext, height], anchor=BOTTOM);

          if (end_col < cols - 1)
            translate([x1 + divider / 2, (y0 + y1 - front_ext + back_ext) / 2, 0])
              cuboid([divider, y1 - y0 + front_ext + back_ext, height], anchor=BOTTOM);

          if (row > 0)
            translate([(x0 + x1 - left_ext + right_ext) / 2, y0 - divider / 2, 0])
              cuboid([x1 - x0 + left_ext + right_ext, divider, height], anchor=BOTTOM);

          if (end_row < rows - 1)
            translate([(x0 + x1 - left_ext + right_ext) / 2, y1 + divider / 2, 0])
              cuboid([x1 - x0 + left_ext + right_ext, divider, height], anchor=BOTTOM);
        }
}

module Base(
  width,
  depth,
  height,
  wallThickness,
  baseThickness,
  chamfer,
  chamferBackSide,
  holeAreaPadding,
  holePattern,
  holeRows,
  holeCols,
  holeDiameter,
  gridRowSizes,
  gridColumnSizes,
  gridCellRoles,
  gridCellRoleOverrides,
  gridCellSpans,
  cellFeatureOverrides,
  gridWallThickness,
  fillTubeClearance
) {
  //ring
  ring_w = (width - wallThickness * 2) - 0.3;
  ring_d = (depth - wallThickness * 2) - 0.3;
  side_chamfer = side_chamfers(chamfer, chamferBackSide);
  diff("hole")
    rect_tube(
      size1=[ring_w, ring_d],
      size2=[width, depth],
      h=height,
      wall=wallThickness,
      chamfer=side_chamfer,
      ichamfer=side_chamfer,
      anchor=FRONT + BOTTOM
    )
      attach(BOTTOM, TOP, overlap=0.1)
        prismoid(
          [ring_w, ring_d],
          [ring_w, ring_d],
          height=baseThickness,
          anchor=TOP + FRONT,
          chamfer=side_chamfer
        )
          tag("hole")
            CellFeaturePattern(width, depth, height + baseThickness, wallThickness, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter, gridRowSizes, gridColumnSizes, gridCellRoles, gridCellRoleOverrides, gridCellSpans, cellFeatureOverrides, gridWallThickness, fillTubeClearance, "BOTTOM", 0);
}

module CellFeaturePattern(width, depth, height, wallThickness, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter, gridRowSizes, gridColumnSizes, gridCellRoles, gridCellRoleOverrides, gridCellSpans, cellFeatureOverrides, gridWallThickness, fillTubeClearance, plane, z) {
  grid_rows = grid_track_count(gridRowSizes);
  grid_cols = grid_track_count(gridColumnSizes);
  divider = max(0.4, gridWallThickness);
  inner_w = max(0, width - wallThickness * 2);
  inner_d = max(0, depth - wallThickness * 2);

  for (grid_row = [0:grid_rows - 1])
    for (grid_col = [0:grid_cols - 1])
      let (
        cell_w = grid_track_size(inner_w, gridColumnSizes, grid_cols, divider, grid_col),
        cell_d = grid_track_size(inner_d, gridRowSizes, grid_rows, divider, grid_row),
        feature_name = plane == "BOTTOM"
          ? cell_bottom_feature_name(cellFeatureOverrides, gridCellRoles, gridCellRoleOverrides, grid_row, grid_col, grid_cols)
          : cell_top_lip_feature_name(cellFeatureOverrides, grid_row, grid_col),
        tube_clearance = feature_fill_tube_clearance(cellFeatureOverrides, grid_row, grid_col, fillTubeClearance),
        left_ext = plane == "BOTTOM" && feature_name == "fill_tube" && filltube_feature_merges_left(gridCellSpans, cellFeatureOverrides, gridCellRoles, gridCellRoleOverrides, grid_row, grid_col, grid_cols) ? divider / 2 : 0,
        right_ext = plane == "BOTTOM" && feature_name == "fill_tube" && filltube_feature_merges_right(gridCellSpans, cellFeatureOverrides, gridCellRoles, gridCellRoleOverrides, grid_row, grid_col, grid_cols) ? divider / 2 : 0,
        front_ext = plane == "BOTTOM" && feature_name == "fill_tube" && filltube_feature_merges_front(gridCellSpans, cellFeatureOverrides, gridCellRoles, gridCellRoleOverrides, grid_row, grid_col, grid_cols) ? divider / 2 : 0,
        back_ext = plane == "BOTTOM" && feature_name == "fill_tube" && filltube_feature_merges_back(gridCellSpans, cellFeatureOverrides, gridCellRoles, gridCellRoleOverrides, grid_row, grid_col, grid_rows, grid_cols) ? divider / 2 : 0
      )
      if (feature_name != "")
        translate([
          grid_track_center(inner_w, gridColumnSizes, grid_cols, divider, grid_col) + (right_ext - left_ext) / 2,
          grid_track_center(inner_d, gridRowSizes, grid_rows, divider, grid_row) + (back_ext - front_ext) / 2,
          z
        ])
          CellFeatureApply(
            feature_name,
            plane,
            cell_w + left_ext + right_ext,
            cell_d + front_ext + back_ext,
            height,
            cellFeatureOverrides,
            grid_row,
            grid_col,
            holeAreaPadding,
            holePattern,
            holeRows,
            holeCols,
            holeDiameter,
            fillTubeClearance,
            left_ext > 0 ? 0 : tube_clearance,
            right_ext > 0 ? 0 : tube_clearance,
            front_ext > 0 ? 0 : tube_clearance,
            back_ext > 0 ? 0 : tube_clearance
          );
}

function filltube_feature_merges_left(spans, overrides, roles, roleOverrides, row, col, colCount) =
  col > 0
  && grid_vertical_divider_blocked(spans, row, col)
  && cell_bottom_feature_name(overrides, roles, roleOverrides, row, col - 1, colCount) == "fill_tube";

function filltube_feature_merges_right(spans, overrides, roles, roleOverrides, row, col, colCount) =
  col < colCount - 1
  && grid_vertical_divider_blocked(spans, row, col + 1)
  && cell_bottom_feature_name(overrides, roles, roleOverrides, row, col + 1, colCount) == "fill_tube";

function filltube_feature_merges_front(spans, overrides, roles, roleOverrides, row, col, colCount) =
  row > 0
  && grid_horizontal_divider_blocked(spans, row, col)
  && cell_bottom_feature_name(overrides, roles, roleOverrides, row - 1, col, colCount) == "fill_tube";

function filltube_feature_merges_back(spans, overrides, roles, roleOverrides, row, col, rowCount, colCount) =
  row < rowCount - 1
  && grid_horizontal_divider_blocked(spans, row + 1, col)
  && cell_bottom_feature_name(overrides, roles, roleOverrides, row + 1, col, colCount) == "fill_tube";

function side_chamfers(chamfer, chamferBackSide) =
  chamferBackSide ? [chamfer, chamfer, chamfer, chamfer] : [chamfer, chamfer, 0, 0];
