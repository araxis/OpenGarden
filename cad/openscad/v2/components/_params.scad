function param_index(params, key, pos = 0) =
  pos >= len(params) ? -1
  : params[pos][0] == key ? pos
  : param_index(params, key, pos + 1);

function param_value(params, key, default = undef) =
  let (index = param_index(params, key))
    index < 0 ? default : params[index][1];

function param_num(params, key, default = 0) =
  let (value = param_value(params, key, default))
    is_num(value) ? value : default;

function param_str(params, key, default = "") =
  let (value = param_value(params, key, default))
    is_string(value) ? value : default;

function param_bool(params, key, default = false) =
  let (value = param_value(params, key, default))
    is_bool(value) ? value : default;
