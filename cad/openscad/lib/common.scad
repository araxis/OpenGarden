// ===================================
// OpenGarden common helpers
// ===================================

module centered_cylinder(d, h) {
    cylinder(d = d, h = h, center = true);
}

module centered_cube(size = [10,10,10]) {
    cube(size, center = true);
}

// Tapered rectangular shell
// Outer shape is defined by top/bottom sizes.
// Inner subtraction uses the same taper logic.
// Small Z offsets are used to avoid coplanar boolean issues.
module tapered_box_shell(
    top = [156,156],
    bottom = [138,138],
    height = 145,
    wall = 2.4,
    bottom_thick = 3
) {
    difference() {
        linear_extrude(
            height = height,
            scale = [bottom[0] / top[0], bottom[1] / top[1]]
        )
        square(top, center = true);

        translate([0, 0, bottom_thick])
        linear_extrude(
            height = height - bottom_thick + 0.2,
            scale = [
                (bottom[0] - 2 * wall) / (top[0] - 2 * wall),
                (bottom[1] - 2 * wall) / (top[1] - 2 * wall)
            ]
        )
        square(
            [top[0] - 2 * wall, top[1] - 2 * wall],
            center = true
        );
    }
}