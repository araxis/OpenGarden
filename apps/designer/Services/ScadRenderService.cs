using Microsoft.JSInterop;
using OpenGarden.Designer.Models;

namespace OpenGarden.Designer.Services;

/// <summary>
/// Singleton implementation of <see cref="IScadRenderService"/>.
///
/// Lifecycle
/// ─────────
/// 1. <see cref="InitializeAsync"/> is called by PreviewPanel on first render.
///    It fires the background init task exactly once (guarded by <see cref="_initTask"/>).
/// 2. The JS init function (<c>openGardenScadRenderer.init</c>) loads openscad-wasm,
///    fetches every SCAD file listed in <c>wwwroot/scad/manifest.json</c>, and mounts
///    them into the WASM virtual filesystem.
/// 3. As init progresses, JS calls back into <see cref="OnProgress"/> via
///    <see cref="DotNetObjectReference{T}"/>, which updates <see cref="InitStatus"/>
///    and raises <see cref="StatusChanged"/> so the UI can re-render.
/// 4. Once <see cref="IsReady"/> is true, <see cref="RenderAsync"/> passes the
///    OpenSCAD customizer parameter block to JS, which prepends it to main.scad
///    and invokes OpenSCAD synchronously in the WASM instance.
///
/// Thread safety
/// ─────────────
/// Blazor WASM runs on a single thread, so there are no true concurrency concerns.
/// <see cref="_renderLock"/> prevents overlapping render calls (e.g. rapid UI clicks).
/// </summary>
public sealed class ScadRenderService : IScadRenderService, IAsyncDisposable
{
    // Base URL for SCAD static assets served from wwwroot/scad/.
    // Relative URL works because Blazor WASM is always served from the app origin.
    private const string ScadBaseUrl = "scad/";

    private readonly IJSRuntime _js;

    private DotNetObjectReference<ScadRenderService>? _dotNetRef;
    private Task? _initTask;
    private readonly SemaphoreSlim _renderLock = new(1, 1);

    private bool   _isReady;
    private string _initStatus = "Renderer not started.";

    public bool   IsReady    => _isReady;
    public string InitStatus => _initStatus;

    public event Action StatusChanged = delegate { };

    public ScadRenderService(IJSRuntime js)
    {
        _js = js;
    }

    /// <inheritdoc/>
    public ValueTask InitializeAsync()
    {
        // Only start the init task once.
        if (_initTask is null)
        {
            _dotNetRef = DotNetObjectReference.Create(this);
            _initTask  = RunInitAsync();
        }
        return ValueTask.CompletedTask;
    }

    private async Task RunInitAsync()
    {
        try
        {
            await _js.InvokeVoidAsync("openGardenScadRenderer.init", ScadBaseUrl, _dotNetRef);
        }
        catch (JSException ex)
        {
            // OnProgress will already have been called with the error message by JS,
            // but catch here as a safety net so the Task doesn't stay faulted silently.
            SetStatus($"Renderer failed: {ex.Message}");
        }
    }

    /// <summary>
    /// Called by JS via <see cref="DotNetObjectReference{T}"/> as init progresses.
    /// Also called with "Ready" on success or an error string on failure.
    /// </summary>
    [JSInvokable("OnNotify")] // This tells JS to look for this name specifically
    public void OnProgress(string message)
    {
        _isReady = string.Equals(message, "Ready", StringComparison.Ordinal);
        SetStatus(message);
    }

    /// <inheritdoc/>
    public async Task<RendererResult> RenderAsync(string scadConfig)
    {
        if (!_isReady)
        {
            return new RendererResult
            {
                Ok      = false,
                Message = "Renderer is not ready yet."
            };
        }

        await _renderLock.WaitAsync();
        try
        {
            return await _js.InvokeAsync<RendererResult>(
                "openGardenScadRenderer.render",
                scadConfig);
        }
        catch (JSException ex)
        {
            return new RendererResult { Ok = false, Message = ex.Message };
        }
        finally
        {
            _renderLock.Release();
        }
    }

    private void SetStatus(string message)
    {
        _initStatus = message;
        StatusChanged.Invoke();
    }

    public ValueTask DisposeAsync()
    {
        _dotNetRef?.Dispose();
        _renderLock.Dispose();
        return ValueTask.CompletedTask;
    }
}
