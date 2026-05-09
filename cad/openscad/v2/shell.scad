// Product shell (v2)
//
// Owns the unified exterior product body. The shell starts as one filled,
// rounded solid and cell tools subtract usable cavities from it.

include <BOSL2/std.scad>
include <components/_dispatch.scad>

module ProductShell(
  width,
  depth,
  height,
  cells,
  tool_name = "pot_cavity",
  params = [],
  wall = 2,
  chamfer = 4,
  anchor = BOTTOM,
  spin = 0,
  orient = UP
) {
  safe_chamfer = min(chamfer, width / 8, depth / 8, height / 5);

  attachable(anchor, spin, orient, size=[width, depth, height]) {
    difference() {
      cuboid([width, depth, height], chamfer=safe_chamfer, anchor=BOTTOM);
      render_cell_tools(cells, tool_name, params, shell_height=height);
    }

    children();
  }
}
