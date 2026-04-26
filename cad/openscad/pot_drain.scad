include <BOSL2/std.scad>
include <anchor_names.scad>

height = 30.0;
width = 70.0;
depth = 70.0;

holdHeight = height * .3;
seatHeight = 5;

wallThickness = 2; //.1
backThickness = 6.5;
baseThickness = 2; //.1
frontChamfer = 5;
chamferBackSide = false;

module DrainPan(
  width,
  depth,
  height,
  baseThickness = baseThickness,
  wallThickness = wallThickness,
  frontChamfer = frontChamfer,
  chamferBackSide = chamferBackSide,
  seatHeight = seatHeight,
  anchor = CENTER,
  spin = 0,
  orient = UP
) {
  hole_w = (width - wallThickness * 2);
  hole_d = (depth - wallThickness * 2);
  cavity_h = height - baseThickness + 0.1;
  chamfer_edges = chamferBackSide
    ? [BACK + LEFT, BACK + RIGHT, FRONT + LEFT, FRONT + RIGHT]
    : [BACK + LEFT, BACK + RIGHT];
  anchors = [
    named_anchor(DRAIN_ANCHOR_TOP, [0, 0, height / 2], UP),
    named_anchor(DRAIN_ANCHOR_RESERVOIR_CENTER, [0, 0, -height / 4], UP)
  ];

  attachable(anchor, spin, orient, size=[width, depth, height], anchors=anchors) {
    down(height / 2) fwd(depth / 2)
        diff("hole")
          cuboid(
            size=[width, depth, height],
            chamfer=frontChamfer,
            edges=chamfer_edges,
            anchor=FORWARD + BOTTOM
          )
            tag("hole")
              up(baseThickness / 2)
                cuboid(
                  [hole_w, hole_d, cavity_h],
                  chamfer=frontChamfer,
                  edges=chamfer_edges
                )
                  position(TOP)
                    prismoid(
                      [hole_w, hole_d],
                      [width, depth],
                      height=seatHeight,
                      chamfer=side_chamfers(frontChamfer, chamferBackSide),
                      anchor=TOP
                    );
    children();
  }
}

function side_chamfers(chamfer, chamferBackSide) =
  chamferBackSide ? [chamfer, chamfer, chamfer, chamfer] : [chamfer, chamfer, 0, 0];
