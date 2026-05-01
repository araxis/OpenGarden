

include <BOSL2/std.scad>
include <anchor_names.scad>
use <back_plate.scad>
use <pot_drain.scad>

/* [Internal Dimensions] */
//Height (in mm) from the top of the back to the base of the internal floor
height = 100.0; //.1
//Width (in mm) of the internal dimension or item you wish to hold
width = 70.0; //.1
//Length (i.e., distance from back) (in mm) of the internal dimension or item you wish to hold
depth = 70.0; //.1

holdHeight = height * .3;
seatHeight = 5;
/* [Additional Customization] */

//Thickness of bin walls (in mm)
wallThickness = 2; //.1
backThickness = 6.5;
//Thickness of bin  (in mm)
baseThickness = 2; //.1
frontChamfer = 5;

module PotHolder(
  width = width,
  depth = depth,
  height = height,
  holdHeight = holdHeight,
  subtractedSlots = 0,
  baseThickness = baseThickness,
  wallThickness = wallThickness,
  backThickness = backThickness,
  frontChamfer = frontChamfer,
  seatHeight = seatHeight,
  anchor = CENTER,
  spin = 0,
  orient = UP
) {

  total_width = width;
  total_depth = depth ;
  total_height = height;

  // Local coordinate assumptions:
  // X center = holder center
  // Y center = middle of full depth including back plate
  // Z center = middle of full height
  //
  // Named anchors are placed where child parts should attach.
  // Named anchors for internal usable spaces
  insert_seat_z = -height / 2 + holdHeight;
  reservoir_z = -height / 2 + holdHeight / 2;
  inside_z = -height / 2 + holdHeight + (height - holdHeight) / 2;

  // Geometry is shifted fwd(depth/2), so internal usable Y is around 0
  inside_y = 0;
  reservoir_y = 0;
  insert_y = backThickness;

  anchors = [
    named_anchor(HOLDER_ANCHOR_INSIDE_CENTER, [0, inside_y, inside_z], UP),
    named_anchor(DRAIN_ANCHOR_TOP, [0, insert_y, insert_seat_z], UP),
    named_anchor(DRAIN_ANCHOR_RESERVOIR_CENTER, [0, reservoir_y, reservoir_z], UP),
  ];

  attachable(
    anchor,
    spin,
    orient,
    size=[total_width, total_depth, total_height],
    anchors=anchors
  ) {
    union() {
      // Put geometry centered in attachable coordinate space
      down(height / 2)
        fwd(depth / 2)
          union() {
            makebackPlate(
              width=width,
              height=height,
              thickness=backThickness,
              subtractedSlots=subtractedSlots,
              anchor=BOTTOM + FRONT
            )
              position(BACK + BOTTOM)
                fwd(.1)
                  DrainPan(
                    width=width,
                    depth=depth,
                    height=holdHeight,
                    baseThickness=baseThickness,
                    wallThickness=wallThickness,
                    frontChamfer=frontChamfer,
                    chamferBackSide=false,
                    seatHeight=seatHeight,
                    anchor=BOTTOM + FRONT
                  );
          }
    }

    children();
  }
}
