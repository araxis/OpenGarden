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

  for (col = [1:cols - 1])
    let (x = grid_track_edge(inner_w, gridColumnSizes, cols, divider, col) + divider / 2)
    for (row = [0:rows - 1])
      if (!grid_vertical_divider_blocked(gridCellSpans, row, col))
        translate([
          x,
          wallThickness + grid_track_edge_from_front(inner_d, gridRowSizes, rows, divider, row) + grid_track_size(inner_d, gridRowSizes, rows, divider, row) / 2,
          0
        ])
          cuboid([divider, grid_track_size(inner_d, gridRowSizes, rows, divider, row), height], anchor=BOTTOM);

  for (row = [1:rows - 1])
    let (y = wallThickness + grid_track_edge_from_front(inner_d, gridRowSizes, rows, divider, row))
    for (col = [0:cols - 1])
      if (!grid_horizontal_divider_blocked(gridCellSpans, row, col))
        translate([
          grid_track_center(inner_w, gridColumnSizes, cols, divider, col),
          y + divider / 2,
          0
        ])
          cuboid([grid_track_size(inner_w, gridColumnSizes, cols, divider, col), divider, height], anchor=BOTTOM);
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
        row_span = grid_cell_span_rows(gridCellSpans, grid_row, grid_col, grid_rows),
        col_span = grid_cell_span_cols(gridCellSpans, grid_row, grid_col, grid_cols),
        cell_w = grid_span_track_size(inner_w, gridColumnSizes, grid_cols, divider, grid_col, col_span),
        cell_d = grid_span_track_size(inner_d, gridRowSizes, grid_rows, divider, grid_row, row_span),
        role = grid_cell_role(gridCellRoles, gridCellRoleOverrides, grid_row, grid_col, grid_cols)
      )
      if (!grid_cell_is_covered_by_span(gridCellSpans, grid_row, grid_col))
        translate([
          grid_span_track_center(inner_w, gridColumnSizes, grid_cols, divider, grid_col, col_span),
          grid_span_track_center(inner_d, gridRowSizes, grid_rows, divider, grid_row, row_span),
          0
        ]) {
          if (role == "Pot")
            CellDrainHolePattern(cell_w, cell_d, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter);
          else if (role == "FillTube")
            FillTubeCutout(cell_w, cell_d, fillTubeClearance);
        }
}

module FillTubeCutout(width, depth, clearance) {
  cut_w = max(0, width - clearance * 2);
  cut_d = max(0, depth - clearance * 2);

  if (cut_w > 0 && cut_d > 0)
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
