include <BOSL2/std.scad>
include <grid_helpers.scad>

function feature_override_name(overrides, row, col, plane, pos = 0) =
  pos >= len(overrides) ? ""
  : let (
      start = grid_skip_spaces(overrides, pos),
      raw_end = grid_delim_pos(overrides, start, len(overrides), ";"),
      end = grid_trim_end(overrides, start, raw_end),
      name = feature_entry_name(overrides, start, end)
    )
      feature_entry_matches(overrides, start, end, row + 1, col + 1, plane)
        ? name
        : feature_override_name(overrides, row, col, plane, raw_end + 1);

function feature_override_number_param(overrides, row, col, plane, key, default_value, pos = 0) =
  pos >= len(overrides) ? default_value
  : let (
      start = grid_skip_spaces(overrides, pos),
      raw_end = grid_delim_pos(overrides, start, len(overrides), ";"),
      end = grid_trim_end(overrides, start, raw_end)
    )
      feature_entry_matches(overrides, start, end, row + 1, col + 1, plane)
        ? feature_entry_number_param(overrides, start, end, key, default_value)
        : feature_override_number_param(overrides, row, col, plane, key, default_value, raw_end + 1);

function feature_override_bool_param(overrides, row, col, plane, key, default_value, pos = 0) =
  pos >= len(overrides) ? default_value
  : let (
      start = grid_skip_spaces(overrides, pos),
      raw_end = grid_delim_pos(overrides, start, len(overrides), ";"),
      end = grid_trim_end(overrides, start, raw_end)
    )
      feature_entry_matches(overrides, start, end, row + 1, col + 1, plane)
        ? feature_entry_bool_param(overrides, start, end, key, default_value)
        : feature_override_bool_param(overrides, row, col, plane, key, default_value, raw_end + 1);

function feature_override_token_param_equals(overrides, row, col, plane, key, expected, pos = 0) =
  pos >= len(overrides) ? false
  : let (
      start = grid_skip_spaces(overrides, pos),
      raw_end = grid_delim_pos(overrides, start, len(overrides), ";"),
      end = grid_trim_end(overrides, start, raw_end)
    )
      feature_entry_matches(overrides, start, end, row + 1, col + 1, plane)
        ? feature_entry_token_param_equals(overrides, start, end, key, expected)
        : feature_override_token_param_equals(overrides, row, col, plane, key, expected, raw_end + 1);

function feature_entry_matches(overrides, start, end, target_row, target_col, plane) =
  let (
    comma = grid_delim_pos(overrides, start, end, ","),
    equals = comma >= end ? end : grid_delim_pos(overrides, comma + 1, end, "="),
    row = comma >= end ? -1 : round(grid_parse_number(overrides, start, comma)),
    col = equals >= end ? -1 : round(grid_parse_number(overrides, comma + 1, equals)),
    name = feature_entry_name(overrides, start, end)
  )
    row == target_row && col == target_col && feature_name_plane(name) == plane;

function feature_entry_name(overrides, start, end) =
  let (
    equals = grid_delim_pos(overrides, start, end, "="),
    name_start = equals >= end ? end : grid_skip_spaces(overrides, equals + 1),
    paren = grid_delim_pos(overrides, name_start, end, "("),
    name_end = grid_trim_end(overrides, name_start, paren)
  )
    feature_token_canonical(overrides, name_start, name_end);

function feature_entry_params_start(overrides, start, end) =
  let (
    equals = grid_delim_pos(overrides, start, end, "="),
    name_start = equals >= end ? end : grid_skip_spaces(overrides, equals + 1),
    paren = grid_delim_pos(overrides, name_start, end, "(")
  )
    paren >= end ? end : paren + 1;

function feature_entry_params_end(overrides, start, end) =
  let (
    params_start = feature_entry_params_start(overrides, start, end),
    close = grid_delim_pos(overrides, params_start, end, ")")
  )
    close >= end ? end : close;

function feature_entry_number_param(overrides, start, end, key, default_value) =
  feature_param_number(
    overrides,
    feature_entry_params_start(overrides, start, end),
    feature_entry_params_end(overrides, start, end),
    key,
    default_value
  );

function feature_entry_bool_param(overrides, start, end, key, default_value) =
  feature_param_bool(
    overrides,
    feature_entry_params_start(overrides, start, end),
    feature_entry_params_end(overrides, start, end),
    key,
    default_value
  );

function feature_entry_token_param_equals(overrides, start, end, key, expected) =
  feature_param_token_equals(
    overrides,
    feature_entry_params_start(overrides, start, end),
    feature_entry_params_end(overrides, start, end),
    key,
    expected
  );

