include <../params/mvp_params.scad>
use <../lib/common.scad>

// ===================================
// Pot Insert
// Mechanical Step 3C
// Removable growing container with usability improvements
// ===================================

// Effective outer dimensions slightly reduced for fit realism
insert_eff_top_width     = insert_top_width - insert_fit_clearance;
insert_eff_top_depth     = insert_top_depth - insert_fit_clearance;
insert_eff_bottom_width  = insert_bottom_width - insert_fit_clearance;
insert_eff_bottom_depth  = insert_bottom_depth - insert_fit_clearance;

// Usability tuning
finger_notch_width       = 40;
finger_notch_depth       = 8;
finger_notch_radius      = 10;

anti_rotation_key_width  = 12;
anti_rotation_key_depth  = 3;
anti_rotation_key_height = 10;


// -----------------------------------
// Drainage
// Use 4 holes instead of 2 for better water distribution
// -----------------------------------
module insert_drain_holes() {
    for (x = [-28, 28])
    for (y = [-28, 28]) {
        translate([x, y, -0.5])
            cylinder(d = drain_hole_diameter, h = insert_bottom_thickness + 2);
    }
}


// -----------------------------------
// Finger notch cut shape
// Used to make insert easier to lift out
// -----------------------------------
module finger_notch_cut(depth = finger_notch_depth, width = finger_notch_width, height = insert_flange_thickness + 0.4) {
    translate([0, 0, -0.2])
    linear_extrude(height = height)
    hull() {
        translate([-width / 2 + finger_notch_radius, 0])
            circle(r = finger_notch_radius);

        translate([ width / 2 - finger_notch_radius, 0])
            circle(r = finger_notch_radius);

        translate([-width / 2, -depth])
            square([width, 0.01]);

        translate([-width / 2, 0])
            square([width, 0.01]);
    }
}


// -----------------------------------
// Top seating flange with front/rear finger notches
// -----------------------------------
module insert_flange() {
    difference() {
        translate([0, 0, insert_height])
            linear_extrude(height = insert_flange_thickness)
                square(
                    [
                        insert_eff_top_width + 2 * insert_flange_width,
                        insert_eff_top_depth + 2 * insert_flange_width
                    ],
                    center = true
                );

        // inner opening
        translate([0, 0, insert_height - 0.1])
            linear_extrude(height = insert_flange_thickness + 0.2)
                square(
                    [insert_eff_top_width, insert_eff_top_depth],
                    center = true
                );

        // front finger notch
        translate([
            0,
            (insert_eff_top_depth / 2) + insert_flange_width + 0.01,
            insert_height
        ])
        rotate([0, 0, 180])
            finger_notch_cut();

        // rear finger notch
        translate([
            0,
            -(insert_eff_top_depth / 2) - insert_flange_width - 0.01,
            insert_height
        ])
            finger_notch_cut();
    }
}


// -----------------------------------
// Small anti-rotation keys
// These are subtle and only help orientation slightly.
// Matching carrier feature can be added later if needed.
// -----------------------------------
module anti_rotation_keys() {
    // front
    translate([
        -anti_rotation_key_width / 2,
        insert_eff_top_depth / 2 - anti_rotation_key_depth,
        insert_height - anti_rotation_key_height
    ])
    cube([
        anti_rotation_key_width,
        anti_rotation_key_depth,
        anti_rotation_key_height
    ], center = false);

    // rear
    translate([
        -anti_rotation_key_width / 2,
        -(insert_eff_top_depth / 2),
        insert_height - anti_rotation_key_height
    ])
    cube([
        anti_rotation_key_width,
        anti_rotation_key_depth,
        anti_rotation_key_height
    ], center = false);
}


// -----------------------------------
// Full insert
// -----------------------------------
module pot_insert(include_flange = true, include_anti_rotation = false) {
    difference() {
        union() {
            tapered_box_shell(
                top = [insert_eff_top_width, insert_eff_top_depth],
                bottom = [insert_eff_bottom_width, insert_eff_bottom_depth],
                height = insert_height,
                wall = insert_wall_thickness,
                bottom_thick = insert_bottom_thickness
            );

            if (include_flange)
                insert_flange();

            if (include_anti_rotation)
                anti_rotation_keys();
        }

        insert_drain_holes();
    }
}

pot_insert(include_flange = true, include_anti_rotation = false);