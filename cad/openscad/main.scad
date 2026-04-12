include <pot_holder_frame.scad>
use <pot_insert.scad>
$fn =100;
height = 150.0; 
width = 100.0; 
depth = 70.0; 
holdHeight = height * .3;
potHeight = height- holdHeight;

PotHolder(width,depth,height,holdHeight);
up(holdHeight) PotInsert(width,depth,potHeight);