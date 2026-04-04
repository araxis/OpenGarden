include <../params/mvp_params.scad>

// ===================================
// Tube Clip
// Clip-on insert flange holder
// ===================================

module clip_body() {
    difference() {
        cube([16, 18, 18], center = false);

        translate([4, 3, 5])
            cube([14, 12, 16], center = false);
    }
}

module tube_ring() {
    difference() {
        cylinder(d = tube_outer_diameter + 2 * tube_clip_wall, h = tube_clip_width);
        translate([0, 0, -0.5])
            cylinder(d = tube_outer_diameter + clearance_loose, h = tube_clip_width + 1);
    }
}

module tube_clip() {
    union() {
        clip_body();

        translate([8, 9, 9])
        rotate([90, 0, 0])
        tube_ring();
    }
}

tube_clip();