include <../params/mvp_params.scad>
include <../params/opengrid_params.scad>

use <../modules/carrier_frame.scad>
use <../modules/pot_insert.scad>
use <../modules/sensor_holder.scad>
use <../modules/tube_clip.scad>
use <../modules/electronics_plate.scad>

// ===================================
// MVP OpenGrid Node Assembly
// Carrier + removable insert + accessories
// ===================================


// -----------------------------------
// Derived placement helpers
// -----------------------------------
carrier_inner_width = carrier_outer_width - 2 * carrier_wall_thickness;
carrier_inner_depth = carrier_outer_depth - 2 * carrier_wall_thickness;

// center of carrier cavity in XY
insert_center_x = carrier_wall_thickness + carrier_inner_width / 2;
insert_center_y = carrier_wall_thickness + carrier_inner_depth / 2;

// insert top Z
insert_top_z = insert_height + insert_flange_thickness;


// -----------------------------------
// Insert placement
// Pot insert is modeled centered in X/Y, starting at Z=0
// So we translate its center into the carrier cavity center
// -----------------------------------
module placed_insert() {
    translate([
        insert_center_x,
        insert_center_y,
        0
    ])
    pot_insert(include_flange = true);
}


// -----------------------------------
// Sensor holder placement
// Simple preview position clipped near right/top region
// Fine-tuning comes in Mechanical Step 3
// -----------------------------------
module placed_sensor_holder() {
    translate([
        carrier_outer_width - 14,
        insert_center_y + 18,
        insert_top_z - sensor_holder_height + 2
    ])
    sensor_holder();
}


// -----------------------------------
// Tube clip placement
// Simple preview position on opposite side
// -----------------------------------
module placed_tube_clip() {
    translate([
        2,
        insert_center_y - 14,
        insert_top_z - 12
    ])
    tube_clip();
}


// -----------------------------------
// Electronics plate placement
// Separate dry-zone plate mounted beside carrier
// Keep some spacing for visual clarity
// -----------------------------------
module placed_electronics_plate() {
    translate([
        -electronics_plate_thick - og_plate_thickness - 12,
        carrier_outer_depth + 24,
        12
    ])
    electronics_plate(
        include_mount_spine = true,
        include_cable_passthroughs = false
    );
}


// -----------------------------------
// Full assembly
// -----------------------------------
module mvp_opengrid_node(
    show_carrier = true,
    show_insert = true,
    show_sensor = true,
    show_tube = true,
    show_electronics = true
) {
    if (show_carrier)
        carrier_frame(
            include_mount_plate = true,
            include_drain_clearance = true,
            include_front_window = false
        );

    if (show_insert)
        placed_insert();

    if (show_sensor)
        placed_sensor_holder();

    if (show_tube)
        placed_tube_clip();

    if (show_electronics)
        placed_electronics_plate();
}

mvp_opengrid_node();