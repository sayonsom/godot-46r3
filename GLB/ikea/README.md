IKEA GLB Asset Bundle

These assets were downloaded from live IKEA product pages using a repo-local workflow based on:
https://github.com/apinanaivot/IKEA-3d-model-batch-downloader

Why a custom workflow exists here:
- Current IKEA product pages expose 3D assets as Draco-compressed GLBs.
- Godot 4.6 in this project does not import `KHR_draco_mesh_compression` directly.
- `tools/ikea_glb_ingest.py` downloads the IKEA source model, then decodes it into a plain GLB with `gltf-transform` so Godot can import it.

Manifest:
- `manifest.json` tracks source product URLs, original IKEA GLB URLs, and local output files.

Rerun example:

```bash
source .venv/bin/activate
python tools/ikea_glb_ingest.py \
  'https://www.ikea.com/fi/en/cat/chairs-700676/' \
  'https://www.ikea.com/fi/en/cat/tables-700675/' \
  --max-products 10
```

After adding more assets, refresh imports with:

```bash
/opt/homebrew/bin/godot --headless --editor --path /Users/sayon/Documents/Codes/Backend/godot-46r3 --import --quit
```
