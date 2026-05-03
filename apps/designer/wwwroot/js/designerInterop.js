window.openGardenDesigner = {
  openScad: null,
  copyText: async (text) => {
    if (!navigator.clipboard) {
      return false;
    }

    await navigator.clipboard.writeText(text);
    return true;
  },
  prefersDarkMode: () => window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches,
  downloadUrl: (url, fileName) => {
    const link = document.createElement("a");
    link.href = url;
    link.download = fileName;
    document.body.append(link);
    link.click();
    link.remove();
  },
  renderPreviewStl: async (scadCode) => {
    const started = performance.now();

    try {
      if (!window.openGardenDesigner.openScad) {
        const module = await import("https://cdn.jsdelivr.net/npm/openscad-wasm@0.0.4/openscad.js");
        window.openGardenDesigner.openScad = await module.createOpenSCAD({
          noInitialRun: true
        });
      }

      const output = await window.openGardenDesigner.openScad.renderToStl(scadCode);
      const blob = new Blob([output], { type: "model/stl" });
      const downloadUrl = URL.createObjectURL(blob);

      return {
        ok: true,
        message: "Preview STL generated.",
        downloadUrl,
        fileName: "opengarden-preview.stl",
        byteLength: blob.size,
        elapsedMs: performance.now() - started
      };
    } catch (error) {
      const message = error?.message
        ?? error?.toString?.()
        ?? JSON.stringify(error)
        ?? "OpenSCAD render failed.";

      return {
        ok: false,
        message,
        downloadUrl: "",
        fileName: "",
        byteLength: 0,
        elapsedMs: performance.now() - started
      };
    }
  }
};
