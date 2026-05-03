/**
 * openGardenDesigner
 *
 * UI utilities: clipboard copy, file download, and the Three.js STL canvas viewer.
 * OpenSCAD rendering has moved to scadRenderer.js / openGardenScadRenderer.
 */
window.openGardenDesigner = {
  three: null,
  stlLoader: null,
  orbitControls: null,
  lastPreviewStl: null,
  lastPreviewScene: null,

  // ── clipboard ─────────────────────────────────────────────────────────────

  copyText: async (text) => {
    if (!navigator.clipboard) return false;
    await navigator.clipboard.writeText(text);
    return true;
  },

  prefersDarkMode: () =>
    window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches,

  // ── file download ─────────────────────────────────────────────────────────

  downloadUrl: (url, fileName) => {
    const link = document.createElement("a");
    link.href = url;
    link.download = fileName;
    document.body.append(link);
    link.click();
    link.remove();
  },

  // ── STL canvas viewer ─────────────────────────────────────────────────────

  drawLastPreviewStl: async (canvas) => {
    if (canvas && window.openGardenDesigner.lastPreviewStl) {
      await window.openGardenDesigner.drawStlPreview(
        canvas,
        window.openGardenDesigner.lastPreviewStl
      );
    }
  },

  drawStlPreview: async (canvas, stlBytes) => {
    const { THREE, STLLoader, OrbitControls } =
      await window.openGardenDesigner.loadThreeViewer();

    const width  = canvas.clientWidth  || 720;
    const height = canvas.clientHeight || 360;

    window.openGardenDesigner.disposeLastPreviewScene();

    const renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true, canvas });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    renderer.setSize(width, height, false);

    const scene    = new THREE.Scene();
    const camera   = new THREE.PerspectiveCamera(38, width / height, 0.1, 5000);
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;
    controls.dampingFactor = 0.08;

    const geometry = new STLLoader().parse(
      window.openGardenDesigner.stlToLoaderInput(stlBytes)
    );
    geometry.computeVertexNormals();
    geometry.computeBoundingBox();

    const material = new THREE.MeshStandardMaterial({
      color: 0xe8ece8, metalness: 0.05, roughness: 0.58, side: THREE.DoubleSide
    });
    const mesh  = new THREE.Mesh(geometry, material);
    const edges = new THREE.LineSegments(
      new THREE.EdgesGeometry(geometry, 25),
      new THREE.LineBasicMaterial({ color: 0xffffff, transparent: true, opacity: 0.22 })
    );
    scene.add(mesh, edges);

    scene.add(new THREE.HemisphereLight(0xffffff, 0x2f443b, 2.2));
    const keyLight = new THREE.DirectionalLight(0xffffff, 2.1);
    keyLight.position.set(1, -1.4, 2.4);
    scene.add(keyLight);

    const box    = geometry.boundingBox;
    const center = new THREE.Vector3();
    const size   = new THREE.Vector3();
    box.getCenter(center);
    box.getSize(size);
    mesh.position.sub(center);
    edges.position.sub(center);

    const maxDim   = Math.max(size.x, size.y, size.z, 1);
    const distance = maxDim / (2 * Math.tan(THREE.MathUtils.degToRad(camera.fov) / 2)) * 1.65;
    camera.position.set(distance * 0.9, -distance * 1.15, distance * 0.72);
    camera.near = Math.max(0.1, distance / 100);
    camera.far  = distance * 100;
    camera.updateProjectionMatrix();
    controls.target.set(0, 0, 0);
    controls.update();

    // Store the STL bytes so drawLastPreviewStl can re-draw after Blazor re-renders.
    window.openGardenDesigner.lastPreviewStl = stlBytes;

    let animationFrame = 0;
    const animate = () => {
      controls.update();
      renderer.render(scene, camera);
      animationFrame = requestAnimationFrame(animate);
    };
    animate();

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

  disposeLastPreviewScene: () => {
    if (window.openGardenDesigner.lastPreviewScene) {
      window.openGardenDesigner.lastPreviewScene.dispose();
      window.openGardenDesigner.lastPreviewScene = null;
    }
  },

  loadThreeViewer: async () => {
    if (!window.openGardenDesigner.three) {
      const [THREE, stlModule, controlsModule] = await Promise.all([
        import("https://esm.sh/three@0.160.0"),
        import("https://esm.sh/three@0.160.0/examples/jsm/loaders/STLLoader.js"),
        import("https://esm.sh/three@0.160.0/examples/jsm/controls/OrbitControls.js")
      ]);
      window.openGardenDesigner.three         = THREE;
      window.openGardenDesigner.stlLoader     = stlModule.STLLoader;
      window.openGardenDesigner.orbitControls = controlsModule.OrbitControls;
    }
    return {
      THREE:         window.openGardenDesigner.three,
      STLLoader:     window.openGardenDesigner.stlLoader,
      OrbitControls: window.openGardenDesigner.orbitControls
    };
  },

  stlToLoaderInput: (stl) => {
    if (typeof stl === "string")      return new TextEncoder().encode(stl).buffer;
    if (stl instanceof ArrayBuffer)   return stl;
    if (ArrayBuffer.isView(stl))      return stl.buffer.slice(stl.byteOffset, stl.byteOffset + stl.byteLength);
    return new ArrayBuffer(0);
  }
};
