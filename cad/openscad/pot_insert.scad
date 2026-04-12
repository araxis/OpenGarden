include <BOSL2/std.scad>

$fn =100;

height = 30;
width = 70.0;
depth = 70.0;
wallThickness = 2;
frontChamfer = 5;
baseThickness = 2; 
holeAreaPadding = 25;
holeRows = 4;
holeCols = 4;
holeDiameter = 5;
ringHeight = 5;


PotInsert(width, depth, height);

module PotInsert(width,depth,height,
         chamfer = frontChamfer,
         baseThickness = baseThickness,
         holeAreaPadding = holeAreaPadding,
         holeRows = holeRows,
         holeCols = holeCols,
         holeDiameter = holeDiameter,
         ringHeight = ringHeight){
w = width + wallThickness * 2;
d= depth + wallThickness * 2;
h= height;
 rect_tube(
            size= [w, d],
            h = h ,
            wall= wallThickness,
            chamfer= [chamfer,chamfer,0,0],
            ichamfer= [chamfer,chamfer,0,0],
            anchor = FRONT+BOTTOM );
           
      Base(w,d,baseThickness,ringHeight,holeAreaPadding,holeRows,holeCols,holeDiameter);

}

module Base(width,depth,thinkness,ringHeight,holeAreaPadding,holeRows,holeCols,holeDiameter){
    //ring
   ring_w = (width - wallThickness *2 ) - 0.25;
   ring_d = (depth - wallThickness *2 ) - 0.25;
   difference(){
           prismoid([ring_w,ring_d],[width,depth],height=thinkness, anchor = TOP + FRONT,
                chamfer=[frontChamfer,frontChamfer,0,0])
                 align(BOTTOM)
                   Ring(ring_w,ring_d,ringHeight, anchor= TOP);           
           back(width/2)
            grid_copies(n=[holeRows,holeCols], size=[width-holeAreaPadding,depth-holeAreaPadding]) cyl(d=           holeDiameter,h=30,anchor = CENTER);
         }      

}

module Ring(w,d,h,anchor){
 rect_tube(
            size1= [w,d],
            size2 =[w,d],
            h = h ,
            wall= wallThickness,
            chamfer= [frontChamfer,frontChamfer,0,0],
            ichamfer= [frontChamfer,frontChamfer,0,0],
           anchor = anchor );
}

