function grid_token_start(spec, index, pos = 0, current = 0) =
  current == index ? grid_skip_spaces(spec, pos)
  : pos >= len(spec) ? len(spec)
  : spec[pos] == "," ? grid_token_start(spec, index, pos + 1, current + 1)
  : grid_token_start(spec, index, pos + 1, current);

function grid_track_count(spec, pos = 0, count = 1) =
  len(spec) == 0 ? 1
  : pos >= len(spec) ? count
  : spec[pos] == "," ? grid_track_count(spec, pos + 1, count + 1)
  : grid_track_count(spec, pos + 1, count);

function grid_token_end(spec, start, pos = undef) =
  let (scan = is_undef(pos) ? start : pos)
    scan >= len(spec) || spec[scan] == "," ? grid_trim_end(spec, start, scan)
    : grid_token_end(spec, start, scan + 1);

function grid_skip_spaces(spec, pos) =
  pos < len(spec) && spec[pos] == " " ? grid_skip_spaces(spec, pos + 1) : pos;

function grid_trim_end(spec, start, end) =
  end > start && spec[end - 1] == " " ? grid_trim_end(spec, start, end - 1) : end;

function grid_token_has(spec, start, end, ch, pos = undef) =
  let (scan = is_undef(pos) ? start : pos)
    scan >= end ? false
    : spec[scan] == ch ? true
    : grid_token_has(spec, start, end, ch, scan + 1);

function grid_digit_value(ch) =
  let (found = search(ch, "0123456789"))
    len(found) > 0 ? found[0] : undef;

function grid_parse_number(spec, start, end, pos = undef, value = 0, divisor = 0, found = false) =
  let (
    scan = is_undef(pos) ? start : pos,
    digit = scan < end ? grid_digit_value(spec[scan]) : undef
  )
    scan >= end ? (found ? value : 1)
    : !is_undef(digit) && divisor == 0 ? grid_parse_number(spec, start, end, scan + 1, value * 10 + digit, divisor, true)
    : !is_undef(digit) ? grid_parse_number(spec, start, end, scan + 1, value + digit / (divisor * 10), divisor * 10, true)
    : spec[scan] == "." && divisor == 0 ? grid_parse_number(spec, start, end, scan + 1, value, 1, found)
    : grid_parse_number(spec, start, end, scan + 1, value, divisor, found);

function grid_token_number(spec, index) =
  let (
    start = grid_token_start(spec, index),
    end = grid_token_end(spec, start)
  )
    grid_parse_number(spec, start, end);

function grid_token_is_percent(spec, index) =
  let (
    start = grid_token_start(spec, index),
    end = grid_token_end(spec, start)
  )
    grid_token_has(spec, start, end, "%");

function grid_track_percent_size(total, spec, count, divider, index) =
  let (usable = grid_usable_span(total, count, divider))
    grid_token_is_percent(spec, index) ? usable * grid_token_number(spec, index) / 100 : 0;

function grid_track_relative_weight(spec, index) =
  grid_token_is_percent(spec, index) ? 0 : grid_token_number(spec, index);

function grid_track_percent_sum(total, spec, count, divider) =
  sum([for (index = [0:count - 1]) grid_track_percent_size(total, spec, count, divider, index)]);

function grid_track_relative_sum(spec, count) =
  sum([for (index = [0:count - 1]) grid_track_relative_weight(spec, index)]);

function grid_usable_span(total, count, divider) =
  max(0, total - divider * (count - 1));

function grid_track_size(total, spec, count, divider, index) =
  let (
    usable = grid_usable_span(total, count, divider),
    percent_total = grid_track_percent_sum(total, spec, count, divider),
    percent_size = grid_track_percent_size(total, spec, count, divider, index),
    remaining = max(0, usable - percent_total),
    relative_total = grid_track_relative_sum(spec, count),
    relative_weight = grid_track_relative_weight(spec, index)
  )
    grid_token_is_percent(spec, index)
      ? (percent_total > usable && percent_total > 0 ? percent_size * usable / percent_total : percent_size)
      : (relative_total > 0 ? remaining * relative_weight / relative_total : 0);

function grid_track_edge(total, spec, count, divider, index) =
  -total / 2
  + grid_track_size_before(total, spec, count, divider, index)
  + divider * index;

function grid_track_size_before(total, spec, count, divider, index) =
  index <= 0 ? 0
  : grid_track_size_before(total, spec, count, divider, index - 1)
    + grid_track_size(total, spec, count, divider, index - 1);

function grid_track_edge_from_front(total, spec, count, divider, index) =
  grid_track_edge(total, spec, count, divider, index) + total / 2;

function grid_track_center(total, spec, count, divider, index) =
  grid_track_edge(total, spec, count, divider, index)
  + grid_track_size(total, spec, count, divider, index) / 2;

