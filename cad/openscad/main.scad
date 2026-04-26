include <BOSL2/std.scad>
include <anchor_names.scad>
use <pot_holder_frame.scad>
use <pot_insert.scad>
$fn = 100;

/* [Output] */
outputMode = "Assembly"; // [Assembly, Print Layout, Holder Only, Pot Insert Only]
printSpacing = 20;

/*[Pot Customization]*/
// combo box for number
height = 100.0;//[150]
width = 70.0; 
depth = 70.0; 
holdHeight = height * .3;
potHeight = height - holdHeight;

if (outputMode == "Assembly") {
    PotAssembly();
} else if (outputMode == "Print Layout") {
    PrintLayout();
} else if (outputMode == "Holder Only") {
    PotHolder(width, depth, height, holdHeight, anchor = BOTTOM + FRONT);
} else if (outputMode == "Pot Insert Only") {
    PotInsert(width, depth, potHeight, anchor = BOTTOM + FRONT);
}

module PotAssembly() {
  PotHolder(width, depth, height, holdHeight, anchor = BOTTOM + FRONT)
    attach(DRAIN_ANCHOR_TOP, POT_INSERT_ANCHOR_BOTTOM)
        PotInsert(width, depth, potHeight);
}

module PrintLayout() {
  PotHolder(width, depth, height, holdHeight, anchor = BOTTOM + FRONT);

  right(width + printSpacing)
    PotInsert(width, depth, potHeight, anchor = BOTTOM + FRONT);
}
