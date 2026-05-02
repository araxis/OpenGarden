include <BOSL2/std.scad>
include <anchor_names.scad>
include <grid_helpers.scad>

function cell_anchor(suffix, row, col) =
  str(CELL_ANCHOR_PREFIX, "_", row, "_", col, "_", suffix);

function cell_anchor_set(width, depth, height, wallThickness, seatHeight, baseThickness, gridRowSizes, gridColumnSizes, gridWallThickness) =
  let (
    rows = grid_track_count(gridRowSizes),
    cols = grid_track_count(gridColumnSizes),
    divider = max(0.4, gridWallThickness),
    inner_w = max(0, width - wallThickness * 2),
    inner_d = max(0, depth - wallThickness * 2),
    bottom_z = -height / 2 + seatHeight + baseThickness,
    top_z = bottom_z + height
  )
    [
      for (row = [0:rows - 1])
        for (col = [0:cols - 1])
          each cell_anchor_list(
            row + 1,
            col + 1,
            cell_anchor_x(inner_w, gridColumnSizes, cols, divider, col),
            cell_anchor_y(depth, wallThickness, inner_d, gridRowSizes, rows, divider, row),
            grid_track_size(inner_w, gridColumnSizes, cols, divider, col),
            grid_track_size(inner_d, gridRowSizes, rows, divider, row),
            bottom_z,
            top_z
          )
    ];

function cell_anchor_list(row, col, x, y, cell_w, cell_d, bottom_z, top_z) =
  let (center_z = (bottom_z + top_z) / 2)
    [
      named_anchor(cell_anchor(CELL_ANCHOR_TOP, row, col), [x, y, top_z], UP),
      named_anchor(cell_anchor(CELL_ANCHOR_BOTTOM, row, col), [x, y, bottom_z], DOWN),
      named_anchor(cell_anchor(CELL_ANCHOR_CENTER, row, col), [x, y, center_z], UP),
      named_anchor(cell_anchor(CELL_ANCHOR_WALL_N, row, col), [x, y + cell_d / 2, center_z], BACK),
      named_anchor(cell_anchor(CELL_ANCHOR_WALL_S, row, col), [x, y - cell_d / 2, center_z], FRONT),
      named_anchor(cell_anchor(CELL_ANCHOR_WALL_E, row, col), [x + cell_w / 2, y, center_z], RIGHT),
      named_anchor(cell_anchor(CELL_ANCHOR_WALL_W, row, col), [x - cell_w / 2, y, center_z], LEFT)
    ];

function cell_anchor_x(innerWidth, gridColumnSizes, cols, divider, col) =
  grid_track_center(innerWidth, gridColumnSizes, cols, divider, col);

function cell_anchor_y(depth, wallThickness, innerDepth, gridRowSizes, rows, divider, row) =
  -depth / 2
  + wallThickness
  + grid_track_edge_from_front(innerDepth, gridRowSizes, rows, divider, row)
  + grid_track_size(innerDepth, gridRowSizes, rows, divider, row) / 2;
