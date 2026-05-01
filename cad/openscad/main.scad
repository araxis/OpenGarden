include <BOSL2/std.scad>
include <anchor_names.scad>
use <pot_holder_frame.scad>
use <pot_insert.scad>
use <pot_drain.scad>

/*[Output]*/
// Preview/export target.
Output_Mode = "Print Layout"; // [Assembly, Freestanding Pot, Print Layout, Holder Only, Drain Only, Pot Insert Only]
// true: use the OpenGrid holder/back plate; false: use the freestanding drain pan.
OpenGrid_Support = false;
// Reduces the number of OpenGrid slots generated on the back plate.
Subtracted_Slots = 0; // [0:1:10]
// Where remaining OpenGrid slots sit after subtraction. Spread distributes slots across valid OpenGrid positions.
Slot_Placement = "Center"; // [Center, Left, Right, Spread]
// Distance between separate parts in Print Layout mode.
Print_Spacing = 20; // [5:1:80]

/*[Pot Size]*/
// Total outside height used by the holder/drain and pot insert assembly.
Pot_Height = 100.0; // [40:0.5:450]
// Outside width of the pot and holder.
Pot_Width = 70.0; // [30:0.5:450]
// Outside depth of the pot and holder.
Pot_Depth = 70.0; // [30:0.5:450]
// Fraction of the total height reserved for the lower drain/reservoir area.
Reservoir_Height_Ratio = 0.3; // [0.1:0.01:0.6]

/*[Walls and Seat]*/
// Height of the insert support seat.
Seat_Height = 5; // [1:0.5:5]
// Wall thickness for printed pot/drain parts.
Wall_Thickness = 2; // [1:0.25:8]
// Thickness of the drain/insert base.
Base_Thickness = 2; // [1:0.25:8]

/*[Drain Hole Pattern]*/
// Shape of the drain hole layout in each pot insert grid cell.
Hole_Pattern = "Rectangle"; // [Rectangle, Circle]
// Per cell. Rectangle: row count. Circle: ring count.
Hole_Rows = 4; // [1:1:10]
// Per cell. Rectangle: column count. Circle: holes added per ring.
Hole_Columns = 4; // [1:1:10]
// Diameter of each drain hole.
Hole_Diameter = 5; // [1:0.5:15]
// Padding around each cell's drain hole pattern.
Hole_Area_Padding = 25; // [0:0.5:80]

/*[Insert Grid]*/
// Number of front/back grid rows inside the insert.
Grid_Rows = 1; // [1:1:8]
// Number of left/right grid columns inside the insert.
Grid_Columns = 1; // [1:1:8]
// Thickness of the internal grid divider walls.
Grid_Wall_Thickness = 2; // [0.8:0.2:6]

/*[Chamfers]*/
// Chamfer size on the front-facing side edges.
Front_Chamfer = 5; // [0:0.5:20]
// Applies back-side chamfers only when OpenGrid_Support is false.
Chamfer_Back_Side = true;

/*[Hidden]*/
$fn = 100;
outputMode = Output_Mode;
openGridSupport = OpenGrid_Support;
subtractedSlots = Subtracted_Slots;
slotPlacement = Slot_Placement;
printSpacing = Print_Spacing;
height = Pot_Height;
width = Pot_Width;
depth = Pot_Depth;
holdHeightRatio = Reservoir_Height_Ratio;
seatHeight = Seat_Height;
wallThickness = Wall_Thickness;
baseThickness = Base_Thickness;
frontChamfer = Front_Chamfer;
chamferBackSide = Chamfer_Back_Side;
holdHeight = height * holdHeightRatio;
potHeight = height - holdHeight;
holePattern = Hole_Pattern;
holeRows = Hole_Rows;
holeCols = Hole_Columns;
holeDiameter = Hole_Diameter;
holeAreaPadding = Hole_Area_Padding;
gridRows = Grid_Rows;
gridColumns = Grid_Columns;
gridWallThickness = Grid_Wall_Thickness;

