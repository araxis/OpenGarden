

include <BOSL2/std.scad>

/*[Slot Types]*/
//How do you intend to mount to a surface and which surface?
Connection_Type = "Multiconnect - openGrid"; // [Multiconnect - Multiboard, Multiconnect - openGrid, Multiconnect - Custom Size]

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

//Thickness of bin  (in mm)
baseThickness = 2; //.1
frontChamfer = 5;
/*[Slot Customization]*/
onRampHalfOffset = true;
//Distance between Multiconnect slots on the back (25mm is standard for MultiBoard)
customDistanceBetweenSlots = 25;
//Reduce the number of slots
subtractedSlots = 0;
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
    Connection_Type == "Multiconnect - openGrid" ? 28 :
    Connection_Type == "Multiconnect - Custom Size" ? customDistanceBetweenSlots :
    25; //default for multipoint

Connection_Standard = "Multiconnect";
   
  
PotHolder();

module PotHolder(width = width,
                 depth = depth,
                 height = height,
                 holdHeight = holdHeight,
                 baseThickness = baseThickness,
                 wallThickness = wallThickness,
                 frontChamfer = frontChamfer,
                 seatHeight = seatHeight) {

    //Calculated
    totalWidth = width + wallThickness*2;
    totalHeight = height + baseThickness;
    union(){
            back(.01)
                DrainPan(
                    width = width + wallThickness * 2,
                    depth = depth + wallThickness * 2,
                    height = holdHeight,
                    baseThickness = baseThickness,
                    wallThickness = wallThickness,
                    frontChamfer = frontChamfer,
                    seatHeight = seatHeight);
            translate([-max(totalWidth,distanceBetweenSlots)/2,0.01,-baseThickness])
            makebackPlate(
                    backWidth = totalWidth, 
                    backHeight = totalHeight, 
                    distanceBetweenSlots = distanceBetweenSlots,
                    backThickness=6.5);
    }
}
 

module DrainPan(width,depth,height,baseThickness,wallThickness,frontChamfer, seatHeight = seatHeight){
   hole_w = (width - wallThickness *2 );
   hole_d = (depth - wallThickness * 2);   
   diff("hole")
      cuboid(size= [width,depth,height],
      chamfer = frontChamfer,
      edges=[BACK+LEFT,BACK+RIGHT],
      anchor = FORWARD+BOTTOM)
        tag("hole")cuboid([hole_w,hole_d,height+1],chamfer = frontChamfer,edges=[BACK+LEFT,BACK+RIGHT])
            position(TOP)
              prismoid([hole_w,hole_d],[width,depth],height=seatHeight
                 , chamfer=[frontChamfer,frontChamfer,0,0],anchor =TOP);
         


    //bottom
   cuboid([width, depth, baseThickness], chamfer=frontChamfer, edges = [BACK+RIGHT, BACK+LEFT], anchor=TOP+FRONT);
}
//BEGIN MODULES
//Slotted back Module
module makebackPlate(backWidth, backHeight, distanceBetweenSlots, backThickness, edgeRounding = 1)
{
    //slot count calculates how many slots can fit on the back. Based on internal width for buffer. 
    //slot width needs to be at least the distance between slot for at least 1 slot to generate
    let (backWidth = max(backWidth,distanceBetweenSlots), backHeight = max(backHeight, 25),slotCount = floor(backWidth/distanceBetweenSlots)- subtractedSlots){
            difference() {
                translate(v = [0,-backThickness,0]) 
                cuboid(size = [backWidth,backThickness,backHeight], rounding=edgeRounding, edges=FRONT, except_edges=BOT, anchor=FRONT+LEFT+BOT, $fn = 60);
                //Loop through slots and center on the item
                //Note: I kept doing math until it looked right. It's possible this can be simplified.
                for (slotNum = [0:1:slotCount-1]) {
                    translate(v = [distanceBetweenSlots/2+(backWidth/distanceBetweenSlots-slotCount)*distanceBetweenSlots/2+slotNum*distanceBetweenSlots,-2.35+slotDepthMicroadjustment,backHeight-multiconnectStopDistanceFromBack]) {
    multiConnectSlotTool(backHeight);
                    
                    }
                }
            }
    }   
}

//Create Slot Tool
module multiConnectSlotTool(totalHeight) {
    //In slotTool, added a new variable distanceOffset which is set by the option:
    distanceOffset = onRampHalfOffset ? distanceBetweenSlots / 2 : 0;
    scale(v = slotTolerance)
    //slot minus optional dimple with optional on-ramp
    let (slotProfile = [[0,0],[10.15,0],[10.15,1.2121],[7.65,3.712],[7.65,5],[0,5]])
    difference() {
        union() {
            //round top
            rotate(a = [90,0,0,]) 
                rotate_extrude($fn=50) 
                    polygon(points = slotProfile);
            //long slot
            translate(v = [0,0,0]) 
                rotate(a = [180,0,0]) 
                linear_extrude(height = totalHeight+1) 
                    union(){
                        polygon(points = slotProfile);
                        mirror([1,0,0])
                            polygon(points = slotProfile);
                    }
            //on-ramp
            if(onRampEnabled)
                for(y = [1:onRampEveryXSlots:totalHeight/distanceBetweenSlots])
                    //then modify the translate within the on-ramp code to include the offset
                    translate(v = [0,-5,(-y*distanceBetweenSlots)+distanceOffset])
                        rotate(a = [-90,0,0]) 
                            cylinder(h = 5, r1 = 12, r2 = 10.15);
        }
        //dimple
        if (slotQuickRelease == false)
            scale(v = dimpleScale) 
            rotate(a = [90,0,0,]) 
                rotate_extrude($fn=50) 
                    polygon(points = [[0,0],[0,1.5],[1.5,0]]);
    }
}
