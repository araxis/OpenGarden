function v2_component_prop(component, name, fallback, i = 0) =
  i >= len(component) ? fallback
  : component[i][0] == name ? component[i][1]
  : v2_component_prop(component, name, fallback, i + 1);

function v2_component_type(component) =
  let (raw_type = v2_component_prop(component, "type", "pot_rect"))
    raw_type == "pot" ? "pot_rect" : raw_type;

function v2_component_is_pot_type(comp_type) =
  comp_type == "pot_rect" || comp_type == "pot_roundrect" || comp_type == "pot_circle" || comp_type == "pot_oval";

function v2_component_is_supported_insert_type(comp_type) =
  v2_component_is_pot_type(comp_type) || comp_type == "box";

function v2_component_default_support_mode(comp_type) =
  v2_component_is_supported_insert_type(comp_type) ? "deck" : "none";

function v2_component_support_mode(component, comp_type = undef) =
  let (safe_type = is_undef(comp_type) ? v2_component_type(component) : comp_type)
    v2_component_prop(component, "support_mode", v2_component_default_support_mode(safe_type));

function v2_component_default_insert_depth(comp_type, supported_insert_depth, utility_insert_depth = undef) =
  v2_component_is_supported_insert_type(comp_type)
    ? supported_insert_depth
    : (!is_undef(utility_insert_depth) ? utility_insert_depth : supported_insert_depth);

function v2_component_insert_depth(component, comp_type, supported_insert_depth, utility_insert_depth = undef) =
  v2_component_prop(
    component,
    "insert_depth",
    v2_component_default_insert_depth(comp_type, supported_insert_depth, utility_insert_depth)
  );

function v2_component_parent_center(component, shell_size, row_spec, col_spec, grid_padding) =
  let (
    row = v2_component_prop(component, "row", 1),
    col = v2_component_prop(component, "col", 1),
    row_span = v2_component_prop(component, "row_span", 1),
    col_span = v2_component_prop(component, "col_span", 1)
  )
    grid_cell_span_center(shell_size, row_spec, col_spec, row, col, row_span, col_span, grid_padding);

function v2_component_parent_size(component, shell_size, row_spec, col_spec, grid_padding) =
  let (
    row = v2_component_prop(component, "row", 1),
    col = v2_component_prop(component, "col", 1),
    row_span = v2_component_prop(component, "row_span", 1),
    col_span = v2_component_prop(component, "col_span", 1)
  )
    grid_cell_span_size(shell_size, row_spec, col_spec, row, col, row_span, col_span, grid_padding);

function v2_component_footprint_center(component, shell_size, row_spec, col_spec, grid_padding) =
  let (
    parent_center = v2_component_parent_center(component, shell_size, row_spec, col_spec, grid_padding),
    parent_size = v2_component_parent_size(component, shell_size, row_spec, col_spec, grid_padding),
    sub_row_spec = v2_component_prop(component, "sub_row_sizes", "1*"),
    sub_col_spec = v2_component_prop(component, "sub_col_sizes", "1*"),
    sub_padding = v2_component_prop(component, "sub_padding", [0, 0, 0, 0]),
    sub_row = v2_component_prop(component, "sub_row", 1),
    sub_col = v2_component_prop(component, "sub_col", 1),
    sub_row_span = v2_component_prop(component, "sub_row_span", 1),
    sub_col_span = v2_component_prop(component, "sub_col_span", 1),
    sub_center = grid_cell_span_center(parent_size, sub_row_spec, sub_col_spec, sub_row, sub_col, sub_row_span, sub_col_span, sub_padding)
  )
    [parent_center[0] + sub_center[0], parent_center[1] + sub_center[1]];

function v2_component_footprint_size(component, shell_size, row_spec, col_spec, grid_padding) =
  let (
    parent_size = v2_component_parent_size(component, shell_size, row_spec, col_spec, grid_padding),
    sub_row_spec = v2_component_prop(component, "sub_row_sizes", "1*"),
    sub_col_spec = v2_component_prop(component, "sub_col_sizes", "1*"),
    sub_padding = v2_component_prop(component, "sub_padding", [0, 0, 0, 0]),
    sub_row = v2_component_prop(component, "sub_row", 1),
    sub_col = v2_component_prop(component, "sub_col", 1),
    sub_row_span = v2_component_prop(component, "sub_row_span", 1),
    sub_col_span = v2_component_prop(component, "sub_col_span", 1)
  )
    grid_cell_span_size(parent_size, sub_row_spec, sub_col_spec, sub_row, sub_col, sub_row_span, sub_col_span, sub_padding);
