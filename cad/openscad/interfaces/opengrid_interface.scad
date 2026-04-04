include <../params/opengrid_params.scad>

// ===================================
// OpenGrid abstraction interface
// Placeholder geometry only
// Replace later with exact OpenGrid geometry
// ===================================

// Generic vertical adapter plate
module og_adapter_plate(
    width = og_mount_width,
    height = og_mount_height,
    thickness = og_plate_thickness
) {
    cube([thickness, width, height], center = false);
}

// Generic slotted mounting face
module og_slotted_face(
    width = 60,
    height = 120,
    thickness = og_plate_thickness
) {
    difference() {
        cube([thickness, width, height], center = false);

        for (y = [20, 60, 100]) {
            translate([-0.5, width/2 - 6, y - 8])
                cube([thickness + 1, 12, 16], center = false);
        }
    }
}

// Generic hook pair placeholder
module og_hook_pair(spacing = 40) {
    union() {
        translate([0, 0, 0]) og_hook();
        translate([0, 0, spacing]) og_hook();
    }
}

module og_hook() {
    union() {
        cube([og_hook_depth, og_hook_width, og_hook_height], center = false);

        translate([og_hook_depth - 2, 0, og_hook_height - 2])
            cube([2, og_hook_width, 4], center = false);
    }
}