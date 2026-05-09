---
name: OpenSCAD local environment
description: How to invoke OpenSCAD on this machine for OpenGarden STL exports
type: reference
---
**OpenSCAD path on this machine:** `C:\Program Files\OpenSCAD (Nightly)`
**BOSL2:** installed globally, picked up automatically.

**STL export from PowerShell:**
```powershell
& 'C:\Program Files\OpenSCAD (Nightly)\openscad.com' -o output.stl cad\openscad\main.scad
```

**Export a specific output mode:**
```powershell
& 'C:\Program Files\OpenSCAD (Nightly)\openscad.com' -D 'Output_Mode="Print Layout"' -o print-layout.stl cad\openscad\main.scad
```

Notes:
- Use `openscad.com` (not `.exe`) for command-line exports — `.exe` is the GUI variant
- `Render_Quality="Export"` raises facet count for final STL quality; `"Preview"` is faster for iteration
- See `CONTRIBUTING.md` in the repo — PRs touching `.scad` files must list which `Output_Mode` values were verified
- GitHub Actions auto-renders STL previews on PRs that touch `.scad` files (the `Render OpenSCAD STL previews` workflow)
