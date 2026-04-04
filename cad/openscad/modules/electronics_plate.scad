include <../params/mvp_params.scad>
use <../interfaces/opengrid_interface.scad>

// ===================================
// Electronics Plate
// Separate OpenGrid-mounted dry-zone plate
// ===================================

module plate_body() {
    difference() {
        cube([
            electronics_plate_thick,
            electronics_plate_width,
            electronics_plate_height
        ], center = false);

        // generic board mounting slots
        for (y = [20, 50, 80, 110]) {
            translate([-0.5, 15, y])
                cube([electronics_plate_thick + 1, 8, 18], center = false);

            translate([-0.5, electronics_plate_width - 23, y])
                cube([electronics_plate_thick + 1, 8, 18], center = false);
        }
    }
}

module electronics_plate() {
    union() {
        plate_body();

        translate([-carrier_back_thickness, 15, 10])
            og_hook_pair(spacing = 60);
    }
}

electronics_plate();