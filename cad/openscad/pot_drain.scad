include <BOSL2/std.scad>

height = 30.0;
width = 70.0;
depth = 70.0;

holdHeight = height * .3;
seatHeight = 5;

wallThickness = 2; //.1
backThickness = 6.5;
baseThickness = 2; //.1
frontChamfer = 5;

module DrainPan(
  width,
  depth,
  height,
  baseThickness,
  wallThickness,
  frontChamfer,
  seatHeight = seatHeight,
  anchor = CENTER,
  spin = 0,
  orient = UP
) {
  hole_w = (width - wallThickness * 2);
  hole_d = (depth - wallThickness * 2);
  attachable(anchor, spin, orient, size=[width, depth, height]) {
    down(height / 2) fwd(depth / 2)
        union() {
          diff("hole")
            cuboid(
              size=[width, depth, height],
              chamfer=frontChamfer,
              edges=[BACK + LEFT, BACK + RIGHT],
              anchor=FORWARD + BOTTOM
            )
              tag("hole") cuboid([hole_w, hole_d, height + 1], chamfer=frontChamfer, edges=[BACK + LEFT, BACK + RIGHT])
                  position(TOP)
                    prismoid(
                      [hole_w, hole_d], [width, depth], height=seatHeight, chamfer=[frontChamfer, frontChamfer, 0, 0], anchor=TOP
                    );
          //bottom
          cuboid([width, depth, baseThickness], chamfer=frontChamfer, edges=[BACK + RIGHT, BACK + LEFT], anchor=BOTTOM + FRONT);
        }
    children();
  }
}
