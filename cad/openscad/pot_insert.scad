include <BOSL2/std.scad>
include <anchor_names.scad>

$fn = 100;

height = 100;
width = 70.0;
depth = 70.0;
wallThickness = 2;
frontChamfer = 5;
baseThickness = 2;
holeAreaPadding = 25;
holeRows = 4;
holeCols = 4;
holeDiameter = 5;
seatHeight = 5;

module PotInsert(
  width,
  depth,
  height,
  wallThickness = wallThickness,
  chamfer = frontChamfer,
  baseThickness = baseThickness,
  holeAreaPadding = holeAreaPadding,
  holeRows = holeRows,
  holeCols = holeCols,
  holeDiameter = holeDiameter,
  seatHeight = seatHeight,
  anchor = CENTER,
  spin = 0,
  orient = UP
) {

  w = width;
  d = depth;
  h = height;
  seat_z = -h / 2 + seatHeight + baseThickness;
  anchors = [
    named_anchor(POT_INSERT_ANCHOR_BOTTOM, [0, 0, seat_z], DOWN)
  ];

  attachable(anchor, spin, orient, size=[w, d, h], anchors=anchors) {
    assert(h > 0, "PotInsert height must be greater than seatHeight + baseThickness.")
      down(h / 2 - seatHeight - baseThickness)
        fwd(d / 2)
          rect_tube(
            size=[w, d],
            h=h,
            wall=wallThickness,
            chamfer=[chamfer, chamfer, 0, 0],
            ichamfer=[chamfer, chamfer, 0, 0],
            anchor=FRONT + BOTTOM
          )
            attach(BOTTOM, TOP)
              Base(w, d, seatHeight, wallThickness, baseThickness, chamfer, holeAreaPadding, holeRows, holeCols, holeDiameter);

    children();
  }
}

module Base(width, depth, height, wallThickness, baseThickness, chamfer, holeAreaPadding, holeRows, holeCols, holeDiameter) {
  //ring
  ring_w = (width - wallThickness * 2) - 0.4;
  ring_d = (depth - wallThickness * 2) - 0.4;
  diff("hole")
    rect_tube(
      size1=[ring_w, ring_d],
      size2=[width, depth],
      h=height,
      wall=wallThickness,
      chamfer=[chamfer, chamfer, 0, 0],
      ichamfer=[chamfer, chamfer, 0, 0],
      anchor=FRONT + BOTTOM
    )
      attach(BOTTOM, TOP, overlap=0.1)
        prismoid(
          [ring_w, ring_d],
          [ring_w, ring_d],
          height=baseThickness,
          anchor=TOP + FRONT,
          chamfer=[chamfer, chamfer, 0, 0]
        )
          tag("hole")
            grid_copies(n=[holeRows, holeCols], size=[width - holeAreaPadding, depth - holeAreaPadding])
              cyl(d=holeDiameter, h=30);
}

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
