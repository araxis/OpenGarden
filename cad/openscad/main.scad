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
// Preview is faster while designing; Export uses smoother circles and chamfers for final STL output.
Render_Quality = "Preview"; // [Preview, Export]

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
// Per cell. Rectangle: row count. Circle: maximum ring count.
Hole_Rows = 4; // [1:1:10]
// Per cell. Rectangle: column count. Circle: holes added per ring.
Hole_Columns = 4; // [1:1:10]
// Diameter of each drain hole.
Hole_Diameter = 5; // [1:0.5:15]
// Padding around each cell's drain hole pattern.
Hole_Area_Padding = 25; // [0:0.5:80]

/*[Insert Grid]*/
// Comma-separated front/back row sizes. Each item creates one row. Use *, 2*, 1, or 25%.
Grid_Row_Sizes = "1*";
// Comma-separated left/right column sizes. Each item creates one column. Use *, 2*, 1, or 25%.
Grid_Column_Sizes = "1*";
// Comma-separated row-major cell roles. Use Pot, Box, or FillTube. Missing values default to Pot.
Grid_Cell_Roles = "Pot";
// Sparse role overrides using 1-based row,column=role entries. Example: 2,2=B;1,3=F.
Grid_Cell_Role_Overrides = "";
// Thickness of the internal grid divider walls.
Grid_Wall_Thickness = 2; // [0.8:0.2:6]
// Diameter of the bottom opening for FillTube cells.
Fill_Tube_Diameter = 18; // [5:0.5:50]

/*[Chamfers]*/
// Chamfer size on the front-facing side edges.
Front_Chamfer = 5; // [0:0.5:20]
// Applies back-side chamfers only when OpenGrid_Support is false.
Chamfer_Back_Side = true;

/*[Hidden]*/
$fn = Render_Quality == "Export" ? 100 : 32;
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
gridRowSizes = Grid_Row_Sizes;
gridColumnSizes = Grid_Column_Sizes;
gridCellRoles = Grid_Cell_Roles;
gridCellRoleOverrides = Grid_Cell_Role_Overrides;
gridWallThickness = Grid_Wall_Thickness;
fillTubeDiameter = Fill_Tube_Diameter;

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
    width, depth, potHeight,
    chamferBackSide=chamferBackSide,
    chamfer=frontChamfer,
    anchor=BOTTOM + FRONT,
    holeAreaPadding=holeAreaPadding,
    holePattern=holePattern,
    holeRows=holeRows,
    holeCols=holeCols,
    holeDiameter=holeDiameter,
    gridRowSizes=gridRowSizes,
    gridColumnSizes=gridColumnSizes,
    gridCellRoles=gridCellRoles,
    gridCellRoleOverrides=gridCellRoleOverrides,
    gridWallThickness=gridWallThickness,
    fillTubeDiameter=fillTubeDiameter
  );
}

module PotAssembly() {
  if (openGridSupport) {
    PotHolder(width, depth, height, holdHeight, subtractedSlots=subtractedSlots, slotPlacement=slotPlacement, anchor=BOTTOM + FRONT)
      attach(DRAIN_ANCHOR_TOP, POT_INSERT_ANCHOR_BOTTOM)
        PotInsert(
          width, depth, potHeight,
          chamferBackSide=false,
          chamfer=frontChamfer,
          holeAreaPadding=holeAreaPadding,
          holePattern=holePattern,
          holeRows=holeRows,
          holeCols=holeCols,
          holeDiameter=holeDiameter,
          gridRowSizes=gridRowSizes,
          gridColumnSizes=gridColumnSizes,
          gridCellRoles=gridCellRoles,
          gridCellRoleOverrides=gridCellRoleOverrides,
          gridWallThickness=gridWallThickness,
          fillTubeDiameter=fillTubeDiameter
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
        width, depth, potHeight,
        chamfer=frontChamfer,
        chamferBackSide=chamferBackSide,
        holeAreaPadding=holeAreaPadding,
        holePattern=holePattern,
        holeRows=holeRows,
        holeCols=holeCols,
        holeDiameter=holeDiameter,
        gridRowSizes=gridRowSizes,
        gridColumnSizes=gridColumnSizes,
        gridCellRoles=gridCellRoles,
        gridCellRoleOverrides=gridCellRoleOverrides,
        gridWallThickness=gridWallThickness,
        fillTubeDiameter=fillTubeDiameter
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
        gridRowSizes=gridRowSizes,
        gridColumnSizes=gridColumnSizes,
        gridCellRoles=gridCellRoles,
        gridCellRoleOverrides=gridCellRoleOverrides,
        gridWallThickness=gridWallThickness,
        fillTubeDiameter=fillTubeDiameter
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
        gridRowSizes=gridRowSizes,
        gridColumnSizes=gridColumnSizes,
        gridCellRoles=gridCellRoles,
        gridCellRoleOverrides=gridCellRoleOverrides,
        gridWallThickness=gridWallThickness,
        fillTubeDiameter=fillTubeDiameter
      );
  }
}
