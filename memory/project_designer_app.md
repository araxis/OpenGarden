---
name: OpenGarden designer app
description: Blazor WASM app at apps/designer — live pot designer with MudBlazor UI, OpenSCAD WASM preview, current panel layout
type: project
---
# Designer app — `apps/designer/`

**Stack:** Blazor WebAssembly, .NET 10, MudBlazor 9.4.0

**What it does:**
- UI to configure all pot/grid parameters (sliders for numerics)
- Generates OpenSCAD config text for copy-paste
- Runs OpenSCAD via WASM in-browser → live STL preview in `PreviewPanel`
- `GeneratedScadPanel` shows the raw SCAD config

**Key files:**
- `Models/DesignerState.cs` — all state + `GenerateScadConfig()`, `CellFeatureConfig`, per-feature models
- `Services/ScadRenderService.cs` — WASM render pipeline
- `Components/` — one component per UI panel
- `Pages/Home.razor` — root page wiring everything together

**Current panel layout (as of 2026-05-09):**
Left column (2/3 width): DesignerHeader → OutputPanel + OpenGridEditor → PotSizePanel + WallsAndHolesPanel → InsertGridPanel → CellFeaturesPanel (full width)
Right column (1/3 width): PreviewPanel → GeneratedScadPanel

**Recent shipped changes:**
- PR #35: simplify lid_lip to internal recess; fix ordering / multi-plane / span preservation; designer move-up/down controls; default Lid Lip Width 8 → 1
- PR #34: CellFeaturesPanel promoted to its own top-level panel
- PR #33: All numeric inputs replaced with MudSlider
- PR #32: Top-level hole pattern inputs removed — per-cell only
- PRs #27-30: WASM render pipeline fixed

**Build note:** `wwwroot/scad/` is auto-generated at build time by MSBuild target `CopyScadFiles` — copies `cad/openscad/` + `cad/bosl2/`. Not committed; CI populates it.

**WASM render quirks:**
- OpenSCAD WASM can produce late errors after emitting valid STL bytes — `ScadRenderService` guards against these
- Table cleanup faults are tolerated (not treated as render failure)

**v2 architecture impact:** When the SCAD-side v2 rewrite happens (see [opengarden_v2_architecture_plan.md](opengarden_v2_architecture_plan.md)), the designer state model and panels will need a parallel rewrite — component picker per cell, then component-specific editor. The `CellFeaturesPanel` becomes a `ComponentsPanel`. Plane / multi-feature concepts retire.
