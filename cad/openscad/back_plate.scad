include <BOSL2/std.scad>

/*[Slot Types]*/
//How do you intend to mount to a surface and which surface?
Connection_Type = "Multiconnect - openGrid"; // [Multiconnect - Multiboard, Multiconnect - openGrid, Multiconnect - Custom Size]

/* [Internal Dimensions] */
//Height (in mm) from the top of the back to the base of the internal floor
height = 100.0; //.1
//Width (in mm) of the internal dimension or item you wish to hold
width = 70.0; //.1

//Thickness of bin walls (in mm)
thickness = 6.5; //.1

/*[Slot Customization]*/
onRampHalfOffset = true;
//Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
customDistanceBetweenSlots = 25;
//Reduce the number of slots
subtractedSlots = 0;
//Where remaining slots should sit when slots are subtracted
slotPlacement = "Center"; // [Center, Left, Right]
//QuickRelease removes the small indent in the top of the slots that lock the part into place
slotQuickRelease = true;
//Dimple scale tweaks the size of the dimple in the slot for printers that need a larger dimple to print correctly
dimpleScale = 1; //[0.5:.05:1.5]
//Scale the size of slots in the back (1.015 scale is default for a tight fit. Increase if your finding poor fit. )
slotTolerance = 1.00; //[0.925:0.005:1.075]
//Move the slot in (positive) or out (negative)
slotDepthMicroadjustment = 0; //[-.5:0.05:.5]
//enable a slot on-ramp for easy mounting of tall items
onRampEnabled = false;
//frequency of slots for on-ramp. 1 = every slot; 2 = every 2 slots; etc.
onRampEveryXSlots = 1;
//Distance from the back of the item holder to where the multiconnect stops (i.e., where the dimple is) (by mm)
multiconnectStopDistanceFromBack = 13;

/* [Hidden] */
distanceBetweenSlots =
  Connection_Type == "Multiconnect - openGrid" ? 28
  : Connection_Type == "Multiconnect - Custom Size" ? customDistanceBetweenSlots
  : 25; //default for multipoint

Connection_Standard = "Multiconnect";

//BEGIN MODULES
//Slotted back Module
module makebackPlate(
  width,
  height,
  thickness,
  distanceBetweenSlots = distanceBetweenSlots,
  subtractedSlots = subtractedSlots,
  slotPlacement = slotPlacement,
  edgeRounding = 1,
  onRampHalfOffset = onRampHalfOffset,
  slotQuickRelease = slotQuickRelease,
  anchor = CENTER,
  spin = 0,
  orient = UP
) {
  //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
  //slot width needs to be at least the distance between slot for at least 1 slot to generate

  let (
    backWidth = max(width, distanceBetweenSlots),
    backHeight = max(height, 25),
    fullSlotCount = floor(backWidth / distanceBetweenSlots),
    slotCount = max(0, fullSlotCount - subtractedSlots),
    slotStartX =
      slotPlacement == "Left" ? distanceBetweenSlots / 2
      : slotPlacement == "Right" ? backWidth - distanceBetweenSlots / 2 - (slotCount - 1) * distanceBetweenSlots
      : distanceBetweenSlots / 2 + (backWidth / distanceBetweenSlots - slotCount) * distanceBetweenSlots / 2
  ) {
    attachable(anchor, spin, orient, size=[backWidth, thickness, backHeight]) {
      left(backWidth / 2) down(backHeight / 2) back(thickness / 2)
            difference() {
              translate(v=[0, -thickness, 0])
                cuboid(size=[backWidth, thickness, backHeight], rounding=edgeRounding, edges=FRONT, except_edges=BOT, anchor=FRONT + LEFT + BOT, $fn=60);
              if (slotCount > 0) {
                for (slotNum = [0:1:slotCount - 1]) {
                  translate(v=[slotStartX + slotNum * distanceBetweenSlots, -2.35 + slotDepthMicroadjustment, backHeight - multiconnectStopDistanceFromBack])
                    multiConnectSlotTool(backHeight, onRampHalfOffset, distanceBetweenSlots, slotQuickRelease);
                }
              }
            }
      children();
    }
  }
}

//Create Slot Tool
module multiConnectSlotTool(totalHeight, onRampHalfOffset, distanceBetweenSlots, slotQuickRelease) {
  //In slotTool, added a new variable distanceOffset which is set by the option:
  distanceOffset = onRampHalfOffset ? distanceBetweenSlots / 2 : 0;
  scale(v=slotTolerance)
  //slot minus optional dimple with optional on-ramp
  let (slotProfile = [[0, 0], [10.15, 0], [10.15, 1.2121], [7.65, 3.712], [7.65, 5], [0, 5]])
  difference() {
    union() {
      //round top
      rotate(a=[90, 0, 0])
        rotate_extrude($fn=50)
          polygon(points=slotProfile);
      //long slot
      translate(v=[0, 0, 0])
        rotate(a=[180, 0, 0])
          linear_extrude(height=totalHeight + 1)
            union() {
              polygon(points=slotProfile);
              mirror([1, 0, 0])
                polygon(points=slotProfile);
            }
      //on-ramp
      if (onRampEnabled)
        for (y = [1:onRampEveryXSlots:totalHeight / distanceBetweenSlots])
        //then modify the translate within the on-ramp code to include the offset
        translate(v=[0, -5, ( -y * distanceBetweenSlots) + distanceOffset])
          rotate(a=[-90, 0, 0])
            cylinder(h=5, r1=12, r2=10.15);
    }
    //dimple
    if (slotQuickRelease == false)
      scale(v=dimpleScale)
        rotate(a=[90, 0, 0])
          rotate_extrude($fn=50)
            polygon(points=[[0, 0], [0, 1.5], [1.5, 0]]);
  }
}
