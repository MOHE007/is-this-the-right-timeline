#!/usr/bin/env node
// Turn the Godot web export into a CDN-friendly bundle.
//
// jsDelivr (Cloudflare) is 15-30x faster than GitHub Pages from mainland
// China, but it rejects files over 20MB — and Godot's index.wasm is ~35MB.
// So: split the wasm into <20MB parts and inject a fetch interceptor that
// reassembles it before the engine sees it. The same bundle still works on
// any ordinary host (parts load same-origin).
//
// Usage: node web/prepare_cdn.mjs <export-dir> <out-dir>
import { readFile, writeFile, mkdir, rm, readdir, copyFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import path from "node:path";

const PART_LIMIT = 19 * 1024 * 1024; // stay safely under jsDelivr's 20MB cap
const [exportDir, outDir] = process.argv.slice(2);
if (!exportDir || !outDir) {
  console.error("Usage: node web/prepare_cdn.mjs <export-dir> <out-dir>");
  process.exit(1);
}

const wasmPath = path.join(exportDir, "index.wasm");
if (!existsSync(wasmPath)) {
  console.error(`Missing ${wasmPath} — run the Godot web export first.`);
  process.exit(1);
}

await rm(outDir, { recursive: true, force: true });
await mkdir(outDir, { recursive: true });

// Copy everything except the oversized wasm.
for (const entry of await readdir(exportDir)) {
  if (entry === "index.wasm" || entry.endsWith(".import")) continue;
  await copyFile(path.join(exportDir, entry), path.join(outDir, entry));
}

// Split the wasm into parts under the cap.
const wasm = await readFile(wasmPath);
const partCount = Math.ceil(wasm.length / PART_LIMIT);
for (let i = 0; i < partCount; i += 1) {
  const chunk = wasm.subarray(i * PART_LIMIT, Math.min((i + 1) * PART_LIMIT, wasm.length));
  await writeFile(path.join(outDir, `index.wasm.part${i + 1}`), chunk);
}

// Inject the reassembly shim ahead of the engine loader.
const interceptor = `<script>
// CDN shim: rebuild index.wasm from ${partCount} parts before the engine loads.
(function () {
  var PARTS = ${partCount};
  var originalFetch = window.fetch.bind(window);
  window.fetch = function (input, init) {
    var url = typeof input === "string" ? input : (input && input.url) || "";
    if (!/index\\.wasm([?#]|$)/.test(url)) return originalFetch(input, init);
    var base = url.replace(/index\\.wasm([?#].*)?$/, "");
    var jobs = [];
    for (var i = 1; i <= PARTS; i += 1) {
      jobs.push(originalFetch(base + "index.wasm.part" + i).then(function (r) {
        if (!r.ok) throw new Error("wasm part HTTP " + r.status);
        return r.arrayBuffer();
      }));
    }
    return Promise.all(jobs).then(function (buffers) {
      var total = 0;
      buffers.forEach(function (b) { total += b.byteLength; });
      var merged = new Uint8Array(total);
      var offset = 0;
      buffers.forEach(function (b) { merged.set(new Uint8Array(b), offset); offset += b.byteLength; });
      return new Response(merged, { status: 200, headers: { "Content-Type": "application/wasm" } });
    });
  };
})();
</script>
`;

const htmlPath = path.join(outDir, "index.html");
const html = await readFile(htmlPath, "utf8");
const anchor = `<script src="index.js"></script>`;
if (!html.includes(anchor)) {
  console.error("Could not find the loader script tag in index.html");
  process.exit(1);
}
await writeFile(htmlPath, html.replace(anchor, `${interceptor}\t\t${anchor}`));

const mb = (n) => `${(n / 1024 / 1024).toFixed(1)}MB`;
console.log(`wasm ${mb(wasm.length)} -> ${partCount} parts (limit ${mb(PART_LIMIT)})`);
console.log(`bundle written to ${outDir}`);
