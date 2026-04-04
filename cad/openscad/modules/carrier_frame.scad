include <../params/mvp_params.scad>
use <../interfaces/opengrid_interface.scad>

// ===================================
// Carrier Frame
// OpenGrid-mounted structural holder
// ===================================

module carrier_outer_shell() {
    difference() {
        cube([carrier_outer_width, carrier_outer_depth, carrier_height], center = false);

        translate([
            carrier_wall_thickness,
            carrier_wall_thickness,
            carrier_ledge_height
        ])
        cube([
            carrier_outer_width - 2 * carrier_wall_thickness,
            carrier_outer_depth - 2 * carrier_wall_thickness,
            carrier_height
        ], center = false);
    }
}

module carrier_support_ledge() {
    // simple insert support ledge near top seating zone
    difference() {
        translate([
            carrier_wall_thickness,
            carrier_wall_thickness,
            insert_height - 2
        ])
        cube([
            carrier_outer_width - 2 * carrier_wall_thickness,
            carrier_outer_depth - 2 * carrier_wall_thickness,
            carrier_ledge_height
        ], center = false);

        translate([
            carrier_wall_thickness + carrier_ledge_width,
            carrier_wall_thickness + carrier_ledge_width,
            insert_height - 2 - 0.5
        ])
        cube([
            carrier_outer_width - 2 * (carrier_wall_thickness + carrier_ledge_width),
            carrier_outer_depth - 2 * (carrier_wall_thickness + carrier_ledge_width),
            carrier_ledge_height + 1
        ], center = false);
    }
}

module carrier_back_mount_plate() {
    translate([
        -carrier_back_thickness,
        (carrier_outer_depth - 80) / 2,
        20
    ])
    og_slotted_face(
        width = 80,
        height = 120,
        thickness = carrier_back_thickness
    );
}

module carrier_frame() {
    union() {
        carrier_outer_shell();
        carrier_support_ledge();
        carrier_back_mount_plate();
    }
}

carrier_frame();