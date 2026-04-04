include <../params/opengrid_params.scad>

// ===================================
// OpenGrid abstraction interface
// Grid-aligned placeholder system
// Mechanical Step 2A / Step 3
// ===================================

// NOTE:
// This is still an abstraction layer.
// It does NOT attempt to model exact openGrid connector geometry yet.
// It provides a clean 28mm-grid-aligned mounting system
// that can later be replaced with exact openGrid-compatible geometry.

function og_unit(value) = value * og_pitch;


// -----------------------------------
// Generic adapter plate
// X = thickness
// Y = width
// Z = height
// -----------------------------------
module og_adapter_plate(
    width = og_mount_width,
    height = og_mount_height,
    thickness = og_plate_thickness
) {
    cube([thickness, width, height], center = false);
}


// -----------------------------------
// Single round mounting hole
// Oriented through X thickness
// -----------------------------------
module og_mount_hole(
    diameter = 5,
    thickness = og_plate_thickness + 1
) {
    rotate([0, 90, 0])
        cylinder(d = diameter, h = thickness, center = false);
}


// -----------------------------------
// Single vertical slot
// Oriented through X thickness
// Slot is centered at local origin in Y/Z
// -----------------------------------
module og_mount_slot(
    slot_width = 6,
    slot_height = 14,
    thickness = og_plate_thickness + 1
) {
    translate([0, 0, -slot_height / 2])
    hull() {
        rotate([0, 90, 0])
            cylinder(d = slot_width, h = thickness, center = false);

        translate([0, 0, slot_height])
            rotate([0, 90, 0])
                cylinder(d = slot_width, h = thickness, center = false);
    }
}


// -----------------------------------
// Grid-aligned hole pattern
// Plate lies in Y/Z plane, thickness along X.
// -----------------------------------
module og_grid_hole_pattern(
    width_units = 6,
    height_units = 6,
    hole_diameter = 5,
    thickness = og_plate_thickness + 1,
    edge_margin = 0
) {
    for (x_idx = [0 : width_units - 1])
    for (y_idx = [0 : height_units - 1]) {
        translate([
            -0.5,
            edge_margin + x_idx * og_pitch + og_pitch / 2,
            edge_margin + y_idx * og_pitch + og_pitch / 2
        ])
        og_mount_hole(
            diameter = hole_diameter,
            thickness = thickness
        );
    }
}


// -----------------------------------
// Grid-aligned slot pattern
// Slot direction is vertical in Z.
// -----------------------------------
module og_grid_slot_pattern(
    width_units = 6,
    height_units = 6,
    slot_width = 6,
    slot_height = 14,
    thickness = og_plate_thickness + 1,
    edge_margin = 0
) {
    for (x_idx = [0 : width_units - 1])
    for (y_idx = [0 : height_units - 1]) {
        translate([
            -0.5,
            edge_margin + x_idx * og_pitch + og_pitch / 2,
            edge_margin + y_idx * og_pitch + og_pitch / 2
        ])
        og_mount_slot(
            slot_width = slot_width,
            slot_height = slot_height,
            thickness = thickness
        );
    }
}


// -----------------------------------
// Grid-aligned mounting face
// Width/height are derived from grid units.
// -----------------------------------
module og_mount_face(
    width_units = 6,
    height_units = 6,
    thickness = og_plate_thickness,
    pattern = "slots",          // "slots" or "holes"
    hole_diameter = 5,
    slot_width = 6,
    slot_height = 14
) {
    plate_width  = og_unit(width_units);
    plate_height = og_unit(height_units);

    difference() {
        cube([thickness, plate_width, plate_height], center = false);

        if (pattern == "holes") {
            og_grid_hole_pattern(
                width_units = width_units,
                height_units = height_units,
                hole_diameter = hole_diameter,
                thickness = thickness + 1
            );
        } else {
            og_grid_slot_pattern(
                width_units = width_units,
                height_units = height_units,
                slot_width = slot_width,
                slot_height = slot_height,
                thickness = thickness + 1
            );
        }
    }
}


// -----------------------------------
// Smaller centered slot face
// -----------------------------------
module og_slotted_face(
    width = og_unit(3),
    height = og_unit(5),
    thickness = og_plate_thickness,
    slot_count = 3,
    slot_width = 6,
    slot_height = 14
) {
    difference() {
        cube([thickness, width, height], center = false);

        for (i = [0 : slot_count - 1]) {
            z_pos = (height / (slot_count + 1)) * (i + 1);

            translate([
                -0.5,
                width / 2,
                z_pos
            ])
            og_mount_slot(
                slot_width = slot_width,
                slot_height = slot_height,
                thickness = thickness + 1
            );
        }
    }
}

module og_debug_mount_face() {
    og_mount_face(
        width_units = 6,
        height_units = 6,
        thickness = og_plate_thickness,
        pattern = "slots"
    );
}

// og_debug_mount_face();