function grid_span_track_size(total, spec, count, divider, start, span) =
  let (
    safe_start = min(max(0, start), count - 1),
    safe_span = min(max(1, span), count - safe_start),
    last = safe_start + safe_span - 1
  )
    grid_track_edge(total, spec, count, divider, last)
    + grid_track_size(total, spec, count, divider, last)
    - grid_track_edge(total, spec, count, divider, safe_start);

function grid_span_track_center(total, spec, count, divider, start, span) =
  grid_track_edge(total, spec, count, divider, start)
  + grid_span_track_size(total, spec, count, divider, start, span) / 2;

function grid_cell_role(roles, row, col, colCount) =
  grid_cell_role(roles, "", row, col, colCount);

function grid_cell_role(roles, overrides, row, col, colCount) =
  let (override = grid_cell_role_override(overrides, row + 1, col + 1))
    override != "" ? override : grid_row_major_cell_role(roles, row, col, colCount);

function grid_row_major_cell_role(roles, row, col, colCount) =
  let (
    index = row * colCount + col,
    start = grid_token_start(roles, index),
    end = grid_token_end(roles, start)
  )
    grid_role_name(roles, start, end);

function grid_cell_role_override(overrides, target_row, target_col, pos = 0) =
  pos >= len(overrides) ? ""
  : let (
      start = grid_skip_spaces(overrides, pos),
      raw_end = grid_delim_pos(overrides, start, len(overrides), ";"),
      end = grid_trim_end(overrides, start, raw_end),
      role = grid_cell_role_override_entry(overrides, start, end, target_row, target_col)
    )
      role != "" ? role : grid_cell_role_override(overrides, target_row, target_col, raw_end + 1);

function grid_cell_role_override_entry(overrides, start, end, target_row, target_col) =
  let (
    comma = grid_delim_pos(overrides, start, end, ","),
    equals = comma >= end ? end : grid_delim_pos(overrides, comma + 1, end, "="),
    row = comma >= end ? -1 : round(grid_parse_number(overrides, start, comma)),
    col = equals >= end ? -1 : round(grid_parse_number(overrides, comma + 1, equals))
  )
    row == target_row && col == target_col
      ? grid_role_name(overrides, grid_skip_spaces(overrides, equals + 1), grid_trim_end(overrides, equals + 1, end))
      : "";

function grid_cell_span_rows(spans, row, col, rowCount) =
  min(grid_cell_span_value(spans, row + 1, col + 1, 0), rowCount - row);

function grid_cell_span_cols(spans, row, col, colCount) =
  min(grid_cell_span_value(spans, row + 1, col + 1, 1), colCount - col);

function grid_cell_span_value(spans, target_row, target_col, axis, pos = 0) =
  pos >= len(spans) ? 1
  : let (
      start = grid_skip_spaces(spans, pos),
      raw_end = grid_delim_pos(spans, start, len(spans), ";"),
      end = grid_trim_end(spans, start, raw_end),
      value = grid_cell_span_entry_value(spans, start, end, target_row, target_col, axis)
    )
      value > 0 ? value : grid_cell_span_value(spans, target_row, target_col, axis, raw_end + 1);

function grid_cell_span_entry_value(spans, start, end, target_row, target_col, axis) =
  let (
    comma = grid_delim_pos(spans, start, end, ","),
    equals = comma >= end ? end : grid_delim_pos(spans, comma + 1, end, "="),
    x_delim = equals >= end ? end : min(grid_delim_pos(spans, equals + 1, end, "x"), grid_delim_pos(spans, equals + 1, end, "X")),
    row = comma >= end ? -1 : round(grid_parse_number(spans, start, comma)),
    col = equals >= end ? -1 : round(grid_parse_number(spans, comma + 1, equals)),
    row_span = x_delim >= end ? 1 : max(1, round(grid_parse_number(spans, equals + 1, x_delim))),
    col_span = x_delim >= end ? max(1, round(grid_parse_number(spans, equals + 1, end))) : max(1, round(grid_parse_number(spans, x_delim + 1, end)))
  )
    row == target_row && col == target_col ? (axis == 0 ? row_span : col_span) : -1;

function grid_cell_is_covered_by_span(spans, row, col, pos = 0) =
  pos >= len(spans) ? false
  : let (
      start = grid_skip_spaces(spans, pos),
      raw_end = grid_delim_pos(spans, start, len(spans), ";"),
      end = grid_trim_end(spans, start, raw_end)
    )
      grid_cell_is_covered_by_span_entry(spans, start, end, row + 1, col + 1)
        ? true
        : grid_cell_is_covered_by_span(spans, row, col, raw_end + 1);

