include <BOSL2/std.scad>
include <../grid_helpers.scad>
include <drain_holes.scad>
include <fill_tube.scad>
include <lid_lip.scad>
include <wick_port.scad>
include <box.scad>

FEATURE_PLANE_NONE = "";
FEATURE_PLANE_BOTTOM = "BOTTOM";
FEATURE_PLANE_TOP_LIP = "TOP_LIP";

function feature_plane(name) =
  name == "drain_holes" ? FEATURE_PLANE_BOTTOM
  : name == "fill_tube" ? FEATURE_PLANE_BOTTOM
  : name == "wick_port" ? FEATURE_PLANE_BOTTOM
  : name == "box" ? FEATURE_PLANE_BOTTOM
  : name == "lid_lip" ? FEATURE_PLANE_TOP_LIP
  : FEATURE_PLANE_NONE;

function feature_name(name) =
  feature_token_eq(name, "P") || feature_token_eq(name, "p") || feature_token_eq(name, "Pot") || feature_token_eq(name, "pot")
    || feature_token_eq(name, "DH") || feature_token_eq(name, "dh") || feature_token_eq(name, "DrainHoles") || feature_token_eq(name, "drain_holes") ? "drain_holes"
  : feature_token_eq(name, "F") || feature_token_eq(name, "f") || feature_token_eq(name, "FT") || feature_token_eq(name, "ft")
    || feature_token_eq(name, "FillTube") || feature_token_eq(name, "fill_tube") || feature_token_eq(name, "filltube") ? "fill_tube"
  : feature_token_eq(name, "B") || feature_token_eq(name, "b") || feature_token_eq(name, "Box") || feature_token_eq(name, "box") ? "box"
  : feature_token_eq(name, "WP") || feature_token_eq(name, "wp") || feature_token_eq(name, "WickPort") || feature_token_eq(name, "wick_port") ? "wick_port"
  : feature_token_eq(name, "LL") || feature_token_eq(name, "ll") || feature_token_eq(name, "LidLip") || feature_token_eq(name, "lid_lip") ? "lid_lip"
  : "";

function feature_pattern_name(value, default = "Rectangle") =
  feature_token_eq(value, "C") || feature_token_eq(value, "c") || feature_token_eq(value, "Circle") || feature_token_eq(value, "circle") ? "Circle"
  : feature_token_eq(value, "R") || feature_token_eq(value, "r") || feature_token_eq(value, "Rectangle") || feature_token_eq(value, "rectangle") ? "Rectangle"
  : default;

function cell_feature_for_plane(spec, defaultFeature, target_row, target_col, plane) =
  let (override = cell_feature_override_for_plane(spec, target_row, target_col, plane))
    override != "" ? override
    : plane == FEATURE_PLANE_BOTTOM ? feature_name(defaultFeature)
    : "";

function cell_feature_override_for_plane(spec, target_row, target_col, plane, pos = 0) =
  pos >= len(spec) ? ""
  : let (
      start = feature_skip_spaces(spec, pos),
      raw_end = feature_delim(spec, start, len(spec), ";"),
      end = feature_trim_end(spec, start, raw_end),
      entry_name = feature_entry_name(spec, start, end, target_row, target_col)
    )
      entry_name != "" && feature_plane(entry_name) == plane ? entry_name
      : raw_end >= len(spec) ? ""
      : cell_feature_override_for_plane(spec, target_row, target_col, plane, raw_end + 1);

function feature_string_param(spec, target_row, target_col, plane, key, default = "", pos = 0) =
  pos >= len(spec) ? default
  : let (
      start = feature_skip_spaces(spec, pos),
      raw_end = feature_delim(spec, start, len(spec), ";"),
      end = feature_trim_end(spec, start, raw_end),
      entry_name = feature_entry_name(spec, start, end, target_row, target_col),
      val = entry_name != "" && feature_plane(entry_name) == plane
        ? feature_entry_param_string(spec, start, end, key)
        : ""
    )
      val != "" ? val
      : raw_end >= len(spec) ? default
      : feature_string_param(spec, target_row, target_col, plane, key, default, raw_end + 1);

function feature_number_param(spec, target_row, target_col, plane, key, default = 0, pos = 0) =
  pos >= len(spec) ? default
  : let (
      start = feature_skip_spaces(spec, pos),
      raw_end = feature_delim(spec, start, len(spec), ";"),
      end = feature_trim_end(spec, start, raw_end),
      entry_name = feature_entry_name(spec, start, end, target_row, target_col),
      val = entry_name != "" && feature_plane(entry_name) == plane
        ? feature_entry_param_number(spec, start, end, key)
        : undef
    )
      !is_undef(val) ? val
      : raw_end >= len(spec) ? default
      : feature_number_param(spec, target_row, target_col, plane, key, default, raw_end + 1);

