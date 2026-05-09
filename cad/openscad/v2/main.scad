// v2 main orchestrator
//
// Composes the three layers — grid, components, carrier — into a final model.
// Reads top-level customizer parameters (Pot_Width, Pot_Depth, etc.) and feeds
// them to both the grid (for cell layout) and the carrier (for footprint).
//
// Top-level orchestration only. No geometry math lives here — that belongs
// inside grid.scad / carrier.scad / components/.
//
// Status: scaffold. Intentionally empty — wiring lands in a later commit
// once grid/carrier/dispatcher have real behavior.

include <grid.scad>
include <carrier.scad>
include <components/_dispatch.scad>

// ===== Top-level customizer parameters =====

Output_Mode = "Assembly"; // [Assembly, Print Layout, Component Only, Carrier Only]
Render_Quality = "Preview"; // [Preview, Export]
Print_Spacing = 20; // [5:1:80]

Pot_Width  = 70; // [30:0.5:450]
Pot_Depth  = 70; // [30:0.5:450]
Pot_Height = 100; // [40:0.5:450]

Grid_Row_Sizes = "1*,1*";
Grid_Column_Sizes = "1*,1*";
Grid_Default_Margin = [0, 0, 0, 0];
Grid_Default_Padding = [0, 0, 0, 0];
Grid_Wall_Fusion = false;
Grid_Fusion_Thickness = 2;

Carrier_Enabled = true;
Carrier_Back_Plate = false;
Carrier_Drain_Pan = true;
Carrier_Reservoir_Height = 30; // [5:0.5:100]
Carrier_Base_Thickness = 2; // [1:0.25:8]
Carrier_Chamfer = 2; // [0:0.5:20]

Default_Component = "empty";

/*[Hidden]*/
$fn = Render_Quality == "Export" ? 100 : 32;
cells = grid_layout(
  rows_str=Grid_Row_Sizes,
  cols_str=Grid_Column_Sizes,
  default_margin=Grid_Default_Margin,
  default_padding=Grid_Default_Padding,
  wall_fusion=Grid_Wall_Fusion,
  fusion_thickness=Grid_Fusion_Thickness,
  total_width=Pot_Width,
  total_depth=Pot_Depth,
  total_height=Pot_Height
);

// ===== Orchestration =====
if (Output_Mode == "Assembly") {
  Assembly();
} else if (Output_Mode == "Print Layout") {
  PrintLayout();
} else if (Output_Mode == "Component Only") {
  render_components(cells, Default_Component);
} else if (Output_Mode == "Carrier Only") {
  CarrierLayer();
}

module Assembly() {
  if (Carrier_Enabled)
    CarrierLayer();

  render_components(cells, Default_Component);
}

module PrintLayout() {
  if (Carrier_Enabled)
    CarrierLayer();

  translate([Pot_Width + Print_Spacing, 0, 0])
    render_components_print_layout(cells, Default_Component, spacing=Print_Spacing);
}

module CarrierLayer() {
  Carrier(
    Pot_Width,
    Pot_Depth,
    Pot_Height,
    use_back_plate=Carrier_Back_Plate,
    use_drain_pan=Carrier_Drain_Pan,
    reservoir_height=Carrier_Reservoir_Height,
    base_thickness=Carrier_Base_Thickness,
    chamfer=Carrier_Chamfer,
    anchor=BOTTOM
  );
}
