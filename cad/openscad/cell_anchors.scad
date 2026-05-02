// cell_anchors.scad
//
// Builds the per-cell BOSL2 named_anchor() list for the pot insert.
//
// One named anchor per (post-span) cell per relevant face:
//   cell_<row>_<col>_top      (UP)    - top of cell wall
//   cell_<row>_<col>_bottom   (DOWN)  - top of cell floor (= seat plane)
//   cell_<row>_<col>_center   (UP)    - vertical midpoint of cell wall
//   cell_<row>_<col>_wall_n   (BACK)  - only for cells on back boundary
//   cell_<row>_<col>_wall_s   (FRONT) - only for cells on front boundary
//   cell_<row>_<col>_wall_e   (RIGHT) - only for cells on right boundary
//   cell_<row>_<col>_wall_w   (LEFT)  - only for cells on left boundary
//
// Spans: a spanned cell's anchors live at the merged cell's center.
// Cells covered by a span (the non-anchor cells in the span area) produce
// no anchors of their own.
//
// Row and col in anchor names are 1-based to match the override DSLs
// (Grid_Cell_Spans and Cell_Feature_Overrides).
//
// Coordinate frame: returned positions are in the PotInsert attachable's
// coordinate space (origin at bbox center). The pot insert geometry's
// rect_tube top sits at +height/2 + seatHeight + baseThickness because the
// base + seat extend below the bbox bottom; cell anchor Z values mirror
// that geometry.

include <BOSL2/std.scad>
include <anchor_names.scad>
include <grid_helpers.scad>

function cell_anchor_list(
  width, depth, height,
  wallThickness, seatHeight, baseThickness,
  gridRowSizes, gridColumnSizes,
  gridCellSpans,
  gridWallThickness
) =
  let (
    rows = grid_track_count(gridRowSizes),
    cols = grid_track_count(gridColumnSizes),
    divider = max(0.4, gridWallThickness),
    inner_w = max(0, width - wallThickness * 2),
    inner_d = max(0, depth - wallThickness * 2),
    z_center = seatHeight + baseThickness,
    z_top    =  height / 2 + seatHeight + baseThickness,
    z_bottom = -height / 2 + seatHeight + baseThickness
  )
  [
    for (row = [0 : rows - 1])
      for (col = [0 : cols - 1])
        if (!grid_cell_is_covered_by_span(gridCellSpans, row, col))
          each cell_anchor_entries(
            row, col, rows, cols,
            inner_w, inner_d,
            width, depth,
            gridRowSizes, gridColumnSizes,
            gridCellSpans,
            divider,
            z_top, z_bottom, z_center
          )
  ];

function cell_anchor_entries(
  row, col, rows, cols,
  inner_w, inner_d,
  width, depth,
  gridRowSizes, gridColumnSizes,
  gridCellSpans,
  divider,
  z_top, z_bottom, z_center
) =
  let (
    row_span = grid_cell_span_rows(gridCellSpans, row, col, rows),
    col_span = grid_cell_span_cols(gridCellSpans, row, col, cols),
    end_row = row + row_span - 1,
    end_col = col + col_span - 1,
    cx = grid_span_track_center(inner_w, gridColumnSizes, cols, divider, col, col_span),
    cy = grid_span_track_center(inner_d, gridRowSizes,    rows, divider, row, row_span),
    r1 = row + 1,
    c1 = col + 1
  )
  concat(
    [
      named_anchor(cell_anchor(r1, c1, CELL_ANCHOR_TOP),    [cx, cy, z_top],    UP),
      named_anchor(cell_anchor(r1, c1, CELL_ANCHOR_BOTTOM), [cx, cy, z_bottom], DOWN),
      named_anchor(cell_anchor(r1, c1, CELL_ANCHOR_CENTER), [cx, cy, z_center], UP)
    ],
    row     == 0        ? [named_anchor(cell_anchor(r1, c1, CELL_ANCHOR_WALL_S), [cx, -depth / 2, z_center], FRONT)] : [],
    end_row == rows - 1 ? [named_anchor(cell_anchor(r1, c1, CELL_ANCHOR_WALL_N), [cx,  depth / 2, z_center], BACK)]  : [],
    col     == 0        ? [named_anchor(cell_anchor(r1, c1, CELL_ANCHOR_WALL_W), [-width / 2, cy, z_center], LEFT)]  : [],
    end_col == cols - 1 ? [named_anchor(cell_anchor(r1, c1, CELL_ANCHOR_WALL_E), [ width / 2, cy, z_center], RIGHT)] : []
  );
