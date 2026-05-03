include <BOSL2/std.scad>
include <anchor_names.scad>
include <grid_helpers.scad>
include <cell_anchors.scad>
include <cell_features/registry.scad>

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
gridCellSpans = "";
gridWallThickness = 2;
cellFeatureOverrides = "";

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
  cellDefaultFeature = "Pot",
  gridCellSpans = gridCellSpans,
  gridWallThickness = gridWallThickness,
  cellFeatureOverrides = cellFeatureOverrides,
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
    [named_anchor(POT_INSERT_ANCHOR_BOTTOM, [0, 0, seat_z], DOWN)],
    cell_anchor_list(
      w, d, h,
      wallThickness, seatHeight, baseThickness,
      gridRowSizes, gridColumnSizes,
      gridCellSpans,
      gridWallThickness
    )
  );

  attachable(anchor, spin, orient, size=[w, d, h], anchors=anchors) {
    assert(h > 0, "PotInsert height must be greater than seatHeight + baseThickness.")
      down(h / 2 - seatHeight - baseThickness)
        fwd(d / 2)
          // Wall + base + dividers, with TOP_LIP-plane features subtracted
          // from the WHOLE assembly. InsertGrid must be inside this diff so
          // lid_lip recesses cut interior dividers too, not just the outer
          // wall. The Base() module runs its own diff("hole") inside; nested
          // diffs work because each looks for its own tag.
          diff("lid_lip") {
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
                  Base(
                    w, d, seatHeight, wallThickness, baseThickness,
                    chamfer, chamferBackSide,
                    holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter,
                    gridRowSizes, gridColumnSizes,
                    cellDefaultFeature, gridCellSpans,
                    gridWallThickness,
                    cellFeatureOverrides
                  );

              InsertGrid(w, d, h, wallThickness, gridRowSizes, gridColumnSizes, gridCellSpans, gridWallThickness);
            }

            TopLipPattern(
              w, d, h, wallThickness,
              gridRowSizes, gridColumnSizes,
              gridCellSpans, gridWallThickness,
              cellFeatureOverrides
            );
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

  for (boundary = [1:cols - 1])
    for (row = [0:rows - 1])
      if (!grid_vertical_divider_blocked(gridCellSpans, row, boundary))
        let (
          x = grid_track_edge(inner_w, gridColumnSizes, cols, divider, boundary) - divider / 2,
          y0 = wallThickness + grid_track_edge_from_front(inner_d, gridRowSizes, rows, divider, row),
          y1 = y0 + grid_track_size(inner_d, gridRowSizes, rows, divider, row),
          front_ext = grid_has_horizontal_junction(gridCellSpans, row, rows, boundary, cols) ? divider / 2 : 0,
          back_ext = grid_has_horizontal_junction(gridCellSpans, row + 1, rows, boundary, cols) ? divider / 2 : 0
        )
          translate([x, (y0 + y1 - front_ext + back_ext) / 2, 0])
            cuboid([divider, y1 - y0 + front_ext + back_ext, height], anchor=BOTTOM);

  for (boundary = [1:rows - 1])
    for (col = [0:cols - 1])
      if (!grid_horizontal_divider_blocked(gridCellSpans, boundary, col))
        let (
          y = wallThickness + grid_track_edge_from_front(inner_d, gridRowSizes, rows, divider, boundary) - divider / 2,
          x0 = grid_track_edge(inner_w, gridColumnSizes, cols, divider, col),
          x1 = x0 + grid_track_size(inner_w, gridColumnSizes, cols, divider, col),
          left_ext = grid_has_vertical_junction(gridCellSpans, boundary, rows, col, cols) ? divider / 2 : 0,
          right_ext = grid_has_vertical_junction(gridCellSpans, boundary, rows, col + 1, cols) ? divider / 2 : 0
        )
          translate([(x0 + x1 - left_ext + right_ext) / 2, y, 0])
            cuboid([x1 - x0 + left_ext + right_ext, divider, height], anchor=BOTTOM);
}

function grid_has_horizontal_junction(spans, rowBoundary, rowCount, colBoundary, colCount) =
  rowBoundary > 0
  && rowBoundary < rowCount
  && (
    !grid_horizontal_divider_blocked(spans, rowBoundary, colBoundary - 1)
    || (colBoundary < colCount && !grid_horizontal_divider_blocked(spans, rowBoundary, colBoundary))
  );

