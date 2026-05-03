using OpenGarden.Designer.Models;

namespace OpenGarden.Designer.Services;

/// <summary>
/// Manages the OpenSCAD WASM renderer lifecycle and exposes a single
/// <see cref="RenderAsync"/> method for on-demand STL generation.
///
/// The service is registered as a singleton.  Call <see cref="InitializeAsync"/>
/// once on app startup (e.g. from PreviewPanel.OnInitializedAsync).  Subsequent
/// calls are no-ops — the WASM instance and mounted SCAD files persist for the
/// lifetime of the page.
/// </summary>
public interface IScadRenderService
{
    /// <summary>True once WASM is loaded and all SCAD files are mounted.</summary>
    bool IsReady { get; }

    /// <summary>
    /// Human-readable initialisation status shown in the preview panel.
    /// Examples: "Loading OpenSCAD…", "Loading files… (42/67)", "Ready",
    /// "Renderer failed: …"
    /// </summary>
    string InitStatus { get; }

    /// <summary>Raised on the calling thread whenever <see cref="InitStatus"/> changes.</summary>
    event Action StatusChanged;

    /// <summary>
    /// Kicks off background initialisation (WASM load + file mounting).
    /// Safe to call multiple times — only the first call has any effect.
    /// </summary>
    ValueTask InitializeAsync();

    /// <summary>
    /// Renders an STL from the given OpenSCAD customizer parameter block.
    /// The block should be the output of <see cref="Models.DesignerState.GenerateScadConfig"/>.
    /// </summary>
    /// <returns>
    /// A <see cref="RendererResult"/> describing success or failure, the download
    /// URL of the generated blob, and timing information.
    /// </returns>
    Task<RendererResult> RenderAsync(string scadConfig);
}
