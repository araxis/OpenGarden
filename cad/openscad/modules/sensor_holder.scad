include <../params/mvp_params.scad>

// ===================================
// Sensor Holder
// Clip-on insert flange holder
// ===================================

module sensor_channel() {
    cube([
        sensor_probe_thickness + clearance_loose,
        sensor_probe_width + clearance_loose,
        sensor_probe_length
    ], center = false);
}

module flange_clip_body() {
    difference() {
        cube([16, sensor_holder_width, sensor_holder_height], center = false);

        translate([4, 3, 6])
            cube([14, sensor_holder_width - 6, sensor_holder_height], center = false);
    }
}

module sensor_holder_body() {
    difference() {
        cube([
            sensor_holder_thickness + sensor_probe_thickness + 6,
            sensor_holder_width,
            sensor_insert_depth + 20
        ], center = false);

        translate([
            3,
            (sensor_holder_width - (sensor_probe_width + clearance_loose))/2,
            8
        ])
        sensor_channel();
    }
}

module sensor_holder() {
    union() {
        flange_clip_body();
        translate([10, 0, 0])
            sensor_holder_body();
    }
}

sensor_holder();