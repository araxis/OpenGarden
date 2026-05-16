function v2_component_prop(component, name, fallback, i = 0) =
  i >= len(component) ? fallback
  : component[i][0] == name ? component[i][1]
  : v2_component_prop(component, name, fallback, i + 1);
