include <../grid_helpers.scad>

function v2_grid_track_count(spec) =
  max(1, grid_track_count(spec));

function v2_grid_usable_span(total, count, divider) =
  max(0, total - divider * max(0, count - 1));

function v2_grid_token_start(spec, index) =
  grid_token_start(spec, index);

function v2_grid_token_end(spec, index) =
  let (start = v2_grid_token_start(spec, index))
    grid_token_end(spec, start);

function v2_grid_token_is_percent(spec, index) =
  let (
    start = v2_grid_token_start(spec, index),
    end = v2_grid_token_end(spec, index)
  )
    grid_token_has(spec, start, end, "%");

function v2_grid_token_is_star(spec, index) =
  let (
    start = v2_grid_token_start(spec, index),
    end = v2_grid_token_end(spec, index)
  )
    grid_token_has(spec, start, end, "*");

function v2_grid_token_number(spec, index) =
  let (
    start = v2_grid_token_start(spec, index),
    end = v2_grid_token_end(spec, index)
  )
    grid_parse_number(spec, start, end);

function v2_grid_track_fixed(spec, index) =
  !v2_grid_token_is_percent(spec, index) && !v2_grid_token_is_star(spec, index)
    ? max(0, v2_grid_token_number(spec, index))
    : 0;

function v2_grid_track_percent(total, spec, count, divider, index) =
  v2_grid_token_is_percent(spec, index)
    ? v2_grid_usable_span(total, count, divider) * max(0, v2_grid_token_number(spec, index)) / 100
    : 0;

function v2_grid_track_star_weight(spec, index) =
  v2_grid_token_is_star(spec, index)
    ? max(0, v2_grid_token_number(spec, index))
    : 0;

function v2_grid_fixed_sum(spec, count) =
  sum([for (i = [0:count - 1]) v2_grid_track_fixed(spec, i)]);

function v2_grid_percent_sum(total, spec, count, divider) =
  sum([for (i = [0:count - 1]) v2_grid_track_percent(total, spec, count, divider, i)]);

function v2_grid_star_sum(spec, count) =
  sum([for (i = [0:count - 1]) v2_grid_track_star_weight(spec, i)]);

function v2_grid_reserved_scale(total, spec, count, divider) =
  let (
    usable = v2_grid_usable_span(total, count, divider),
    reserved = v2_grid_fixed_sum(spec, count) + v2_grid_percent_sum(total, spec, count, divider)
  )
    reserved > usable && reserved > 0 ? usable / reserved : 1;

function v2_grid_remaining_for_stars(total, spec, count, divider) =
  let (
    usable = v2_grid_usable_span(total, count, divider),
    fixed_sum = v2_grid_fixed_sum(spec, count),
    percent_sum = v2_grid_percent_sum(total, spec, count, divider),
    scale = v2_grid_reserved_scale(total, spec, count, divider)
  )
    max(0, usable - (fixed_sum + percent_sum) * scale);

function v2_grid_track_size(total, spec, count, divider, index) =
  let (
    scale = v2_grid_reserved_scale(total, spec, count, divider),
    fixed = v2_grid_track_fixed(spec, index),
    percent = v2_grid_track_percent(total, spec, count, divider, index),
    star_weight = v2_grid_track_star_weight(spec, index),
    star_sum = v2_grid_star_sum(spec, count),
    star_space = v2_grid_remaining_for_stars(total, spec, count, divider)
  )
    v2_grid_token_is_star(spec, index)
      ? (star_sum > 0 ? star_space * star_weight / star_sum : 0)
      : (fixed + percent) * scale;

function v2_grid_track_size_before(total, spec, count, divider, index) =
  index <= 0 ? 0
  : v2_grid_track_size_before(total, spec, count, divider, index - 1)
    + v2_grid_track_size(total, spec, count, divider, index - 1);

function v2_grid_track_edge(total, spec, count, divider, index) =
  -total / 2 + v2_grid_track_size_before(total, spec, count, divider, index) + divider * index;

function v2_grid_track_center(total, spec, count, divider, index) =
  v2_grid_track_edge(total, spec, count, divider, index)
  + v2_grid_track_size(total, spec, count, divider, index) / 2;

function grid_cell_size(shell_size, row_spec, col_spec, row, col, padding, divider = 0) =
  let (
    rows = v2_grid_track_count(row_spec),
    cols = v2_grid_track_count(col_spec),
    safe_row = min(max(1, row), rows) - 1,
    safe_col = min(max(1, col), cols) - 1
  )
  [
    max(0, v2_grid_track_size(shell_size[0], col_spec, cols, divider, safe_col) - padding[0] - padding[1]),
    max(0, v2_grid_track_size(shell_size[1], row_spec, rows, divider, safe_row) - padding[2] - padding[3])
  ];

function grid_cell_center(shell_size, row_spec, col_spec, row, col, padding, divider = 0) =
  let (
    rows = v2_grid_track_count(row_spec),
    cols = v2_grid_track_count(col_spec),
    safe_row = min(max(1, row), rows) - 1,
    safe_col = min(max(1, col), cols) - 1,
    base_x = v2_grid_track_center(shell_size[0], col_spec, cols, divider, safe_col),
    base_y = v2_grid_track_center(shell_size[1], row_spec, rows, divider, safe_row)
  )
  [
    base_x + (padding[0] - padding[1]) / 2,
    base_y + (padding[2] - padding[3]) / 2
  ];
