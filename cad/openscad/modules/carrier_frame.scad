include <../params/mvp_params.scad>
include <../params/opengrid_params.scad>
use <../interfaces/opengrid_interface.scad>

// ===================================
// Carrier Frame
// Mechanical Step 3
// OpenGrid-mounted structural holder
// ===================================

// -----------------------------------
// Derived dimensions
// -----------------------------------
carrier_inner_width = carrier_outer_width - 2 * carrier_wall_thickness;
carrier_inner_depth = carrier_outer_depth - 2 * carrier_wall_thickness;

// Insert seating opening with realistic clearance
carrier_insert_opening_width =
    insert_top_width + insert_clearance_xy;

carrier_insert_opening_depth =
    insert_top_depth + insert_clearance_xy;


// -----------------------------------
// Outer shell
// -----------------------------------
module carrier_outer_shell() {
    difference() {
        cube(
            [carrier_outer_width, carrier_outer_depth, carrier_height],
            center = false
        );

        // main cavity
        translate([
            carrier_wall_thickness,
            carrier_wall_thickness,
            0.2
        ])
        cube([
            carrier_inner_width,
            carrier_inner_depth,
            carrier_height + 1
        ], center = false);
    }
}


// -----------------------------------
// Insert support ledge
//
// Insert flange sits above this ledge.
// Ledge is slightly lower than flange bottom
// to avoid coplanar boolean/manifold issues.
// -----------------------------------
module carrier_support_ledge() {
translate([
    carrier_wall_thickness,
    carrier_wall_thickness,
    insert_height - 0.2
])
    difference() {
        cube([
            carrier_inner_width,
            carrier_inner_depth,
            carrier_ledge_height
        ], center = false);

        translate([
            (carrier_inner_width - carrier_insert_opening_width) / 2,
            (carrier_inner_depth - carrier_insert_opening_depth) / 2,
            -0.1
        ])
        cube([
            carrier_insert_opening_width,
            carrier_insert_opening_depth,
            carrier_ledge_height + 0.2
        ], center = false);
    }
}


// -----------------------------------
// Back mounting plate
// Slightly intersects carrier for cleaner union
// -----------------------------------
module carrier_back_mount_plate(
    width_units = 6,
    height_units = 6
) {
    plate_width  = og_unit(width_units);
    plate_height = og_unit(height_units);

    translate([
        -carrier_back_thickness + 1,
        (carrier_outer_depth - plate_width) / 2,
        (carrier_height - plate_height) / 2
    ])
    og_mount_face(
        width_units = width_units,
        height_units = height_units,
        thickness = carrier_back_thickness,
        pattern = "slots",
        slot_width = 6,
        slot_height = 14
    );
}


// -----------------------------------
// Bottom drainage clearance
// -----------------------------------
module carrier_drain_clearance() {
    translate([
        carrier_outer_width / 2 - 24,
        carrier_outer_depth / 2 - 24,
        -0.5
    ])
    cube([48, 48, carrier_wall_thickness + 1], center = false);
}


// -----------------------------------
// Optional front relief opening
// Disabled by default for now
// -----------------------------------
module carrier_front_window() {
    translate([
        carrier_outer_width - 0.5,
        carrier_outer_depth * 0.18,
        carrier_height * 0.22
    ])
    rotate([0, 90, 0])
    cube([
        carrier_height * 0.40,
        carrier_outer_depth * 0.64,
        carrier_wall_thickness + 1
    ], center = false);
}


// -----------------------------------
// Full carrier
// -----------------------------------
module carrier_frame(
    include_mount_plate = true,
    include_drain_clearance = true,
    include_front_window = false
) {
    difference() {
        union() {
            carrier_outer_shell();
            carrier_support_ledge();

            if (include_mount_plate)
                carrier_back_mount_plate();
        }

        if (include_drain_clearance)
            carrier_drain_clearance();

        if (include_front_window)
            carrier_front_window();
    }
}

carrier_frame();