function feature_param_number(spec, start, end, key, default_value, pos = undef) =
  let (scan = is_undef(pos) ? start : pos)
    scan >= end ? default_value
    : let (
        param_start = grid_skip_spaces(spec, scan),
        raw_param_end = grid_delim_pos(spec, param_start, end, ","),
        param_end = grid_trim_end(spec, param_start, raw_param_end),
        equals = grid_delim_pos(spec, param_start, param_end, "="),
        key_end = grid_trim_end(spec, param_start, equals),
        value_start = equals >= param_end ? param_end : grid_skip_spaces(spec, equals + 1)
      )
        grid_token_equals(spec, param_start, key_end, key)
          ? grid_parse_number(spec, value_start, param_end)
          : feature_param_number(spec, start, end, key, default_value, raw_param_end + 1);

function feature_param_bool(spec, start, end, key, default_value, pos = undef) =
  let (scan = is_undef(pos) ? start : pos)
    scan >= end ? default_value
    : let (
        param_start = grid_skip_spaces(spec, scan),
        raw_param_end = grid_delim_pos(spec, param_start, end, ","),
        param_end = grid_trim_end(spec, param_start, raw_param_end),
        equals = grid_delim_pos(spec, param_start, param_end, "="),
        key_end = grid_trim_end(spec, param_start, equals),
        value_start = equals >= param_end ? param_end : grid_skip_spaces(spec, equals + 1),
        value_end = grid_trim_end(spec, value_start, param_end)
      )
        grid_token_equals(spec, param_start, key_end, key)
          ? feature_bool_token_value(spec, value_start, value_end, default_value)
          : feature_param_bool(spec, start, end, key, default_value, raw_param_end + 1);

function feature_param_token_equals(spec, start, end, key, expected, pos = undef) =
  let (scan = is_undef(pos) ? start : pos)
    scan >= end ? false
    : let (
        param_start = grid_skip_spaces(spec, scan),
        raw_param_end = grid_delim_pos(spec, param_start, end, ","),
        param_end = grid_trim_end(spec, param_start, raw_param_end),
        equals = grid_delim_pos(spec, param_start, param_end, "="),
        key_end = grid_trim_end(spec, param_start, equals),
        value_start = equals >= param_end ? param_end : grid_skip_spaces(spec, equals + 1),
        value_end = grid_trim_end(spec, value_start, param_end)
      )
        grid_token_equals(spec, param_start, key_end, key)
          ? grid_token_equals(spec, value_start, value_end, expected)
          : feature_param_token_equals(spec, start, end, key, expected, raw_param_end + 1);

function feature_bool_token_value(spec, start, end, default_value) =
  grid_token_equals(spec, start, end, "true") || grid_token_equals(spec, start, end, "True") || grid_token_equals(spec, start, end, "1") ? true
  : grid_token_equals(spec, start, end, "false") || grid_token_equals(spec, start, end, "False") || grid_token_equals(spec, start, end, "0") ? false
  : default_value;

function feature_token_canonical(spec, start, end) =
  grid_token_equals(spec, start, end, "drain_holes") || grid_token_equals(spec, start, end, "drain") ? "drain_holes"
  : grid_token_equals(spec, start, end, "fill_tube") || grid_token_equals(spec, start, end, "filltube") ? "fill_tube"
  : grid_token_equals(spec, start, end, "lid_lip") ? "lid_lip"
  : grid_token_equals(spec, start, end, "wick_port") ? "wick_port"
  : grid_token_equals(spec, start, end, "none") || grid_token_equals(spec, start, end, "box") || grid_token_equals(spec, start, end, "Box") ? "none"
  : "";

function feature_name_plane(name) =
  name == "drain_holes" || name == "fill_tube" || name == "wick_port" || name == "none" ? "BOTTOM"
  : name == "lid_lip" ? "TOP_LIP"
  : "";

function feature_entry_is_valid(overrides, start, end) =
  let (
    comma = grid_delim_pos(overrides, start, end, ","),
    equals = comma >= end ? end : grid_delim_pos(overrides, comma + 1, end, "="),
    row = comma >= end ? -1 : round(grid_parse_number(overrides, start, comma)),
    col = equals >= end ? -1 : round(grid_parse_number(overrides, comma + 1, equals))
  )
    start >= end || (row > 0 && col > 0 && feature_entry_name(overrides, start, end) != "");

module FeatureDslWarnings(overrides, pos = 0) {
  if (pos < len(overrides)) {
    let (
      start = grid_skip_spaces(overrides, pos),
      raw_end = grid_delim_pos(overrides, start, len(overrides), ";"),
      end = grid_trim_end(overrides, start, raw_end)
    ) {
      if (end > start && !feature_entry_is_valid(overrides, start, end))
        echo(str("WARNING: ignored malformed Cell_Feature_Overrides entry near character ", start));

      FeatureDslWarnings(overrides, raw_end + 1);
    }
  }
}
