include <../params/mvp_params.scad>
use <../lib/common.scad>

// ===================================
// Pot Insert
// Removable growing container
// ===================================

module insert_drain_holes() {
    for (xsign = [-1, 1]) {
        translate([
            xsign * drain_hole_offset_x,
            drain_hole_offset_y,
            -0.5
        ])
        cylinder(d = drain_hole_diameter, h = insert_bottom_thickness + 2);
    }
}

module insert_flange() {
    difference() {
        translate([0, 0, insert_height])
            linear_extrude(height = insert_flange_thickness)
                square(
                    [
                        insert_top_width + 2 * insert_flange_width,
                        insert_top_depth + 2 * insert_flange_width
                    ],
                    center = true
                );

        translate([0, 0, insert_height - 0.1])
            linear_extrude(height = insert_flange_thickness + 0.2)
                square(
                    [insert_top_width, insert_top_depth],
                    center = true
                );
    }
}

module pot_insert(include_flange = true) {
    difference() {
        union() {
            tapered_box_shell(
                top = [insert_top_width, insert_top_depth],
                bottom = [insert_bottom_width, insert_bottom_depth],
                height = insert_height,
                wall = insert_wall_thickness,
                bottom_thick = insert_bottom_thickness
            );

            if (include_flange)
                insert_flange();
        }

        insert_drain_holes();
    }
}

pot_insert();