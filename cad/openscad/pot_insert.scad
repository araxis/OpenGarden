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
gridWallThickness = 2;

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
  gridWallThickness = gridWallThickness,
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
                Base(w, d, seatHeight, wallThickness, baseThickness, chamfer, chamferBackSide, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter);

            InsertGrid(w, d, h, wallThickness, gridRows, gridColumns, gridWallThickness);
          }

    children();
  }
}

module InsertGrid(width, depth, height, wallThickness, gridRows, gridColumns, gridWallThickness) {
  rows = max(1, round(gridRows));
  cols = max(1, round(gridColumns));
  divider = max(0.4, gridWallThickness);
  inner_w = max(0, width - wallThickness * 2);
  inner_d = max(0, depth - wallThickness * 2);

  for (col = [1:cols - 1]) {
    x = -inner_w / 2 + col * inner_w / cols;
    translate([x, wallThickness, 0])
      cuboid([divider, inner_d, height], anchor=FRONT + BOTTOM);
  }

  for (row = [1:rows - 1]) {
    y = wallThickness + row * inner_d / rows - divider / 2;
    translate([-inner_w / 2, y, 0])
      cuboid([inner_w, divider, height], anchor=LEFT + FRONT + BOTTOM);
  }
}

module Base(width, depth, height, wallThickness, baseThickness, chamfer, chamferBackSide, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter) {
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
            DrainHolePattern(width, depth, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter);
}

module DrainHolePattern(width, depth, holeAreaPadding, holePattern, holeRows, holeCols, holeDiameter) {
  rows = max(1, round(holeRows));
  cols = max(1, round(holeCols));
  span_x = max(0, width - holeAreaPadding);
  span_y = max(0, depth - holeAreaPadding);

  if (holePattern == "Circle") {
    radius = min(span_x, span_y) / 2;
    for (ring = [0:rows - 1]) {
      ring_radius = rows <= 1 ? 0 : ring * radius / (rows - 1);
      holes = ring == 0 ? 1 : cols * ring;
      for (hole = [0:holes - 1])
        translate([
          ring_radius * cos(360 * hole / holes),
          ring_radius * sin(360 * hole / holes),
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
