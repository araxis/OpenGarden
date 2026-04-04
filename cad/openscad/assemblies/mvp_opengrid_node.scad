include <../params/mvp_params.scad>
use <../modules/carrier_frame.scad>
use <../modules/pot_insert.scad>
use <../modules/sensor_holder.scad>
use <../modules/tube_clip.scad>
use <../modules/electronics_plate.scad>

// ===================================
// MVP OpenGrid Node Assembly
// ===================================

module mvp_opengrid_node() {
    // Carrier at origin
    carrier_frame();

    // Insert positioned inside carrier
    translate([
        carrier_wall_thickness + (carrier_outer_width - 2 * carrier_wall_thickness) / 2,
        carrier_wall_thickness + (carrier_outer_depth - 2 * carrier_wall_thickness) / 2,
        0
    ])
    pot_insert(include_flange = true);

    // Sensor holder on right side top edge
    translate([
        carrier_outer_width - 8,
        carrier_outer_depth / 2 + 20,
        insert_height + insert_flange_thickness - 10
    ])
    sensor_holder();

    // Tube clip on left/front upper edge
    translate([
        6,
        carrier_outer_depth / 2 - 10,
        insert_height + insert_flange_thickness - 10
    ])
    tube_clip();

    // Electronics plate offset to the side
    translate([
        -20,
        carrier_outer_depth + 20,
        10
    ])
    electronics_plate();
}

mvp_opengrid_node();