// v2 main orchestrator
//
// Composes the three layers — grid, shell tools, carrier — into a final model.
// Reads top-level customizer parameters (Shell_Width, Shell_Depth, etc.) and feeds
// them to both the grid (for cell layout) and the carrier (for footprint).
//
// Top-level orchestration only. No geometry math lives here — that belongs
// inside grid.scad / shell.scad / carrier.scad / components/.
//
// Status: scaffold. Intentionally empty — wiring lands in a later commit
// once grid/carrier/dispatcher have real behavior.

include <grid.scad>
include <carrier.scad>
include <shell.scad>

// ===== Top-level customizer parameters =====

Output_Mode = "Shell Only"; // [Shell Only, Print Layout, Assembly, Carrier Only]
Render_Quality = "Preview"; // [Preview, Export]
Print_Spacing = 20; // [5:1:80]

Shell_Width  = 200; // [30:0.5:450]
Shell_Depth  = 70; // [30:0.5:450]
Shell_Height = 40; // [10:0.5:300]

Grid_Row_Sizes = "1*";
Grid_Column_Sizes = "1*";
Grid_Default_Margin = [0, 0, 0, 0];
Grid_Default_Padding = [6, 6, 6, 6];
Grid_Wall_Fusion = false;
Grid_Fusion_Thickness = 2;

Carrier_Enabled = true;
Carrier_Back_Plate = false;
Carrier_Drain_Pan = true;
Carrier_Reservoir_Height = 30; // [5:0.5:100]
Carrier_Base_Thickness = 2; // [1:0.25:8]
Carrier_Chamfer = 2; // [0:0.5:20]

Default_Cell_Tool = "pot_cavity"; // [pot_cavity]
Default_Cell_Tool_Params = [
  ["floor", 2],
  ["cavity_height", 25],
  ["cavity_chamfer", 2]
];

/*[Hidden]*/
$fn = Render_Quality == "Export" ? 100 : 32;
cells = grid_layout(
  rows_str=Grid_Row_Sizes,
  cols_str=Grid_Column_Sizes,
  default_margin=Grid_Default_Margin,
  default_padding=Grid_Default_Padding,
  wall_fusion=Grid_Wall_Fusion,
  fusion_thickness=Grid_Fusion_Thickness,
  total_width=Shell_Width,
  total_depth=Shell_Depth,
  total_height=Shell_Height
);
Carrier_Component_Z = Carrier_Enabled && Carrier_Drain_Pan
  ? Carrier_Base_Thickness + Carrier_Reservoir_Height
  : 0;

// ===== Orchestration =====
if (Output_Mode == "Assembly") {
  Assembly();
} else if (Output_Mode == "Print Layout") {
  PrintLayout();
} else if (Output_Mode == "Shell Only") {
  ShellLayer();
} else if (Output_Mode == "Carrier Only") {
  CarrierLayer();
}

module Assembly() {
  if (Carrier_Enabled)
    CarrierLayer();

  translate([0, 0, Carrier_Component_Z])
    ShellLayer();
}

module PrintLayout() {
  if (Carrier_Enabled)
    CarrierLayer();

  translate([Shell_Width + Print_Spacing, 0, 0])
    ShellLayer();
}

module ShellLayer() {
  ProductShell(
    Shell_Width,
    Shell_Depth,
    Shell_Height,
    cells,
    tool_name=Default_Cell_Tool,
    params=Default_Cell_Tool_Params,
    wall=2,
    chamfer=Carrier_Chamfer,
    anchor=BOTTOM
  );
}

module CarrierLayer() {
  Carrier(
    Shell_Width,
    Shell_Depth,
    Shell_Height,
    use_back_plate=Carrier_Back_Plate,
    use_drain_pan=Carrier_Drain_Pan,
    reservoir_height=Carrier_Reservoir_Height,
    base_thickness=Carrier_Base_Thickness,
    chamfer=Carrier_Chamfer,
    anchor=BOTTOM
  );
}
