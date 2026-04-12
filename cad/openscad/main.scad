include <BOSL2/std.scad>
use <pot_holder_frame.scad>
use <pot_insert.scad>
$fn =100;
height = 100.0; 
width = 70.0; 
depth = 70.0; 
holdHeight = height * .3;
potHeight = height- holdHeight;

PotHolder(width,depth,height,holdHeight);
up(holdHeight) 
    PotInsert(width,depth,potHeight);