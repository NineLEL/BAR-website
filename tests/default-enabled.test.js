"use strict";

const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const { defaultEnabled } = require("./helpers/enabledTweaks");

const tweaksRoot = path.join(__dirname, "..", "tweaks");

test("test-owned default enablement manifest points only to existing Lua tweaks", () => {
  const entries = Object.entries(defaultEnabled);
  assert.ok(entries.length > 0, "default-enabled manifest must not be empty");

  for (const [relative, enabled] of entries) {
    assert.equal(enabled, true, `${relative}: manifest values must explicitly be true`);
    assert.ok(relative.endsWith(".lua"), `${relative}: manifest entries must identify Lua tweaks`);
    assert.ok(!relative.startsWith("/") && !relative.includes("\\") &&
      relative.split("/").every((part) => part && part !== "." && part !== ".."),
    `${relative}: manifest path must be a normalized relative tweak path`);
    const file = path.join(tweaksRoot, ...relative.split("/"));
    assert.ok(fs.statSync(file).isFile(), `${relative}: manifest entry must point to a file`);
  }
});
