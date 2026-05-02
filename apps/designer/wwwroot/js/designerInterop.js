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
        window.openGardenDesigner.openScad = await module.default({ noInitialRun: true });
      }

      const instance = window.openGardenDesigner.openScad;
      const inputPath = "/opengarden-preview.scad";
      const outputPath = "/opengarden-preview.stl";

      try {
        instance.FS.unlink(outputPath);
      } catch {
      }

      instance.FS.writeFile(inputPath, scadCode);
      instance.callMain([inputPath, "--enable=manifold", "-o", outputPath]);

      const output = instance.FS.readFile(outputPath);
      const blob = new Blob([output], { type: "model/stl" });
      const downloadUrl = URL.createObjectURL(blob);

      return {
        ok: true,
        message: "Preview STL generated.",
        downloadUrl,
        fileName: "opengarden-preview.stl",
        byteLength: output.byteLength,
        elapsedMs: performance.now() - started
      };
    } catch (error) {
      return {
        ok: false,
        message: error?.message ?? "OpenSCAD render failed.",
        downloadUrl: "",
        fileName: "",
        byteLength: 0,
        elapsedMs: performance.now() - started
      };
    }
  }
};
