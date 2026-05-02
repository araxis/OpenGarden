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

function grid_cell_role(roles, row, col, colCount) =
  let (
    index = row * colCount + col,
    start = grid_token_start(roles, index),
    end = grid_token_end(roles, start)
  )
    grid_token_equals(roles, start, end, "Box") ? "Box"
    : grid_token_equals(roles, start, end, "FillTube") ? "FillTube"
    : "Pot";

function grid_token_equals(spec, start, end, expected, pos = 0) =
  end - start != len(expected) ? false
  : pos >= len(expected) ? true
  : spec[start + pos] == expected[pos] ? grid_token_equals(spec, start, end, expected, pos + 1)
  : false;
