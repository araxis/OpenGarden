include <BOSL2/std.scad>
include <anchor_names.scad>
include <grid_helpers.scad>

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
  anchors = [
    named_anchor(POT_INSERT_ANCHOR_BOTTOM, [0, 0, seat_z], DOWN)
  ];

  attachable(anchor, spin, orient, size=[w, d, h], anchors=anchors) {
    assert(h > 0, "PotInsert height must be greater than seatHeight + baseThickness.")
      down(h / 2 - seatHeight - baseThickness)
        fwd(d / 2)
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
                Base(w, d, seatHeight, wallThickness, baseThickness, chamfer, chamferBackSide, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter, gridRowSizes, gridColumnSizes, gridCellRoles, gridCellRoleOverrides, gridCellSpans, gridWallThickness, fillTubeClearance);

            InsertGrid(w, d, h, wallThickness, gridRowSizes, gridColumnSizes, gridCellSpans, gridWallThickness);
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
            DrainHolePattern(width, depth, wallThickness, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter, gridRowSizes, gridColumnSizes, gridCellRoles, gridCellRoleOverrides, gridCellSpans, gridWallThickness, fillTubeClearance);
}

module DrainHolePattern(width, depth, wallThickness, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter, gridRowSizes, gridColumnSizes, gridCellRoles, gridCellRoleOverrides, gridCellSpans, gridWallThickness, fillTubeClearance) {
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
        role = grid_cell_role(gridCellRoles, gridCellRoleOverrides, grid_row, grid_col, grid_cols),
        left_ext = role == "FillTube" && filltube_merges_left(gridCellSpans, gridCellRoles, gridCellRoleOverrides, grid_row, grid_col, grid_cols) ? divider / 2 : 0,
        right_ext = role == "FillTube" && filltube_merges_right(gridCellSpans, gridCellRoles, gridCellRoleOverrides, grid_row, grid_col, grid_cols) ? divider / 2 : 0,
        front_ext = role == "FillTube" && filltube_merges_front(gridCellSpans, gridCellRoles, gridCellRoleOverrides, grid_row, grid_col, grid_cols) ? divider / 2 : 0,
        back_ext = role == "FillTube" && filltube_merges_back(gridCellSpans, gridCellRoles, gridCellRoleOverrides, grid_row, grid_col, grid_rows, grid_cols) ? divider / 2 : 0
      )
      translate([
        grid_track_center(inner_w, gridColumnSizes, grid_cols, divider, grid_col) + (right_ext - left_ext) / 2,
        grid_track_center(inner_d, gridRowSizes, grid_rows, divider, grid_row) + (back_ext - front_ext) / 2,
        0
      ]) {
        if (role == "Pot")
          CellDrainHolePattern(cell_w, cell_d, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter);
        else if (role == "FillTube")
          FillTubeCutout(
            cell_w + left_ext + right_ext,
            cell_d + front_ext + back_ext,
            left_ext > 0 ? 0 : fillTubeClearance,
            right_ext > 0 ? 0 : fillTubeClearance,
            front_ext > 0 ? 0 : fillTubeClearance,
            back_ext > 0 ? 0 : fillTubeClearance
          );
      }
}

function filltube_merges_left(spans, roles, overrides, row, col, colCount) =
  col > 0
  && grid_vertical_divider_blocked(spans, row, col)
  && grid_cell_role(roles, overrides, row, col - 1, colCount) == "FillTube";

function filltube_merges_right(spans, roles, overrides, row, col, colCount) =
  col < colCount - 1
  && grid_vertical_divider_blocked(spans, row, col + 1)
  && grid_cell_role(roles, overrides, row, col + 1, colCount) == "FillTube";

function filltube_merges_front(spans, roles, overrides, row, col, colCount) =
  row > 0
  && grid_horizontal_divider_blocked(spans, row, col)
  && grid_cell_role(roles, overrides, row - 1, col, colCount) == "FillTube";

function filltube_merges_back(spans, roles, overrides, row, col, rowCount, colCount) =
  row < rowCount - 1
  && grid_horizontal_divider_blocked(spans, row + 1, col)
  && grid_cell_role(roles, overrides, row + 1, col, colCount) == "FillTube";

module FillTubeCutout(width, depth, leftClearance, rightClearance, frontClearance, backClearance) {
  cut_w = max(0, width - leftClearance - rightClearance);
  cut_d = max(0, depth - frontClearance - backClearance);

  if (cut_w > 0 && cut_d > 0)
    translate([(leftClearance - rightClearance) / 2, (frontClearance - backClearance) / 2, 0])
      cuboid([cut_w, cut_d, 30]);
}

module CellDrainHolePattern(width, depth, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter) {
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
          hole_offset(row, rows, span_x),
          hole_offset(col, cols, span_y),
          0
        ])
          cyl(d=holeDiameter, h=30);
  }
}

function hole_offset(index, count, span) =
  count <= 1 ? 0 : -span / 2 + index * span / (count - 1);

function side_chamfers(chamfer, chamferBackSide) =
  chamferBackSide ? [chamfer, chamfer, chamfer, chamfer] : [chamfer, chamfer, 0, 0];

module Ring(w, d, h) {
  rect_tube(
    size1=[w, d],
    size2=[w, d],
    h=h,
    wall=wallThickness,
    chamfer=[frontChamfer, frontChamfer, 0, 0],
    ichamfer=[frontChamfer, frontChamfer, 0, 0]
  );
}
