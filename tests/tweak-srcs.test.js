// Guards against phantom clone sources: every `src = "..."` in tweaks/defs/*.lua
// must name a real BAR unit (see bar-unit-names.json snapshot). A wrong src is
// either silently skipped (missing unit) or, worse, clones a different unit that
// happens to share the key (e.g. a wall), producing broken in-game units.
// Regenerate the snapshot from BAR master when the roster changes.
const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const defsDir = path.join(__dirname, "..", "tweaks", "defs");
const known = new Set(JSON.parse(fs.readFileSync(path.join(__dirname, "bar-unit-names.json"), "utf8")));

test("every tweak clone src exists in BAR", () => {
  const files = fs.readdirSync(defsDir).filter((f) => f.endsWith(".lua")).sort();
  assert.ok(files.length > 0, "no tweak files found");
  const missing = [];
  for (const f of files) {
    const src = fs.readFileSync(path.join(defsDir, f), "utf8");
    const re = /\bsrc\s*=\s*"([A-Za-z0-9_]+)"/g;
    let m;
    while ((m = re.exec(src)) !== null) {
      if (!known.has(m[1])) missing.push(`${f}: ${m[1]}`);
    }
  }
  assert.deepEqual(missing, [], `unknown clone sources:\n${missing.join("\n")}`);
});
