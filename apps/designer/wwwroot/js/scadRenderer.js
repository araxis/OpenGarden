window.openGardenScadRenderer = (() => {

    const _MODULE_URL = 'js/openscad.js';
    const _LIB_ROOTS = [
        '/usr/share/openscad/libraries',
        '/usr/local/share/openscad/libraries',
        '/libraries',
        '/root/.local/share/OpenSCAD/libraries',
    ];

    let _scadFiles = null;
    let _isReady = false;
    let _initPromise = null;

    const _WORKER_SRC = /* javascript */ `
self.onmessage = async function({ data: { scadFiles, configBlock, moduleUrl, libRoots } }) {
  let instance = null;

  function postGeneratedStl(message) {
    const bytes = instance.FS.readFile('/output.stl');
    self.postMessage({ ok: true, stlBuffer: bytes.buffer, message }, [bytes.buffer]);
  }

  try {
    const mod = await import(moduleUrl);
    // Note: ensure your openscad.js exports a default or named 'createOpenSCAD'
    const openScad = await mod.default({ noInitialRun: true }); 
    instance = openScad;

    function mkdirp(path) {
      const segs = path.replace(/^\\//, '').split('/');
      let cur = '';
      for (const s of segs) {
        if (!s) continue;
        cur += '/' + s;
        try { instance.FS.mkdir(cur); } catch {}
      }
    }

    // Mount Files
    for (const [rel, text] of scadFiles) {
      // 1. Mount as Library if it belongs to BOSL2
      if (rel.includes('BOSL2/')) {
        for (const root of libRoots) {
          const fp = root + '/' + rel;
          mkdirp(fp.substring(0, fp.lastIndexOf('/')));
          instance.FS.writeFile(fp, text);
        }
      } 
      // 2. Mount as Project file
      const projectPath = '/project/' + rel;
      mkdirp(projectPath.substring(0, projectPath.lastIndexOf('/')));
      instance.FS.writeFile(projectPath, text);
    }

    const dArgs = configBlock
      .split('\\n')
      .map(l => l.trim().replace(/;$/, ''))
      .filter(l => l.length > 0)
      .flatMap(l => ['-D', l]);

    // Execute - assuming main.scad is your entry point
    const code = instance.callMain(['/project/main.scad', ...dArgs, '-o', '/output.stl']);
    
    if (code !== 0) {
        self.postMessage({ ok: false, error: 'OpenSCAD Error Code: ' + code });
        return;
    }

    postGeneratedStl('STL generated successfully.');

  } catch (err) {
    try {
      if (instance) {
        postGeneratedStl('STL generated successfully. OpenSCAD reported a late runtime warning: ' + (err.message || err));
        return;
      }
    } catch {}

    self.postMessage({ ok: false, error: err.message || String(err) });
  }
};
`;

    async function init(scadBaseUrl, dotNetRef) {
        if (_initPromise) return _initPromise;
        _initPromise = _doInit(scadBaseUrl, dotNetRef);
        return _initPromise;
    }

    async function _doInit(scadBaseUrl, dotNetRef) {
        try {
            const base = scadBaseUrl.replace(/\/?$/, '/');
            const manifestResp = await fetch(base + 'manifest.json');
            const manifest = await manifestResp.json();

            const entries = await Promise.all(
                manifest.map(async (relPath) => {
                    const resp = await fetch(base + relPath);
                    const text = await resp.text();
                    return [relPath.replace(/\\/g, '/'), text];
                })
            );

            _scadFiles = new Map(entries);
            _isReady = true;
            if (dotNetRef) await dotNetRef.invokeMethodAsync('OnNotify', 'Ready');
        } catch (err) {
            console.error("OpenSCAD Init Failed", err);
        }
    }

    async function render(configBlock) {
        if (!_isReady) throw new Error("Not Ready");

        const started = performance.now();
        const blob = new Blob([_WORKER_SRC], { type: 'text/javascript' });
        const workerUrl = URL.createObjectURL(blob);
        const worker = new Worker(workerUrl, { type: 'module' });

        return new Promise((resolve) => {
            worker.onmessage = e => {
                const result = e.data;

                if (result.ok) {
                    const stlBytes = new Uint8Array(result.stlBuffer);
                    const stlBlob = new Blob([stlBytes], { type: 'model/stl' });
                    const url = URL.createObjectURL(stlBlob);

                    // This object matches your C# RendererResult class
                    resolve({
                        ok: true,
                        message: result.message || 'STL generated successfully.',
                        stlBytes: stlBytes, // Blazor converts this to byte[]
                        downloadUrl: url,
                        fileName: 'opengarden-preview.stl',
                        byteLength: stlBytes.length,
                        elapsedMs: performance.now() - started
                    });
                } else {
                    resolve({
                        ok: false,
                        message: result.error || 'Unknown rendering error',
                        elapsedMs: performance.now() - started
                    });
                }

                worker.terminate();
                URL.revokeObjectURL(workerUrl);
            };

            worker.postMessage({
                scadFiles: [..._scadFiles],
                configBlock,
                moduleUrl: new URL(_MODULE_URL, document.baseURI).href,
                libRoots: _LIB_ROOTS
            });
        });
    }


    return { init, render, dispose: () => { _isReady = false; _scadFiles = null; } };
})();
