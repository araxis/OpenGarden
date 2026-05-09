// Grid layout primitives (v2)
//
// Owns: rows, columns, sizes, spans, splits, margin, padding, wall_fusion
//       convenience flag, optional gap-fill.
//
// Pure data layer. Produces a list of cells. Does NOT draw anything.
//
// Cell record shape:
//   [cx, cy, cell_w, cell_d, cell_h, row, col]
//
// Where:
//   cx, cy        cell center in local (post-padding) coords
//   cell_w, cell_d  drawing area handed to the component (after padding)
//   cell_h        cell height handed to the component
//   row, col      1-indexed cell identity (post-span/split), used for cell_id
//
// Sizing string syntax (v2 extension over v1):
//   "1*"            single dynamic track (full)
//   "1*, 1*"        two equal dynamic tracks
//   "10, 1*, 10"    fixed-mm bookends with dynamic middle  (NEW vs v1)
//   "2*, 1*"        weighted dynamic
//
// Spans:  "row,col=rowspanxcolspan; ..."  (sparse merge)
// Splits: "row,col=rowsplitxcolsplit; ..." (sparse subdivide — NEW in v2)
//
// Margin / padding (per-cell sparse overrides on top of grid-level defaults):
//   default_margin  = [left, right, fwd, back]   space OUTSIDE cell
//   default_padding = [left, right, fwd, back]   space INSIDE cell
//
// Status: first-pass implementation. Supports basic fixed-mm, percent, and
// weighted-star tracks plus uniform margin/padding. Spans, splits, and sparse
// overrides remain contract placeholders for later commits.

// ===== Public API =====

// grid_layout — returns the list of cell records described above.
function grid_layout(
  rows_str            = "1*",
  cols_str            = "1*",
  spans_str           = "",
  splits_str          = "",
  default_margin      = [0, 0, 0, 0],
  default_padding     = [0, 0, 0, 0],
  margin_overrides    = "",
  padding_overrides   = "",
  wall_fusion         = false,
  fusion_thickness    = 0,
  total_width         = 70,
  total_depth         = 70,
  total_height        = 100
) =
  let (
    row_count = v2_grid_track_count(rows_str),
    col_count = v2_grid_track_count(cols_str),
    margin = wall_fusion
      ? [-fusion_thickness / 2, -fusion_thickness / 2, -fusion_thickness / 2, -fusion_thickness / 2]
      : default_margin,
    padding = default_padding
  )
    [
      for (row = [0:row_count - 1])
        for (col = [0:col_count - 1])
          let (
            raw_x0 = v2_grid_track_edge(total_width, cols_str, col_count, col),
            raw_x1 = raw_x0 + v2_grid_track_size(total_width, cols_str, col_count, col),
            raw_y0 = v2_grid_track_edge(total_depth, rows_str, row_count, row),
            raw_y1 = raw_y0 + v2_grid_track_size(total_depth, rows_str, row_count, row),
            cell_x0 = raw_x0 + margin[0] + padding[0],
            cell_x1 = raw_x1 - margin[1] - padding[1],
            cell_y0 = raw_y0 + margin[2] + padding[2],
            cell_y1 = raw_y1 - margin[3] - padding[3],
            cell_w = max(0.01, cell_x1 - cell_x0),
            cell_d = max(0.01, cell_y1 - cell_y0)
          )
            [
              (cell_x0 + cell_x1) / 2,
              (cell_y0 + cell_y1) / 2,
              cell_w,
              cell_d,
              total_height,
              row + 1,
              col + 1
            ]
    ];

// fill_gaps_geometry — optional grid-level wall fill (for "framed" look)
//
// Drawn when components declare wallThickness=0 and the user wants the
// continuous-shell look. Owns its own chamfer because the geometry is
// owned here, not in any component.
//
// Status: scaffold.
module fill_gaps_geometry(
  cells,               // output of grid_layout()
  total_width,
  total_depth,
  total_height,
  wall_thickness  = 2,
  chamfer         = 0,
  chamfer_back    = false
) {
  // empty
}

function v2_grid_track_count(spec, pos = 0, count = 1) =
  len(spec) == 0 ? 1
  : pos >= len(spec) ? count
  : spec[pos] == "," ? v2_grid_track_count(spec, pos + 1, count + 1)
  : v2_grid_track_count(spec, pos + 1, count);

function v2_grid_token_start(spec, index, pos = 0, current = 0) =
  current == index ? v2_grid_skip_spaces(spec, pos)
  : pos >= len(spec) ? len(spec)
  : spec[pos] == "," ? v2_grid_token_start(spec, index, pos + 1, current + 1)
  : v2_grid_token_start(spec, index, pos + 1, current);

