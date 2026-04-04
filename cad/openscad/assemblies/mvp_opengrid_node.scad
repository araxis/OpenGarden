include <../params/mvp_params.scad>
include <../params/opengrid_params.scad>

use <../modules/carrier_frame.scad>
use <../modules/pot_insert.scad>
use <../modules/sensor_holder.scad>
use <../modules/tube_clip.scad>
use <../modules/electronics_plate.scad>

// ===================================
// MVP OpenGrid Node Assembly
// Mechanical Step 3 fit-first assembly
// ===================================

carrier_inner_width = carrier_outer_width - 2 * carrier_wall_thickness;
carrier_inner_depth = carrier_outer_depth - 2 * carrier_wall_thickness;

insert_center_x = carrier_wall_thickness + carrier_inner_width / 2;
insert_center_y = carrier_wall_thickness + carrier_inner_depth / 2;
insert_top_z    = insert_height + insert_flange_thickness;

module placed_insert() {
    translate([
        insert_center_x,
        insert_center_y,
        0.2
    ])
    pot_insert(include_flange = true);
}

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

module mvp_opengrid_node(
    show_carrier = true,
    show_insert = true,
    show_sensor = false,
    show_tube = false,
    show_electronics = false
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
        translate([
            carrier_outer_width - 14,
            insert_center_y + 18,
            insert_top_z - sensor_holder_height + 2
        ])
        sensor_holder();

    if (show_tube)
        translate([
            2,
            insert_center_y - 14,
            insert_top_z - 12
        ])
        tube_clip();

    if (show_electronics)
        placed_electronics_plate();
}

mvp_opengrid_node();