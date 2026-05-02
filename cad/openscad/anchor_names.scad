// Shared BOSL2 named-anchor constants for OpenGarden modules.

// --- Holder / drain / insert assembly anchors ---
HOLDER_ANCHOR_INSIDE_CENTER = "inside";
DRAIN_ANCHOR_TOP = "insert_seat";
DRAIN_ANCHOR_RESERVOIR_CENTER = "reservoir";
POT_INSERT_ANCHOR_BOTTOM = "seat";

// --- Per-cell anchor name suffixes ---
// Combined with cell_anchor() to build full names like "cell_2_3_wall_n".
// Row and column are 1-based to match the user-facing override DSL.
CELL_ANCHOR_TOP = "_top";
CELL_ANCHOR_BOTTOM = "_bottom";
CELL_ANCHOR_CENTER = "_center";
CELL_ANCHOR_WALL_N = "_wall_n";
CELL_ANCHOR_WALL_S = "_wall_s";
CELL_ANCHOR_WALL_E = "_wall_e";
CELL_ANCHOR_WALL_W = "_wall_w";

// Build a per-cell anchor name. Row and col are 1-based.
// Example: cell_anchor(2, 3, CELL_ANCHOR_WALL_N) => "cell_2_3_wall_n".
function cell_anchor(row, col, suffix) =
  str("cell_", row, "_", col, suffix);