function v2_grid_token_end(spec, start, pos = undef) =
  let (scan = is_undef(pos) ? start : pos)
    scan >= len(spec) || spec[scan] == "," ? v2_grid_trim_end(spec, start, scan)
    : v2_grid_token_end(spec, start, scan + 1);

function v2_grid_skip_spaces(spec, pos) =
  pos < len(spec) && (spec[pos] == " " || spec[pos] == "\t") ? v2_grid_skip_spaces(spec, pos + 1) : pos;

function v2_grid_trim_end(spec, start, end) =
  end > start && (spec[end - 1] == " " || spec[end - 1] == "\t") ? v2_grid_trim_end(spec, start, end - 1) : end;

function v2_grid_token_has(spec, start, end, ch, pos = undef) =
  let (scan = is_undef(pos) ? start : pos)
    scan >= end ? false
    : spec[scan] == ch ? true
    : v2_grid_token_has(spec, start, end, ch, scan + 1);

function v2_grid_digit_value(ch) =
  let (found = search(ch, "0123456789"))
    len(found) > 0 ? found[0] : undef;

function v2_grid_parse_number(spec, start, end, pos = undef, value = 0, divisor = 0, found = false) =
  let (
    scan = is_undef(pos) ? start : pos,
    digit = scan < end ? v2_grid_digit_value(spec[scan]) : undef
  )
    scan >= end ? (found ? value : 1)
    : !is_undef(digit) && divisor == 0 ? v2_grid_parse_number(spec, start, end, scan + 1, value * 10 + digit, divisor, true)
    : !is_undef(digit) ? v2_grid_parse_number(spec, start, end, scan + 1, value + digit / (divisor * 10), divisor * 10, true)
    : spec[scan] == "." && divisor == 0 ? v2_grid_parse_number(spec, start, end, scan + 1, value, 1, found)
    : v2_grid_parse_number(spec, start, end, scan + 1, value, divisor, found);

function v2_grid_token_number(spec, index) =
  let (
    start = v2_grid_token_start(spec, index),
    end = v2_grid_token_end(spec, start)
  )
    v2_grid_parse_number(spec, start, end);

function v2_grid_token_is_star(spec, index) =
  let (
    start = v2_grid_token_start(spec, index),
    end = v2_grid_token_end(spec, start)
  )
    v2_grid_token_has(spec, start, end, "*");

function v2_grid_token_is_percent(spec, index) =
  let (
    start = v2_grid_token_start(spec, index),
    end = v2_grid_token_end(spec, start)
  )
    v2_grid_token_has(spec, start, end, "%");

function v2_grid_fixed_sum(spec, count) =
  sum([
    for (index = [0:count - 1])
      (!v2_grid_token_is_star(spec, index) && !v2_grid_token_is_percent(spec, index))
        ? v2_grid_token_number(spec, index)
        : 0
  ]);

function v2_grid_percent_sum(total, spec, count) =
  sum([
    for (index = [0:count - 1])
      v2_grid_token_is_percent(spec, index)
        ? total * v2_grid_token_number(spec, index) / 100
        : 0
  ]);

function v2_grid_star_weight_sum(spec, count) =
  sum([
    for (index = [0:count - 1])
      v2_grid_token_is_star(spec, index) ? v2_grid_token_number(spec, index) : 0
  ]);

function v2_grid_track_size(total, spec, count, index) =
  let (
    fixed_total = v2_grid_fixed_sum(spec, count),
    percent_total = v2_grid_percent_sum(total, spec, count),
    star_total = v2_grid_star_weight_sum(spec, count),
    remaining = max(0, total - fixed_total - percent_total),
    star_weight = v2_grid_token_is_star(spec, index) ? v2_grid_token_number(spec, index) : 0
  )
    v2_grid_token_is_percent(spec, index) ? total * v2_grid_token_number(spec, index) / 100
    : v2_grid_token_is_star(spec, index) ? (star_total > 0 ? remaining * star_weight / star_total : 0)
    : v2_grid_token_number(spec, index);

function v2_grid_track_size_before(total, spec, count, index) =
  index <= 0 ? 0
  : v2_grid_track_size_before(total, spec, count, index - 1)
    + v2_grid_track_size(total, spec, count, index - 1);

function v2_grid_track_edge(total, spec, count, index) =
  -total / 2 + v2_grid_track_size_before(total, spec, count, index);