function grid_cell_is_covered_by_span_entry(spans, start, end, target_row, target_col) =
  let (
    comma = grid_delim_pos(spans, start, end, ","),
    equals = comma >= end ? end : grid_delim_pos(spans, comma + 1, end, "="),
    x_delim = equals >= end ? end : min(grid_delim_pos(spans, equals + 1, end, "x"), grid_delim_pos(spans, equals + 1, end, "X")),
    row = comma >= end ? -1 : round(grid_parse_number(spans, start, comma)),
    col = equals >= end ? -1 : round(grid_parse_number(spans, comma + 1, equals)),
    row_span = x_delim >= end ? 1 : max(1, round(grid_parse_number(spans, equals + 1, x_delim))),
    col_span = x_delim >= end ? max(1, round(grid_parse_number(spans, equals + 1, end))) : max(1, round(grid_parse_number(spans, x_delim + 1, end)))
  )
    !(row == target_row && col == target_col)
    && row <= target_row && target_row < row + row_span
    && col <= target_col && target_col < col + col_span;

function grid_vertical_divider_blocked(spans, row, boundary, pos = 0) =
  pos >= len(spans) ? false
  : let (
      start = grid_skip_spaces(spans, pos),
      raw_end = grid_delim_pos(spans, start, len(spans), ";"),
      end = grid_trim_end(spans, start, raw_end)
    )
      grid_vertical_divider_blocked_entry(spans, start, end, row + 1, boundary)
        ? true
        : grid_vertical_divider_blocked(spans, row, boundary, raw_end + 1);

function grid_vertical_divider_blocked_entry(spans, start, end, target_row, boundary) =
  let (
    comma = grid_delim_pos(spans, start, end, ","),
    equals = comma >= end ? end : grid_delim_pos(spans, comma + 1, end, "="),
    x_delim = equals >= end ? end : min(grid_delim_pos(spans, equals + 1, end, "x"), grid_delim_pos(spans, equals + 1, end, "X")),
    row = comma >= end ? -1 : round(grid_parse_number(spans, start, comma)),
    col = equals >= end ? -1 : round(grid_parse_number(spans, comma + 1, equals)),
    row_span = x_delim >= end ? 1 : max(1, round(grid_parse_number(spans, equals + 1, x_delim))),
    col_span = x_delim >= end ? max(1, round(grid_parse_number(spans, equals + 1, end))) : max(1, round(grid_parse_number(spans, x_delim + 1, end)))
  )
    row <= target_row && target_row < row + row_span
    && col <= boundary && boundary < col + col_span - 1;

function grid_horizontal_divider_blocked(spans, boundary, col, pos = 0) =
  pos >= len(spans) ? false
  : let (
      start = grid_skip_spaces(spans, pos),
      raw_end = grid_delim_pos(spans, start, len(spans), ";"),
      end = grid_trim_end(spans, start, raw_end)
    )
      grid_horizontal_divider_blocked_entry(spans, start, end, boundary, col + 1)
        ? true
        : grid_horizontal_divider_blocked(spans, boundary, col, raw_end + 1);

function grid_horizontal_divider_blocked_entry(spans, start, end, boundary, target_col) =
  let (
    comma = grid_delim_pos(spans, start, end, ","),
    equals = comma >= end ? end : grid_delim_pos(spans, comma + 1, end, "="),
    x_delim = equals >= end ? end : min(grid_delim_pos(spans, equals + 1, end, "x"), grid_delim_pos(spans, equals + 1, end, "X")),
    row = comma >= end ? -1 : round(grid_parse_number(spans, start, comma)),
    col = equals >= end ? -1 : round(grid_parse_number(spans, comma + 1, equals)),
    row_span = x_delim >= end ? 1 : max(1, round(grid_parse_number(spans, equals + 1, x_delim))),
    col_span = x_delim >= end ? max(1, round(grid_parse_number(spans, equals + 1, end))) : max(1, round(grid_parse_number(spans, x_delim + 1, end)))
  )
    row <= boundary && boundary < row + row_span - 1
    && col <= target_col && target_col < col + col_span;

function grid_role_name(spec, start, end) =
  grid_token_equals(spec, start, end, "B") || grid_token_equals(spec, start, end, "b") || grid_token_equals(spec, start, end, "Box") || grid_token_equals(spec, start, end, "box") ? "Box"
  : grid_token_equals(spec, start, end, "F") || grid_token_equals(spec, start, end, "f") || grid_token_equals(spec, start, end, "FillTube") || grid_token_equals(spec, start, end, "filltube") ? "FillTube"
  : "Pot";

function grid_delim_pos(spec, start, end, delim) =
  start >= end ? end
  : spec[start] == delim ? start
  : grid_delim_pos(spec, start + 1, end, delim);

function grid_token_equals(spec, start, end, expected, pos = 0) =
  end - start != len(expected) ? false
  : pos >= len(expected) ? true
  : spec[start + pos] == expected[pos] ? grid_token_equals(spec, start, end, expected, pos + 1)
  : false;