function grid_has_vertical_junction(spans, rowBoundary, rowCount, colBoundary, colCount) =
  colBoundary > 0
  && colBoundary < colCount
  && (
    !grid_vertical_divider_blocked(spans, rowBoundary - 1, colBoundary)
    || (rowBoundary < rowCount && !grid_vertical_divider_blocked(spans, rowBoundary, colBoundary))
  );

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
  cellDefaultFeature = "Pot",
  gridCellSpans,
  gridWallThickness,
  cellFeatureOverrides = ""
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
            BottomFeaturePattern(width, depth, wallThickness, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter, gridRowSizes, gridColumnSizes, cellDefaultFeature, gridCellSpans, gridWallThickness, cellFeatureOverrides);
}

module BottomFeaturePattern(
  width, depth, wallThickness,
  holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter,
  gridRowSizes, gridColumnSizes,
  cellDefaultFeature = "Pot", gridCellSpans,
  gridWallThickness,
  cellFeatureOverrides = ""
) {
  grid_rows = grid_track_count(gridRowSizes);
  grid_cols = grid_track_count(gridColumnSizes);
  divider = max(0.4, gridWallThickness);
  inner_w = max(0, width - wallThickness * 2);
  inner_d = max(0, depth - wallThickness * 2);

  for (grid_row = [0:grid_rows - 1])
    for (grid_col = [0:grid_cols - 1])
      if (!grid_cell_is_covered_by_span(gridCellSpans, grid_row, grid_col))
        let (
          row_span = grid_cell_span_rows(gridCellSpans, grid_row, grid_col, grid_rows),
          col_span = grid_cell_span_cols(gridCellSpans, grid_row, grid_col, grid_cols),
          feature_name = cell_feature_for_plane(cellFeatureOverrides, cellDefaultFeature, grid_row + 1, grid_col + 1, FEATURE_PLANE_BOTTOM),
          spanned_w = grid_span_track_size(inner_w, gridColumnSizes, grid_cols, divider, grid_col, col_span),
          spanned_d = grid_span_track_size(inner_d, gridRowSizes,    grid_rows, divider, grid_row, row_span),
          span_cx = grid_span_track_center(inner_w, gridColumnSizes, grid_cols, divider, grid_col, col_span),
          span_cy = grid_span_track_center(inner_d, gridRowSizes,    grid_rows, divider, grid_row, row_span)
        )
          translate([span_cx, span_cy, 0])
            feature_apply(
              feature_name,
              FEATURE_PLANE_BOTTOM,
              spanned_w,
              spanned_d,
              30,
              cellFeatureOverrides, grid_row + 1, grid_col + 1,
              defaultDrainPattern=holePattern,
              defaultDrainRows=holeRows,
              defaultDrainCols=holeCols,
              defaultDrainDiameter=holeDiameter,
              defaultDrainPadding=holeAreaPadding
            );
}

// TopLipPattern
//
// Emits tagged subtractions for every cell that has a TOP_LIP-plane feature
// override. The diff("lid_lip") wrapping in PotInsert subtracts these from
// the wall + base assembly.
//
// Local coord frame: this runs as a sibling of rect_tube inside the
// `down() fwd() union()` block. So origin is at the union origin:
//   X centered (rect_tube X-centered)
//   Y from 0 (front face) to d (back face)
//   Z from 0 (rect_tube bottom) to h (rect_tube top)
module TopLipPattern(
  width, depth, height, wallThickness,
  gridRowSizes, gridColumnSizes,
  gridCellSpans, gridWallThickness,
  cellFeatureOverrides
) {
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
          feature_name = cell_feature_for_plane(cellFeatureOverrides, "", row + 1, col + 1, FEATURE_PLANE_TOP_LIP)
        )
          if (feature_name != "")
            let (
              cell_w = grid_span_track_size(inner_w, gridColumnSizes, cols, divider, col, col_span),
              cell_d = grid_span_track_size(inner_d, gridRowSizes,    rows, divider, row, row_span),
              cx = grid_span_track_center(inner_w, gridColumnSizes, cols, divider, col, col_span),
              cy_centered = grid_span_track_center(inner_d, gridRowSizes, rows, divider, row, row_span),
              cy_union = wallThickness + cy_centered + inner_d / 2
            )
              translate([cx, cy_union, height])
                tag("lid_lip")
                  feature_apply(
                    feature_name,
                    FEATURE_PLANE_TOP_LIP,
                    cell_w,
                    cell_d,
                    height,
                    cellFeatureOverrides, row + 1, col + 1
                  );
}

function side_chamfers(chamfer, chamferBackSide) =
  chamferBackSide ? [chamfer, chamfer, chamfer, chamfer] : [chamfer, chamfer, 0, 0];
