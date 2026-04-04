include <../params/mvp_params.scad>
use <../lib/common.scad>

// ==============================
// Pot Body
// ==============================

module drain_holes() {
    for (xsign = [-1, 1]) {
        translate([
            xsign * drain_hole_offset_x,
            drain_hole_offset_y,
            -0.5
        ])
        cylinder(d = drain_hole_diameter, h = bottom_thickness + 2);
    }
}

module rim_lip() {
    difference() {
        translate([0, 0, pot_height])
            linear_extrude(height = rim_lip_height)
                square(
                    [
                        pot_top_width + 2 * rim_lip_overhang,
                        pot_top_depth + 2 * rim_lip_overhang
                    ],
                    center = true
                );

        translate([0, 0, pot_height - 0.1])
            linear_extrude(height = rim_lip_height + 0.2)
                square(
                    [pot_top_width, pot_top_depth],
                    center = true
                );
    }
}

module sensor_slot_preview_cut() {
    translate([
        pot_top_width/2 - wall_thickness/2,
        30,
        pot_height - 40
    ])
    rotate([0, 90, 0])
    cube([18, 8, 10], center = true);
}

module pot_body(include_rim = true, include_sensor_preview_cut = false) {
    difference() {
        union() {
            tapered_box_shell(
                top = [pot_top_width, pot_top_depth],
                bottom = [pot_bottom_width, pot_bottom_depth],
                height = pot_height,
                wall = wall_thickness,
                bottom_thick = bottom_thickness
            );

            if (include_rim)
                rim_lip();
        }

        drain_holes();

        if (include_sensor_preview_cut)
            sensor_slot_preview_cut();
    }
}

pot_body(include_rim = false);