module feature_apply(
  name,
  plane,
  cell_w,
  cell_d,
  cell_h,
  spec,
  row,
  col,
  defaultDrainPattern = "Rectangle",
  defaultDrainRows = 4,
  defaultDrainCols = 4,
  defaultDrainDiameter = 5,
  defaultDrainPadding = 25,
  lidMaxLeft = 0,
  lidMaxRight = 0,
  lidMaxFront = 0,
  lidMaxBack = 0
) {
  if (name == "drain_holes")
    feature_drain_holes(
      cell_w,
      cell_d,
      feature_pattern_name(feature_string_param(spec, row, col, plane, "pattern", defaultDrainPattern), defaultDrainPattern),
      feature_number_param(spec, row, col, plane, "rows", defaultDrainRows),
      feature_number_param(spec, row, col, plane, "cols", defaultDrainCols),
      feature_number_param(spec, row, col, plane, "diameter", defaultDrainDiameter),
      feature_number_param(spec, row, col, plane, "padding", defaultDrainPadding)
    );
  else if (name == "fill_tube")
    feature_fill_tube(
      cell_w,
      cell_d,
      feature_number_param(spec, row, col, plane, "clearance", 0.8)
    );
  else if (name == "wick_port")
    feature_wick_port(feature_number_param(spec, row, col, plane, "diameter", 8));
  else if (name == "lid_lip")
    feature_lid_lip(
      cell_w,
      cell_d,
      feature_number_param(spec, row, col, plane, "depth", 2),
      feature_number_param(spec, row, col, plane, "width", 1.5),
      lidMaxLeft,
      lidMaxRight,
      lidMaxFront,
      lidMaxBack
    );
  else if (name == "box")
    feature_box();
}

function feature_entry_name(spec, start, end, target_row, target_col) =
  let (
    comma = feature_delim(spec, start, end, ","),
    colon = comma >= end ? end : feature_delim(spec, comma + 1, end, ":"),
    name_start = feature_skip_spaces(spec, colon + 1),
    name_end = feature_name_end(spec, name_start, end),
    row = comma >= end ? -1 : round(grid_parse_number(spec, start, comma)),
    col = colon >= end ? -1 : round(grid_parse_number(spec, comma + 1, colon))
  )
    row == target_row && col == target_col && name_end > name_start
      ? feature_name(feature_substring(spec, name_start, name_end))
      : "";

function feature_entry_param_string(spec, start, end, key) =
  let (
    comma = feature_delim(spec, start, end, ","),
    colon = comma >= end ? end : feature_delim(spec, comma + 1, end, ":"),
    name_start = feature_skip_spaces(spec, colon + 1),
    name_end = feature_name_end(spec, name_start, end)
  )
    name_end < end ? feature_param_string(spec, name_end + 1, end, key) : "";

function feature_entry_param_number(spec, start, end, key) =
  let (
    comma = feature_delim(spec, start, end, ","),
    colon = comma >= end ? end : feature_delim(spec, comma + 1, end, ":"),
    name_start = feature_skip_spaces(spec, colon + 1),
    name_end = feature_name_end(spec, name_start, end)
  )
    name_end < end ? feature_param_number(spec, name_end + 1, end, key) : undef;

function feature_param_string(spec, start, end, key, pos = undef) =
  let (scan = is_undef(pos) ? start : pos)
    scan >= end ? ""
    : let (
        token_start = feature_skip_spaces(spec, scan),
        token_end = feature_param_token_end(spec, token_start, end),
        eq = feature_delim(spec, token_start, token_end, "="),
        key_end = feature_trim_end(spec, token_start, eq),
        val_start = feature_skip_spaces(spec, eq + 1),
        val_end = feature_trim_end(spec, val_start, token_end),
        matches = eq < token_end && feature_substring_eq(spec, token_start, key_end, key)
      )
        matches ? feature_substring(spec, val_start, val_end)
        : token_end >= end ? ""
        : feature_param_string(spec, start, end, key, token_end + 1);

function feature_param_number(spec, start, end, key, pos = undef) =
  let (scan = is_undef(pos) ? start : pos)
    scan >= end ? undef
    : let (
        token_start = feature_skip_spaces(spec, scan),
        token_end = feature_param_token_end(spec, token_start, end),
        eq = feature_delim(spec, token_start, token_end, "="),
        key_end = feature_trim_end(spec, token_start, eq),
        matches = eq < token_end && feature_substring_eq(spec, token_start, key_end, key)
      )
        matches ? grid_parse_number(spec, eq + 1, token_end)
        : token_end >= end ? undef
        : feature_param_number(spec, start, end, key, token_end + 1);

function feature_name_end(spec, start, end, pos = undef) =
  let (scan = is_undef(pos) ? start : pos)
    scan >= end || spec[scan] == "," || spec[scan] == " " || spec[scan] == "\t" ? feature_trim_end(spec, start, scan)
    : feature_name_end(spec, start, end, scan + 1);

function feature_param_token_end(spec, start, end, pos = undef) =
  let (scan = is_undef(pos) ? start : pos)
    scan >= end || spec[scan] == "," ? feature_trim_end(spec, start, scan)
    : feature_param_token_end(spec, start, end, scan + 1);

function feature_skip_spaces(spec, pos) =
  pos < len(spec) && (spec[pos] == " " || spec[pos] == "\t") ? feature_skip_spaces(spec, pos + 1) : pos;

function feature_trim_end(spec, start, end) =
  end > start && (spec[end - 1] == " " || spec[end - 1] == "\t") ? feature_trim_end(spec, start, end - 1) : end;

function feature_delim(spec, start, end, delim) =
  start >= end ? end
  : spec[start] == delim ? start
  : feature_delim(spec, start + 1, end, delim);

function feature_substring(spec, start, end, acc = "") =
  start >= end ? acc
  : feature_substring(spec, start + 1, end, str(acc, spec[start]));

function feature_substring_eq(spec, start, end, expected, pos = 0) =
  end - start != len(expected) ? false
  : pos >= len(expected) ? true
  : spec[start + pos] == expected[pos] ? feature_substring_eq(spec, start, end, expected, pos + 1)
  : false;

function feature_token_eq(token, expected, pos = 0) =
  len(token) != len(expected) ? false
  : pos >= len(expected) ? true
  : token[pos] == expected[pos] ? feature_token_eq(token, expected, pos + 1)
  : false;
