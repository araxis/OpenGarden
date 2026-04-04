// ===================================
// OpenGarden MVP Parameters
// Mechanical Step 3
// Carrier + Insert architecture
// ===================================

// ---------- Pot Insert ----------
insert_top_width        = 168;
insert_top_depth        = 168;
insert_bottom_width     = 144;
insert_bottom_depth     = 144;
insert_height           = 145;

insert_wall_thickness   = 2.4;
insert_bottom_thickness = 3.0;

// Top seating flange
insert_flange_width     = 6;
insert_flange_thickness = 3;

// Real-world fit / tolerance
insert_clearance_xy     = 0.8;   // total opening clearance target
insert_fit_clearance    = 0.4;   // applied to insert outer size to avoid coincident geometry
insert_seat_drop_z      = 0.6;   // seat ledge slightly below flange bottom to avoid coplanar faces

// Drainage
drain_hole_diameter     = 8;
drain_hole_offset_x     = 28;
drain_hole_offset_y     = 0;

// Carrier
carrier_outer_width     = 196;   // 7 x 28
carrier_outer_depth     = 196;   // 7 x 28
carrier_height          = 168;   // 6 x 28

carrier_wall_thickness  = 4;
carrier_back_thickness  = 5;
carrier_ledge_width     = 8;
carrier_ledge_height    = 5;

// Sensor
sensor_probe_width      = 14;
sensor_probe_thickness  = 6;
sensor_probe_length     = 70;

sensor_holder_width     = 22;
sensor_holder_thickness = 3;
sensor_holder_height    = 28;
sensor_insert_depth     = 60;

// Tube
tube_outer_diameter     = 6.0;
tube_clip_wall          = 2.4;
tube_clip_width         = 16;
tube_drop_inset         = 18;

// Electronics
electronics_plate_width  = 110;
electronics_plate_height = 140;
electronics_plate_thick  = 4;

// General print
clearance_loose         = 0.4;
clearance_tight         = 0.2;

$fn = 48;