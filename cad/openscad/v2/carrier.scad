// Carrier (v2) — foundation under everything
//
// One module with internal feature flags. Composes:
//   ─ back plate (OpenGrid Multiconnect mount, optional)
//   ─ drain pan / reservoir floor (optional)
//
// Footprint is shared with the grid via main.scad's top-level Pot_Width /
// Pot_Depth — there's no inter-module dependency. Both grid and carrier
// consume the same input.
//
// Reservoir is GENERIC — a single pool under the entire footprint, not
// targeted at specific component drain hole positions.
//
// Components are removable: drain pan presents a flat top; components rest
// on it (or slot into a raised lip in v2.x). They are NOT union'd into
// the carrier in print output.
//
// Status: scaffold. Empty module body until wired up.

include <BOSL2/std.scad>

module Carrier(
  width,
  depth,
  height,
  use_back_plate    = false,
  use_drain_pan     = true,
  reservoir_height  = 30,
  base_thickness    = 2,
  chamfer           = 0,
  chamfer_back      = false,
  anchor            = CENTER,
  spin              = 0,
  orient            = UP
) {
  carrier_height = use_drain_pan ? reservoir_height + base_thickness : height;
  safe_chamfer = min(chamfer, base_thickness / 3, reservoir_height / 3);

  attachable(anchor, spin, orient, size=[width, depth, carrier_height]) {
    union() {
      if (use_drain_pan) {
        cuboid(
          [width, depth, base_thickness],
          chamfer=safe_chamfer,
          anchor=BOTTOM
        );

        up(base_thickness)
          rect_tube(
            size=[width, depth],
            h=reservoir_height,
            wall=base_thickness,
            chamfer=safe_chamfer,
            ichamfer=safe_chamfer,
            anchor=BOTTOM
          );
      }

      if (use_back_plate)
        translate([0, depth / 2 + base_thickness / 2, carrier_height / 2])
          cuboid([width, base_thickness, carrier_height], chamfer=safe_chamfer, anchor=CENTER);
    }

    children();
  }
}
