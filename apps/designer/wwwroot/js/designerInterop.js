window.openGardenDesigner = {
  openScad: null,
  lastPreviewStl: null,
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
  renderPreviewStl: async (scadCode, canvas) => {
    const started = performance.now();

    try {
      if (!window.openGardenDesigner.openScad) {
        const module = await import("https://cdn.jsdelivr.net/npm/openscad-wasm@0.0.4/openscad.js");
        window.openGardenDesigner.openScad = await module.createOpenSCAD({
          noInitialRun: true
        });
      }

      const output = await window.openGardenDesigner.openScad.renderToStl(scadCode);
      window.openGardenDesigner.lastPreviewStl = output;
      if (canvas) {
        window.openGardenDesigner.drawStlPreview(canvas, output);
      }

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
  },
  drawLastPreviewStl: (canvas) => {
    if (canvas && window.openGardenDesigner.lastPreviewStl) {
      window.openGardenDesigner.drawStlPreview(canvas, window.openGardenDesigner.lastPreviewStl);
    }
  },
  drawStlPreview: (canvas, stlBytes) => {
    const bytes = stlBytes instanceof Uint8Array ? stlBytes : new Uint8Array(stlBytes);
    const triangles = window.openGardenDesigner.readBinaryStl(bytes);
    const context = canvas.getContext("2d");
    const width = canvas.clientWidth || 720;
    const height = canvas.clientHeight || 360;
    const scale = window.devicePixelRatio || 1;

    canvas.width = Math.floor(width * scale);
    canvas.height = Math.floor(height * scale);
    context.setTransform(scale, 0, 0, scale, 0, 0);
    context.clearRect(0, 0, width, height);

    if (triangles.length === 0) {
      context.fillStyle = "#d6eee7";
      context.font = "14px sans-serif";
      context.fillText("No STL triangles to preview", 24, 32);
      return;
    }

    const projected = triangles.map((triangle) => {
      const points = triangle.vertices.map((vertex) => ({
        x: (vertex.x - vertex.y) * 0.866,
        y: (vertex.x + vertex.y) * 0.35 - vertex.z * 0.72
      }));

      return {
        points,
        shade: Math.max(0.35, Math.min(0.95, 0.55 + triangle.normal.z * 0.35)),
        depth: triangle.vertices.reduce((sum, vertex) => sum + vertex.x + vertex.y + vertex.z, 0) / 3
      };
    });

    const bounds = projected.reduce((box, triangle) => {
      for (const point of triangle.points) {
        box.minX = Math.min(box.minX, point.x);
        box.maxX = Math.max(box.maxX, point.x);
        box.minY = Math.min(box.minY, point.y);
        box.maxY = Math.max(box.maxY, point.y);
      }

      return box;
    }, { minX: Infinity, maxX: -Infinity, minY: Infinity, maxY: -Infinity });

    const modelWidth = Math.max(1, bounds.maxX - bounds.minX);
    const modelHeight = Math.max(1, bounds.maxY - bounds.minY);
    const fit = Math.min((width - 48) / modelWidth, (height - 48) / modelHeight);
    const offsetX = width / 2 - (bounds.minX + modelWidth / 2) * fit;
    const offsetY = height / 2 - (bounds.minY + modelHeight / 2) * fit;

    context.lineJoin = "round";
    for (const triangle of projected.sort((a, b) => a.depth - b.depth)) {
      context.beginPath();
      triangle.points.forEach((point, index) => {
        const x = point.x * fit + offsetX;
        const y = point.y * fit + offsetY;
        if (index === 0) {
          context.moveTo(x, y);
        } else {
          context.lineTo(x, y);
        }
      });
      context.closePath();
      const shade = Math.round(255 * triangle.shade);
      context.fillStyle = `rgb(${shade}, ${shade}, ${shade})`;
      context.strokeStyle = "rgba(255, 255, 255, 0.48)";
      context.lineWidth = 0.7;
      context.fill();
      context.stroke();
    }
  },
  readBinaryStl: (bytes) => {
    if (bytes.byteLength < 84) {
      return [];
    }

    const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    const count = view.getUint32(80, true);
    const expectedLength = 84 + count * 50;
    if (expectedLength > bytes.byteLength) {
      return [];
    }

    const triangles = [];
    let offset = 84;
    for (let index = 0; index < count; index += 1) {
      const normal = {
        x: view.getFloat32(offset, true),
        y: view.getFloat32(offset + 4, true),
        z: view.getFloat32(offset + 8, true)
      };
      offset += 12;

      const vertices = [];
      for (let vertex = 0; vertex < 3; vertex += 1) {
        vertices.push({
          x: view.getFloat32(offset, true),
          y: view.getFloat32(offset + 4, true),
          z: view.getFloat32(offset + 8, true)
        });
        offset += 12;
      }

      offset += 2;
      triangles.push({ normal, vertices });
    }

    return triangles;
  }
};
