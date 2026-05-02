#!/usr/bin/env bash
set -euo pipefail

BASE_SHA="${BASE_SHA:?BASE_SHA is required}"
HEAD_SHA="${HEAD_SHA:?HEAD_SHA is required}"
OUTPUT_DIR="${OUTPUT_DIR:-artifacts/stl}"
MAIN_SCAD="cad/openscad/main.scad"

if [ "$BASE_SHA" = "$HEAD_SHA" ]; then
  BASE_SHA="$(git rev-parse "${HEAD_SHA}^")"
fi

mkdir -p "$OUTPUT_DIR"

mapfile -t changed_scad_files < <(
  git diff --name-only --diff-filter=ACMR "$BASE_SHA" "$HEAD_SHA" -- 'cad/openscad/*.scad' | sort -u
)

if [ "${#changed_scad_files[@]}" -eq 0 ]; then
  echo "No changed OpenSCAD files found."
  exit 0
fi

render_mode() {
  local source_name="$1"
  local mode="$2"
  local suffix="$3"
  local open_grid_support="${4:-true}"
  local output_file="$OUTPUT_DIR/${source_name}--${suffix}.stl"

  echo "Rendering $output_file"
  openscad \
    --hardwarnings \
    -o "$output_file" \
    -D "Output_Mode=\"$mode\"" \
    -D "OpenGrid_Support=$open_grid_support" \
    -D "Render_Quality=\"Export\"" \
    "$MAIN_SCAD"
}

for scad_file in "${changed_scad_files[@]}"; do
  source_name="$(basename "$scad_file" .scad)"

  case "$scad_file" in
    cad/openscad/main.scad)
      render_mode "$source_name" "Assembly" "assembly" true
      render_mode "$source_name" "Freestanding Pot" "freestanding-pot" false
      render_mode "$source_name" "Print Layout" "print-layout-opengrid" true
      render_mode "$source_name" "Print Layout" "print-layout-freestanding" false
      ;;
    cad/openscad/pot_holder_frame.scad|cad/openscad/back_plate.scad)
      render_mode "$source_name" "Holder Only" "holder-only" true
      render_mode "$source_name" "Assembly" "assembly" true
      ;;
    cad/openscad/pot_insert.scad)
      render_mode "$source_name" "Pot Insert Only" "pot-insert-only" false
      render_mode "$source_name" "Print Layout" "print-layout-freestanding" false
      ;;
    cad/openscad/pot_drain.scad)
      render_mode "$source_name" "Drain Only" "drain-only" false
      render_mode "$source_name" "Print Layout" "print-layout-freestanding" false
      ;;
    cad/openscad/anchor_names.scad)
      render_mode "$source_name" "Assembly" "assembly" true
      render_mode "$source_name" "Print Layout" "print-layout-freestanding" false
      ;;
    cad/openscad/grid_helpers.scad)
      render_mode "$source_name" "Pot Insert Only" "pot-insert-only" false
      render_mode "$source_name" "Print Layout" "print-layout-freestanding" false
      ;;
    *)
      echo "No render mapping for $scad_file; skipping."
      ;;
  esac
done

echo "Rendered STL files:"
find "$OUTPUT_DIR" -type f -name '*.stl' -print | sort
