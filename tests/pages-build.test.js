"use strict";

const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { buildPages } = require("../scripts/build-pages");

test("Pages builder packages static assets and a deterministically ordered library", (t) => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "bar-pages-src-"));
  const output = fs.mkdtempSync(path.join(os.tmpdir(), "bar-pages-out-"));
  t.after(() => {
    fs.rmSync(root, { recursive: true, force: true });
    fs.rmSync(output, { recursive: true, force: true });
  });
  for (const file of ["index.html", "styles.css", "app-pure.js", "app-library.js", "app.js"])
    fs.writeFileSync(path.join(root, file), file);
  fs.writeFileSync(path.join(root, ".env"), "private value");
  const tweaks = path.join(root, "tweaks");
  fs.mkdirSync(path.join(tweaks, "defs", "nested"), { recursive: true });
  fs.mkdirSync(path.join(tweaks, "units"), { recursive: true });
  fs.writeFileSync(path.join(tweaks, "defs", "z.lua"), "return 'z'");
  fs.writeFileSync(path.join(tweaks, "defs", "nested", "a.lua"), "return 'a'");
  fs.writeFileSync(path.join(tweaks, "units", "ignored.txt"), "not lua");
  fs.writeFileSync(path.join(tweaks, "state.defaults.json"), JSON.stringify({ "defs/z.lua": false }));

  const library = buildPages(root, output);
  assert.deepEqual(library.defs.map((file) => file.name), ["nested/a.lua", "z.lua"]);
  assert.equal(library.defs[0].enabled, true);
  assert.equal(library.defs[0].chars, "return 'a'".length);
  assert.equal(library.defs[1].enabled, false);
  assert.deepEqual(JSON.parse(fs.readFileSync(path.join(output, "library.json"), "utf8")), library);
  assert.equal(fs.readFileSync(path.join(output, "index.html"), "utf8"), "index.html");
  assert.deepEqual(fs.readdirSync(output).sort(), ["app-library.js", "app-pure.js", "app.js", "index.html", "library.json", "styles.css"]);
  assert.equal(fs.existsSync(path.join(output, ".env")), false);
});
