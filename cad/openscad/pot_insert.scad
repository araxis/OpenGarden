include <BOSL2/std.scad>
include <anchor_names.scad>

$fn = 100;

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
gridRows = 1;
gridColumns = 1;
gridRowWeights = [1];
gridColumnWeights = [1];
gridCellRoles = ["Pot"];
gridWallThickness = 2;
fillTubeDiameter = 18;

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
  gridRows = gridRows,
  gridColumns = gridColumns,
  gridRowWeights = gridRowWeights,
  gridColumnWeights = gridColumnWeights,
  gridCellRoles = gridCellRoles,
  gridWallThickness = gridWallThickness,
  fillTubeDiameter = fillTubeDiameter,
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
                Base(w, d, seatHeight, wallThickness, baseThickness, chamfer, chamferBackSide, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter, gridRows, gridColumns, gridRowWeights, gridColumnWeights, gridCellRoles, gridWallThickness, fillTubeDiameter);

            InsertGrid(w, d, h, wallThickness, gridRows, gridColumns, gridRowWeights, gridColumnWeights, gridWallThickness);
          }

    children();
  }
}

module InsertGrid(width, depth, height, wallThickness, gridRows, gridColumns, gridRowWeights, gridColumnWeights, gridWallThickness) {
  rows = max(1, round(gridRows));
  cols = max(1, round(gridColumns));
  divider = max(0.4, gridWallThickness);
  inner_w = max(0, width - wallThickness * 2);
  inner_d = max(0, depth - wallThickness * 2);

  for (col = [1:cols - 1]) {
    x = grid_track_edge(inner_w, gridColumnWeights, cols, divider, col) + divider / 2;
    translate([x, wallThickness, 0])
      cuboid([divider, inner_d, height], anchor=FRONT + BOTTOM);
  }

  for (row = [1:rows - 1]) {
    y = wallThickness + grid_track_edge_from_front(inner_d, gridRowWeights, rows, divider, row);
    translate([-inner_w / 2, y, 0])
      cuboid([inner_w, divider, height], anchor=LEFT + FRONT + BOTTOM);
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
  gridRows,
  gridColumns,
  gridRowWeights,
  gridColumnWeights,
  gridCellRoles,
  gridWallThickness,
  fillTubeDiameter
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
            DrainHolePattern(width, depth, wallThickness, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter, gridRows, gridColumns, gridRowWeights, gridColumnWeights, gridCellRoles, gridWallThickness, fillTubeDiameter);
}

module DrainHolePattern(width, depth, wallThickness, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter, gridRows, gridColumns, gridRowWeights, gridColumnWeights, gridCellRoles, gridWallThickness, fillTubeDiameter) {
  grid_rows = max(1, round(gridRows));
  grid_cols = max(1, round(gridColumns));
  divider = max(0.4, gridWallThickness);
  inner_w = max(0, width - wallThickness * 2);
  inner_d = max(0, depth - wallThickness * 2);

  for (grid_row = [0:grid_rows - 1])
    for (grid_col = [0:grid_cols - 1])
      let (
        cell_w = grid_track_size(inner_w, gridColumnWeights, grid_cols, divider, grid_col),
        cell_d = grid_track_size(inner_d, gridRowWeights, grid_rows, divider, grid_row),
        role = grid_cell_role(gridCellRoles, grid_row, grid_col, grid_cols)
      )
        translate([
          grid_track_center(inner_w, gridColumnWeights, grid_cols, divider, grid_col),
          grid_track_center(inner_d, gridRowWeights, grid_rows, divider, grid_row),
          0
        ]) {
          if (role == "Pot")
            CellDrainHolePattern(cell_w, cell_d, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter);
          else if (role == "FillTube")
            cyl(d=min(fillTubeDiameter, max(holeDiameter, min(cell_w, cell_d) - holeDiameter)), h=30);
        }
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

function grid_weight(weights, index) =
  is_list(weights) && index < len(weights) ? max(0.01, weights[index]) : 1;

function grid_weight_sum(weights, count) =
  sum([for (index = [0:count - 1]) grid_weight(weights, index)]);

function grid_weight_before(weights, index) =
  index <= 0 ? 0 : sum([for (i = [0:index - 1]) grid_weight(weights, i)]);

function grid_usable_span(total, count, divider) =
  max(0, total - divider * (count - 1));

function grid_track_size(total, weights, count, divider, index) =
  grid_usable_span(total, count, divider) * grid_weight(weights, index) / grid_weight_sum(weights, count);

function grid_track_edge(total, weights, count, divider, index) =
  -total / 2
  + grid_usable_span(total, count, divider) * grid_weight_before(weights, index) / grid_weight_sum(weights, count)
  + divider * index;

function grid_track_edge_from_front(total, weights, count, divider, index) =
  grid_track_edge(total, weights, count, divider, index) + total / 2;

function grid_track_center(total, weights, count, divider, index) =
  grid_track_edge(total, weights, count, divider, index)
  + grid_track_size(total, weights, count, divider, index) / 2;

function grid_cell_role(roles, row, col, colCount) =
  let (index = row * colCount + col)
    is_list(roles) && index < len(roles) ? roles[index] : "Pot";

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