if (outputMode == "Assembly") {
  PotAssembly();
} else if (outputMode == "Freestanding Pot") {
  FreestandingPot();
} else if (outputMode == "Print Layout") {
  PrintLayout();
} else if (outputMode == "Holder Only") {
  PotHolder(width, depth, height, holdHeight, subtractedSlots=subtractedSlots, slotPlacement=slotPlacement, anchor=BOTTOM + FRONT);
} else if (outputMode == "Drain Only") {
  DrainPan(
    width, depth, holdHeight,
    baseThickness=baseThickness,
    wallThickness=wallThickness,
    frontChamfer=frontChamfer,
    chamferBackSide=chamferBackSide,
    seatHeight=seatHeight,
    anchor=BOTTOM + FRONT
  );
} else if (outputMode == "Pot Insert Only") {
  PotInsert(
    width, depth, potHeight, chamferBackSide=chamferBackSide, anchor=BOTTOM + FRONT,
    holeAreaPadding=holeAreaPadding,
    holePattern=holePattern,
    holeRows=holeRows,
    holeCols=holeCols,
    holeDiameter=holeDiameter,
    gridRows=gridRows,
    gridColumns=gridColumns,
    gridWallThickness=gridWallThickness
  );
}

module PotAssembly() {
  if (openGridSupport) {
    PotHolder(width, depth, height, holdHeight, subtractedSlots=subtractedSlots, slotPlacement=slotPlacement, anchor=BOTTOM + FRONT)
      attach(DRAIN_ANCHOR_TOP, POT_INSERT_ANCHOR_BOTTOM)
        PotInsert(
          width, depth, potHeight, chamferBackSide=false,
          holeAreaPadding=holeAreaPadding,
          holePattern=holePattern,
          holeRows=holeRows,
          holeCols=holeCols,
          holeDiameter=holeDiameter,
          gridRows=gridRows,
          gridColumns=gridColumns,
          gridWallThickness=gridWallThickness
        );
  } else {
    FreestandingPot();
  }
}

module FreestandingPot() {
  DrainPan(
    width, depth, holdHeight,
    baseThickness=baseThickness,
    wallThickness=wallThickness,
    frontChamfer=frontChamfer,
    chamferBackSide=chamferBackSide,
    seatHeight=seatHeight,
    anchor=BOTTOM + FRONT
  )
    attach(DRAIN_ANCHOR_TOP, POT_INSERT_ANCHOR_BOTTOM)
      PotInsert(
        width, depth, potHeight, chamfer=frontChamfer, chamferBackSide=chamferBackSide,
        holeAreaPadding=holeAreaPadding,
        holePattern=holePattern,
        holeRows=holeRows,
        holeCols=holeCols,
        holeDiameter=holeDiameter,
        gridRows=gridRows,
        gridColumns=gridColumns,
        gridWallThickness=gridWallThickness
      );
}

module PrintLayout() {
  if (openGridSupport) {
    PotHolder(width, depth, height, holdHeight, subtractedSlots=subtractedSlots, slotPlacement=slotPlacement, anchor=BOTTOM + FRONT);

    right(width + printSpacing)
      PotInsert(
        width, depth, potHeight, chamfer=frontChamfer, chamferBackSide=false, anchor=BOTTOM + FRONT,
        holeAreaPadding=holeAreaPadding,
        holePattern=holePattern,
        holeRows=holeRows,
        holeCols=holeCols,
        holeDiameter=holeDiameter,
        gridRows=gridRows,
        gridColumns=gridColumns,
        gridWallThickness=gridWallThickness
      );
  } else {
    DrainPan(
      width, depth, holdHeight,
      baseThickness=baseThickness,
      wallThickness=wallThickness,
      frontChamfer=frontChamfer,
      chamferBackSide=chamferBackSide,
      seatHeight=seatHeight,
      anchor=BOTTOM + FRONT
    );

    right(width + printSpacing)
      PotInsert(
        width, depth, potHeight, chamfer=frontChamfer, chamferBackSide=chamferBackSide, anchor=BOTTOM + FRONT,
        holeAreaPadding=holeAreaPadding,
        holePattern=holePattern,
        holeRows=holeRows,
        holeCols=holeCols,
        holeDiameter=holeDiameter,
        gridRows=gridRows,
        gridColumns=gridColumns,
        gridWallThickness=gridWallThickness
      );
  }
}
