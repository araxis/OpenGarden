include <../params/mvp_params.scad>
include <../params/opengrid_params.scad>
use <../interfaces/opengrid_interface.scad>

// ===================================
// Electronics Plate
// Separate OpenGrid-mounted dry-zone plate
// Grid-aligned abstraction version
// ===================================

// -----------------------------------
// Main electronics mounting plate
// X = thickness
// Y = width
// Z = height
// -----------------------------------
module plate_body() {
    difference() {
        cube([
            electronics_plate_thick,
            electronics_plate_width,
            electronics_plate_height
        ], center = false);

        // Generic vertical board mounting slots
        for (z = [20, 50, 80, 110]) {
            translate([-0.5, 15, z])
                og_mount_slot(
                    slot_width = 4,
                    slot_height = 12,
                    thickness = electronics_plate_thick + 1
                );

            translate([-0.5, electronics_plate_width - 15, z])
                og_mount_slot(
                    slot_width = 4,
                    slot_height = 12,
                    thickness = electronics_plate_thick + 1
                );
        }
    }
}


// -----------------------------------
// OpenGrid mounting spine
// -----------------------------------
module electronics_mount_spine(
    width_units = 2,
    height_units = 5
) {
    plate_width  = og_unit(width_units);
    plate_height = og_unit(height_units);

    translate([
        -og_plate_thickness,
        (electronics_plate_width - plate_width) / 2,
        (electronics_plate_height - plate_height) / 2
    ])
    og_mount_face(
        width_units = width_units,
        height_units = height_units,
        thickness = og_plate_thickness,
        pattern = "slots",
        slot_width = 6,
        slot_height = 14
    );
}


// -----------------------------------
// Optional cable passthrough holes
// -----------------------------------
module cable_passthroughs() {
    for (z = [25, 55, 85]) {
        translate([-0.5, electronics_plate_width / 2, z])
            og_mount_hole(
                diameter = 8,
                thickness = electronics_plate_thick + 1
            );
    }
}


// -----------------------------------
// Full electronics plate
// -----------------------------------
module electronics_plate(
    include_mount_spine = true,
    include_cable_passthroughs = false
) {
    union() {
        difference() {
            plate_body();

            if (include_cable_passthroughs)
                cable_passthroughs();
        }

        if (include_mount_spine)
            electronics_mount_spine();
    }
}

electronics_plate();