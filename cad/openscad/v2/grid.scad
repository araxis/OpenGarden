function grid_cell_size(shell_size, rows, cols, padding) =
  [
    shell_size[0] / cols - padding[0] - padding[1],
    shell_size[1] / rows - padding[2] - padding[3]
  ];

function grid_cell_center(shell_size, rows, cols, row, col, padding) =
  let (
    cell_w = shell_size[0] / cols,
    cell_d = shell_size[1] / rows,
    x0 = -shell_size[0] / 2 + (col - 1) * cell_w,
    y0 = -shell_size[1] / 2 + (row - 1) * cell_d,
    left = x0 + padding[0],
    right = x0 + cell_w - padding[1],
    fwd = y0 + padding[2],
    back = y0 + cell_d - padding[3]
  )
    [(left + right) / 2, (fwd + back) / 2];
