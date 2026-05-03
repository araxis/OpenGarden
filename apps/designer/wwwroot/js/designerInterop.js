window.openGardenDesigner = {
  openScad: null,
  three: null,
  stlLoader: null,
  orbitControls: null,
  lastPreviewStl: null,
  lastPreviewScene: null,
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
        await window.openGardenDesigner.drawStlPreview(canvas, output);
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
  drawLastPreviewStl: async (canvas) => {
    if (canvas && window.openGardenDesigner.lastPreviewStl) {
      await window.openGardenDesigner.drawStlPreview(canvas, window.openGardenDesigner.lastPreviewStl);
    }
  },
  drawStlPreview: async (canvas, stlBytes) => {
    const { THREE, STLLoader, OrbitControls } = await window.openGardenDesigner.loadThreeViewer();
    const width = canvas.clientWidth || 720;
    const height = canvas.clientHeight || 360;

    if (window.openGardenDesigner.lastPreviewScene) {
      window.openGardenDesigner.lastPreviewScene.dispose();
    }

    const renderer = new THREE.WebGLRenderer({
      alpha: true,
      antialias: true,
      canvas
    });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    renderer.setSize(width, height, false);

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(38, width / height, 0.1, 5000);
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;
    controls.dampingFactor = 0.08;

    const geometry = new STLLoader().parse(window.openGardenDesigner.stlToLoaderInput(stlBytes));
    geometry.computeVertexNormals();
    geometry.computeBoundingBox();

    const material = new THREE.MeshStandardMaterial({
      color: 0xe8ece8,
      metalness: 0.05,
      roughness: 0.58,
      side: THREE.DoubleSide
    });
    const mesh = new THREE.Mesh(geometry, material);
    scene.add(mesh);

    const edges = new THREE.LineSegments(
      new THREE.EdgesGeometry(geometry, 25),
      new THREE.LineBasicMaterial({ color: 0xffffff, transparent: true, opacity: 0.22 })
    );
    scene.add(edges);

    scene.add(new THREE.HemisphereLight(0xffffff, 0x2f443b, 2.2));
    const keyLight = new THREE.DirectionalLight(0xffffff, 2.1);
    keyLight.position.set(1, -1.4, 2.4);
    scene.add(keyLight);

    const box = geometry.boundingBox;
    const center = new THREE.Vector3();
    const size = new THREE.Vector3();
    box.getCenter(center);
    box.getSize(size);
    mesh.position.sub(center);
    edges.position.sub(center);

    const maxDimension = Math.max(size.x, size.y, size.z, 1);
    const distance = maxDimension / (2 * Math.tan(THREE.MathUtils.degToRad(camera.fov) / 2)) * 1.65;
    camera.position.set(distance * 0.9, -distance * 1.15, distance * 0.72);
    camera.near = Math.max(0.1, distance / 100);
    camera.far = distance * 100;
    camera.updateProjectionMatrix();
    controls.target.set(0, 0, 0);
    controls.update();

    let animationFrame = 0;
    const render = () => {
      controls.update();
      renderer.render(scene, camera);
      animationFrame = requestAnimationFrame(render);
    };
    render();

    window.openGardenDesigner.lastPreviewScene = {
      dispose: () => {
        cancelAnimationFrame(animationFrame);
        controls.dispose();
        geometry.dispose();
        material.dispose();
        edges.geometry.dispose();
        edges.material.dispose();
        renderer.dispose();
      }
    };
  },
  loadThreeViewer: async () => {
    if (!window.openGardenDesigner.three) {
      const [THREE, stlModule, controlsModule] = await Promise.all([
        import("https://esm.sh/three@0.160.0"),
        import("https://esm.sh/three@0.160.0/examples/jsm/loaders/STLLoader.js"),
        import("https://esm.sh/three@0.160.0/examples/jsm/controls/OrbitControls.js")
      ]);

      window.openGardenDesigner.three = THREE;
      window.openGardenDesigner.stlLoader = stlModule.STLLoader;
      window.openGardenDesigner.orbitControls = controlsModule.OrbitControls;
    }

    return {
      THREE: window.openGardenDesigner.three,
      STLLoader: window.openGardenDesigner.stlLoader,
      OrbitControls: window.openGardenDesigner.orbitControls
    };
  },
  stlToLoaderInput: (stl) => {
    if (typeof stl === "string") {
      return new TextEncoder().encode(stl).buffer;
    }

    if (stl instanceof ArrayBuffer) {
      return stl;
    }

    if (stl instanceof Uint8Array) {
      return stl.buffer.slice(stl.byteOffset, stl.byteOffset + stl.byteLength);
    }

    if (ArrayBuffer.isView(stl)) {
      return stl.buffer.slice(stl.byteOffset, stl.byteOffset + stl.byteLength);
    }

    return new ArrayBuffer(0);
  }
};
